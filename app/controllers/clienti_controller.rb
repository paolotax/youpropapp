class ClientiController < UITableViewController

  attr_accessor :filtro, :menuVC, :mode, :controller


  KClientiMode = 0
  KAppuntiMode = 1


  def viewDidLoad
    super

    self.mode = KClientiMode
    
    @refreshControl = UIRefreshControl.alloc.init
    @refreshControl.addTarget(self, action:"loadFromBackend", forControlEvents:UIControlEventValueChanged)
    self.tableView.addSubview(@refreshControl)

    self.navigationController.toolbarHidden = false

    @segmentedControl = UISegmentedControl.alloc.initWithItems(["Clienti", "Appunti"])
    @segmentedControl.setSelectedSegmentIndex(0)
    @segmentedControl.addTarget(self, action:"changeMode:", forControlEvents:UIControlEventValueChanged)
    @segmentedControl.delegate = self
    segItem = UIBarButtonItem.alloc.initWithCustomView(@segmentedControl)
 
    sep =     UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)


    self.toolbarItems = [ sep, segItem, sep]

    self.tableView.registerClass(AppuntoCellAuto, forCellReuseIdentifier:"cellAppuntoBis")
  end

  def viewWillAppear(animated)
    super
    if Device.ipad?
      "clientiDidChange".add_observer(self, :reload)
    end
    reload
  end

  def changeMode(sender)
    self.mode = sender.selectedSegmentIndex
    reload
  end

  def viewWillDisappear(animated)
    super
    if Device.ipad?
      "clientiDidChange".remove_observer(self, :reload)
    end
  end


  def reload
    @controller = nil
    self.tableView.reloadData

    if mode == KClientiMode
      tabella = "clienti"
    else
      tabella = 'appunti'
    end
    "#{filtro}changeTitolo".post_notification( self, titolo: filtro, sottotitolo: "#{@controller.fetchedObjects.count} #{tabella}" )
  end

  def scrollToClienteAndPush(cliente)
    indexPath = @controller.indexPathForObject(cliente)
    self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition:UITableViewScrollPositionTop, animated:false)
    cell = self.tableView.cellForRowAtIndexPath(indexPath)
    #cell.setSelected(true, animated:true)
    self.performSegueWithIdentifier("showCliente", sender:cell)
  end




  # Storyboard methods
  def prepareForSegue(segue, sender:sender)

    cliente = @controller.objectAtIndexPath(self.tableView.indexPathForCell(sender)) || @controller.objectAtIndexPath(self.tableView.indexPathForSelectedRow)
    
    if segue.identifier.isEqualToString("showCliente")
      segue.destinationViewController.cliente = cliente
      segue.destinationViewController.titolo = filtro
    end
  end

  def fetchControllerForTableView(tableView)

    @controller ||= begin

      if mode == KClientiMode
        klass = Cliente
        key = nil

      else
        klass = Appunto
        key = "cliente.provincia_e_comune"
      end

      klass.reset

      if filtro == "tutti"

        if mode == KAppuntiMode
          klass.setSortKeys ['created_at']
          klass.setSortOrders [false]
          klass.setSectionKey nil
        else
          klass.setSectionKey key
        end
        @controller = klass.controller 
      else
        klass.setSectionKey key
        if filtro == "in sospeso"
          @controller = klass.in_sospeso_controller         
        elsif filtro == "da fare"
          @controller = klass.da_fare_controller         
        else
          @controller = klass.nel_baule_controller
        end
      end
      @controller
    end
  end

  def numberOfSectionsInTableView(tableView)
    self.fetchControllerForTableView(tableView).sections.size
  end

  def tableView(tableView, heightForHeaderInSection:section)
    if mode == KClientiMode
      1
    else
      50
    end
  end

  def tableView(tableView, titleForHeaderInSection:section)
    self.fetchControllerForTableView(tableView).sections[section].name
  end
  
  def tableView(tableView, numberOfRowsInSection:section)
    self.fetchControllerForTableView(tableView).sections[section].numberOfObjects
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    
    if mode == KClientiMode
      
      cellIdentifier = "cellCliente";
      cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath:indexPath)
      
      cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton

      cliente = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)
      
      cell.clienteLabel.text = cliente.nome
      cell.cittaLabel.text = cliente.citta
      cell.cittaLabel.color = tableView.tintColor
      cell.colorButton.setColor tableView.tintColor
      cell.colorButton.nel_baule = cliente.nel_baule
      cell.colorButton.addTarget(self, action:"buttonTappedAction:", forControlEvents:UIControlEventTouchUpInside)

    elsif mode == KAppuntiMode

      cell = tableView.dequeueReusableCellWithIdentifier("cellAppuntoBis", forIndexPath:indexPath)
    
      cell.updateFonts
      
      appunto = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)

      if filtro == 'tutti'
        cell.labelDestinatario.text = "#{appunto.cliente.nome} #{appunto.destinatario}" 
      else  
        cell.labelDestinatario.text =  appunto.destinatario
      end
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
    end

    cell
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)

    if mode == KAppuntiMode
      cell = tableView.dequeueReusableCellWithIdentifier("cellAppuntoBis")
      
      cell.updateFonts
      
      appunto = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)

      cell.labelDestinatario.text =  appunto.destinatario
      cell.labelNote.text = appunto.note_e_righe + "\r\n"
      
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
    else
      54
    end
  end

  # def tableView(tableView, titleForHeaderInSection:section)
  #   if section == 0
  #     "da fare"
  #   elsif section == 1
  #     "in sospeso"
  #   else
  #     "completati"
  #   end
  # end

  def tableView(tableView, estimatedHeightForRowAtIndexPath:indexPath)
    if mode == KAppuntiMode
      100
    else
      54
    end
  end





  def buttonTappedAction(sender)
    buttonPosition = sender.convertPoint(CGPointZero, toView:self.tableView)
    indexPath = self.tableView.indexPathForRowAtPoint buttonPosition

    if indexPath
      cliente = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)
      if cliente.nel_baule == 0
        cliente.nel_baule = 1
      else
        cliente.nel_baule = 0
      end
      sender.nel_baule = cliente.nel_baule
    end

    "bauleDidChange".post_notification
  end

  private

    def loadFromBackend
      
      Store.shared.login do
        
        if mode == KClientiMode

          DataImporter.default.importa_clienti do |result|
            @refreshControl.endRefreshing unless @refreshControl.nil?
            if result.success?
              reload
            end          
          end

        else

          DataImporter.default.importa_appunti(nil) do |result|
            @refreshControl.endRefreshing unless @refreshControl.nil?
            if result.success?
              reload
            end  
          end
          
        end
      end
    end



end