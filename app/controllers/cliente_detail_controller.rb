class ClienteDetailController < UIViewController

  extend IB
  
  outlet :tableView

  attr_accessor :cliente
  attr_accessor :refreshControl
  attr_accessor :titolo

  def viewDidLoad
    super
 
    @refreshControl = UIRefreshControl.alloc.init
    @refreshControl.addTarget(self, action:"loadFromBackend", forControlEvents:UIControlEventValueChanged)
    self.tableView.addSubview(@refreshControl)

    self.tableView.registerClass(AppuntoCell, forCellReuseIdentifier:"cellAppuntoBis")

  end

  def viewDidAppear(animated)
    super
    "#{titolo}changeTitolo".post_notification( self, titolo: cliente.nome )

    NSNotificationCenter.defaultCenter.addObserver(self,
                                             selector:"contentSizeCategoryChanged:",
                                                 name:UIContentSizeCategoryDidChangeNotification,
                                               object:nil)
  end


  def viewDidDisappear(animated)
    super
    NSNotificationCenter.defaultCenter.removeObserver(self,
                                                    name:UIContentSizeCategoryDidChangeNotification,
                                                  object:nil)
  end


  def contentSizeCategoryChanged(notification)
    puts "contentSizeCategoryChanged"
    self.tableView.reloadData
  end



  def appunti_da_fare
    @appunti_da_fare = []
    @appunti_da_fare = sorted_appunti.select { |a| a.status != "completato" && a.status != "in_sospeso" }
    @appunti_da_fare
  end

  def appunti_in_sospeso
    @appunti_in_sospeso = [] 
    @appunti_in_sospeso = sorted_appunti.select { |a| a.status == "in_sospeso" }
    @appunti_in_sospeso
  end

  def appunti_completati
    @appunti_completati = [] 
    @appunti_completati = sorted_appunti.select { |a| a.status == "completato" }
    @appunti_completati
  end

  def sorted_appunti
    @sorted_appunti = []
    orderAppunti = NSSortDescriptor.sortDescriptorWithKey("created_at", ascending:false)
    @sorted_appunti = cliente.appunti.sortedArrayUsingDescriptors([orderAppunti])
    @sorted_appunti
  end


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
        appunti_in_sospeso.count
      else
        appunti_completati.count
      end
    else
      0
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
   
    cell = tableView.dequeueReusableCellWithIdentifier("cellAppuntoBis", forIndexPath:indexPath)
    
    cell.updateFonts
    
    if indexPath.section == 0
      appunto = appunti_da_fare.objectAtIndex( indexPath.row )
    elsif indexPath.section == 1
      appunto = appunti_in_sospeso.objectAtIndex( indexPath.row )
    else
      appunto = appunti_completati.objectAtIndex( indexPath.row )
    end    
    
    cell.labelDestinatario.text =  appunto.destinatario
    cell.labelNote.text = appunto.note_e_righe
    
    if appunto.totale_copie != 0
      cell.labelTotali.text = "#{appunto.totale_copie} copie - € #{appunto.totale_importo.round(2)}"
    else
      cell.labelTotali.text = nil
    end

    if appunto.status == "completato"
      cell.imageStatus.image = "completato".uiimage
      cell.imageStatus.highlightedImage = "completato".uiimage
    elsif appunto.status == "in_sospeso"
      cell.imageStatus.image = "826-money-1".uiimage
      cell.imageStatus.highlightedImage = "826-money-1-selected".uiimage
    else
      cell.imageStatus.image = nil
      cell.imageStatus.highlightedImage = nil
    end

    cell.setNeedsUpdateConstraints
    cell
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)

    cell = tableView.dequeueReusableCellWithIdentifier("cellAppuntoBis")
    
    cell.updateFonts
    
    if indexPath.section == 0
      appunto = appunti_da_fare.objectAtIndex( indexPath.row )
    elsif indexPath.section == 1
      appunto = appunti_in_sospeso.objectAtIndex( indexPath.row )
    else
      appunto = appunti_completati.objectAtIndex( indexPath.row )
    end     

    cell.labelDestinatario.text =  appunto.destinatario
    cell.labelNote.text = appunto.note_e_righe
    
    cell.labelNote.preferredMaxLayoutWidth = tableView.bounds.size.width - (78.0)
    
    if appunto.totale_copie != 0
      cell.labelTotali.text = "#{appunto.totale_copie} copie - € #{appunto.totale_importo.round(2)}"
    else
      cell.labelTotali.text = nil
    end

    cell.setNeedsUpdateConstraints
    cell.updateConstraintsIfNeeded
    cell.contentView.setNeedsLayout
    cell.contentView.layoutIfNeeded
    
    height = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height    
    
    height = [height, 48].max
    height
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
    100
  end


  private

    def loadFromBackend
      params = { q: cliente.ClienteId }

      Store.shared.login do
        Store.shared.backend.getObjectsAtPath(
          "api/v1/appunti",
        parameters: params,
           success: lambda do |operation, result|
                      Store.shared.backend.getObjectsAtPath(
                        "api/v1/righe",
                        parameters: params,
                           success: lambda do |operation, result|
                                      @refreshControl.endRefreshing unless @refreshControl.nil?
                                      self.tableView.reloadData
                                    end,
                           failure: lambda do |operation, error|
                                       @refreshControl.endRefreshing unless @refreshControl.nil?
                                       App.alert("#{error.localizedDescription}")
                                     end                              
                      )
                    end,
           failure: lambda do |operation, error|
                      @refreshControl.endRefreshing unless @refreshControl.nil?
                      App.alert("#{error.localizedDescription}")
                    end)
      end
    end






end