class ClienteDetailController < UIViewController

  extend IB
  
  outlet :tableView

  attr_accessor :cliente
  attr_accessor :refreshControl
  attr_accessor :titolo

  def viewDidLoad
    super

    self.tableView.layer.cornerRadius = 10
    self.view.backgroundColor = UIColor.clearColor

    @refreshControl = UIRefreshControl.alloc.init
    @refreshControl.addTarget(self, action:"loadFromBackend", forControlEvents:UIControlEventValueChanged)
    self.tableView.addSubview(@refreshControl)

    self.tableView.registerClass(AppuntoCellAuto, forCellReuseIdentifier:"cellAppuntoAuto")

  end


  def viewWillAppear(animated)
    super
    "#{titolo}changeTitolo".post_notification( self, titolo: cliente.nome, sottotitolo: nil )
    contentSizeChange = UIContentSizeCategoryDidChangeNotification
    contentSizeChange.add_observer(self, "contentSizeCategoryChanged:", nil)
    reload
  end


  def viewWillDisappear(animated)
    super
    contentSizeChange = UIContentSizeCategoryDidChangeNotification
    contentSizeChange.remove_observer(self, "contentSizeCategoryChanged:")
  end


  def contentSizeCategoryChanged(notification)
    self.tableView.reloadData
  end

  def reload
    @sorted_appunti = nil
    @appunti_da_fare = nil
    @appunti_in_sospeso = nil
    @appunti_completati = nil
    self.tableView.reloadData
  end


  def appunti_da_fare
    @appunti_da_fare ||= begin
      @appunti_da_fare = []
      @appunti_da_fare = sorted_appunti.select { |a| a.status != "completato" && a.status != "in_sospeso" }
      @appunti_da_fare
    end
  end

  def appunti_in_sospeso
    @appunti_in_sospeso ||= begin
      @appunti_in_sospeso = [] 
      @appunti_in_sospeso = sorted_appunti.select { |a| a.status == "in_sospeso" }
      @appunti_in_sospeso
    end
  end

  def appunti_completati
    @appunti_completati ||= begin
      @appunti_completati = [] 
      @appunti_completati = sorted_appunti.select { |a| a.status == "completato" }
      @appunti_completati
    end
  end

  def sorted_appunti
    @sorted_appunti = []
    orderAppunti = NSSortDescriptor.sortDescriptorWithKey("created_at", ascending:false)
    @sorted_appunti = cliente.appunti.sortedArrayUsingDescriptors([orderAppunti])
    @sorted_appunti
  end

  # Storyboard methods
  def prepareForSegue(segue, sender:sender)
    
    if segue.identifier.isEqualToString("newAppunto")
      controller = segue.destinationViewController.topViewController
      controller.cliente = cliente
      controller.isNew = true
      controller.presentedAsModal = true
      controller.delegate = self
    
    elsif segue.identifier.isEqualToString("editAppunto")
      controller = segue.destinationViewController.topViewController
      controller.cliente = cliente
      indexPath = self.tableView.indexPathForCell(sender)
      if indexPath.section == 0
        appunto = appunti_da_fare.objectAtIndex( indexPath.row )
      elsif indexPath.section == 1
        appunto = appunti_in_sospeso.objectAtIndex( indexPath.row )
      else
        appunto = appunti_completati.objectAtIndex( indexPath.row )
      end
      controller.appunto = appunto
      controller.isNew = false
      controller.presentedAsModal = true
      controller.delegate = self
    
    elsif segue.identifier.isEqualToString("showInSospeso")
      controller = segue.destinationViewController
      controller.appunti = appunti_in_sospeso
      controller.cliente = cliente
      controller.tableView.setTintColor self.tableView.tintColor
    
    elsif segue.identifier.isEqualToString("showCompletati")
      controller = segue.destinationViewController
      controller.appunti = appunti_completati
      controller.cliente = cliente
      controller.tableView.setTintColor self.tableView.tintColor
    

    end
  end


#pragma mark - AppuntoFormController delegate 
  

  def appuntoFormController(appuntoFormController, didSaveAppunto:appunto)

    appuntoFormController.dismissViewControllerAnimated(true, completion:nil)
    DataImporter.default.sync_entity("Appunto",
                success:lambda do
                  reload
                end,
                failure:lambda do
                  App.alert "Impossibile salvare dati sul server"
                end) 

  end


#pragma mark - TableView delegate


  def numberOfSectionsInTableView(tableView)
    if cliente 
      3
    else
      0
    end
  end
  
  def tableView(tableView, numberOfRowsInSection:section)
    if cliente
      if section == 0
        appunti_da_fare.count
      elsif section == 1
        if appunti_in_sospeso.count > 0
          1
        else
          0
        end
      else
        if appunti_completati.count > 0
          1
        else
          0
        end
      end
    else
      0
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
   
    if indexPath.section == 0

      cell = tableView.dequeueReusableCellWithIdentifier("cellAppuntoAuto", forIndexPath:indexPath)

      appunto = appunti_da_fare.objectAtIndex( indexPath.row )
      cell.fill_data(appunto, withCliente:false)
    
    elsif indexPath.section == 1
      cell = tableView.dequeueReusableCellWithIdentifier("cellInSospeso", forIndexPath:indexPath)
      cell.textLabel.text = "#{appunti_in_sospeso.count} appunti"      
      cell.detailTextLabel.text = appunti_in_sospeso.inject(0) {|sum, a| sum + a.totale_importo.round(2)}.string_with_style(:currency)

    elsif indexPath.section == 2
      cell = tableView.dequeueReusableCellWithIdentifier("cellCompletato", forIndexPath:indexPath)
      cell.textLabel.text = "#{appunti_completati.count} appunti"
      cell.detailTextLabel.text = appunti_completati.inject(0) {|sum, a| sum + a.totale_importo.round(2)}.string_with_style(:currency)
    end    

    cell
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    if indexPath.section == 0
      cell = tableView.dequeueReusableCellWithIdentifier("cellAppuntoAuto")
      appunto = appunti_da_fare.objectAtIndex( indexPath.row )
      cell.get_height(appunto)
    else
      44
    end
  end

  def tableView(tableView, titleForHeaderInSection:section)
    if section == 0
      "da fare"
    elsif section == 1
      "in sospeso"
    else
      "completati"
    end
  end

  def tableView(tableView, estimatedHeightForRowAtIndexPath:indexPath)
    if indexPath.section == 0
      200
    else
      44
    end
  end

  
  def tableView(tableView, accessoryButtonTappedForRowWithIndexPath:indexPath)    
    self.performSegueWithIdentifier("editAppunto", sender:tableView.cellForRowAtIndexPath(indexPath))
  end


  def navigate(sender)
    placemark = MKPlacemark.alloc.initWithCoordinate(cliente.coordinate, addressDictionary:nil)
    mapItem = MKMapItem.alloc.initWithPlacemark(placemark)
    mapItem.name = cliente.nome    
    mapItem.openInMapsWithLaunchOptions({ MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving })
  end  


  def makeCall(sender)
    url = NSURL.URLWithString("tel://#{cliente.telefono.split(" ").join}")
    UIApplication.sharedApplication.openURL(url);
  end  


  def sendEmail(sender)
    url = NSURL.URLWithString("mailto://#{cliente.email}")
    UIApplication.sharedApplication.openURL(url);
  end 

  
  def goToSite(sender)
    url = NSURL.URLWithString("http://youpropa.com/clienti/#{cliente.ClienteId}")
    UIApplication.sharedApplication.openURL(url);
  end 


  private


    def loadFromBackend
      if Store.shared.isReachable? == false
        @refreshControl.endRefreshing unless @refreshControl.nil?
        App.alert "Dispositivo non connesso alla rete. Riprova più tardi"
        return
      end
      params = { cliente: cliente.ClienteId }
      DataImporter.default.importa_appunti(params) do |result|
        @refreshControl.endRefreshing unless @refreshControl.nil?
        if result.success?
          reload
        end  
      end
    end


end