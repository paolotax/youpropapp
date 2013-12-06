class ClientiController < UITableViewController

  attr_accessor :filtro, :menuVC, :mode, :controller


  KClientiMode = 0
  KAppuntiMode = 1


  def viewDidLoad
    super

    self.mode = KClientiMode

    self.tableView.layer.cornerRadius = 10
    self.navigationController.toolbarHidden = false
    self.navigationController.toolbar.layer.cornerRadius = 10
    self.navigationController.toolbar.clipsToBounds = true
 
    @refreshControl = UIRefreshControl.alloc.init
    @refreshControl.addTarget(self, action:"loadFromBackend", forControlEvents:UIControlEventValueChanged)
    self.tableView.addSubview(@refreshControl)

    @segmentedProvince = UISegmentedControl.alloc.initWithItems(["tutte","RA", "RE"])
    @segmentedProvince.setSelectedSegmentIndex(0)
    @segmentedProvince.addTarget(self, action:"changeProvincia:", forControlEvents:UIControlEventValueChanged)
    @segmentedProvince.delegate = self
    self.navigationItem.titleView = @segmentedProvince

    @segmentedControl = UISegmentedControl.alloc.initWithItems(["Clienti", "Appunti"])
    @segmentedControl.setSelectedSegmentIndex(0)
    @segmentedControl.addTarget(self, action:"changeMode:", forControlEvents:UIControlEventValueChanged)
    @segmentedControl.delegate = self
    segItem = UIBarButtonItem.alloc.initWithCustomView(@segmentedControl)
 
    sep =     UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)

    self.toolbarItems = [ sep, segItem, sep]

    self.tableView.registerClass(AppuntoCellAuto, forCellReuseIdentifier:"cellAppuntoAuto")
    self.tableView.registerClass(HeaderCliente, forHeaderFooterViewReuseIdentifier:"headerCliente")
    #self.tableView.sectionHeaderHeight = 44
    
  end


  def viewWillAppear(animated)
    super
    if Device.ipad?
      "clientiDidChange".add_observer(self, :reload)
    end
    contentSizeChange = UIContentSizeCategoryDidChangeNotification
    contentSizeChange.add_observer(self, "contentSizeCategoryChanged:", nil)
    reload
  end


  def viewWillDisappear(animated)
    super
    if Device.ipad?
      "clientiDidChange".remove_observer(self, :reload)
    end
    contentSizeChange = UIContentSizeCategoryDidChangeNotification
    contentSizeChange.remove_observer(self, "contentSizeCategoryChanged:")
  end


  def contentSizeCategoryChanged(notification)
    self.tableView.reloadData
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


  def changeMode(sender)
    self.mode = sender.selectedSegmentIndex
    reload
  end
  
  def changeProvincia(sender)
    ##
    reload
  end


  def scrollToClienteAndPush(cliente)
    indexPath = @controller.indexPathForObject(cliente)
    self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition:UITableViewScrollPositionTop, animated:false)
    cell = self.tableView.cellForRowAtIndexPath(indexPath)
    #cell.setSelected(true, animated:true)
    self.performSegueWithIdentifier("showCliente", sender:cell)
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


  # Storyboard methods
  def prepareForSegue(segue, sender:sender)
    
    if segue.identifier.isEqualToString("showCliente")
      cliente = @controller.objectAtIndexPath(self.tableView.indexPathForCell(sender)) || @controller.objectAtIndexPath(self.tableView.indexPathForSelectedRow)

      segue.destinationViewController.cliente = cliente
      segue.destinationViewController.titolo = filtro
      segue.destinationViewController.view.setTintColor self.view.tintColor
    
    elsif segue.identifier.isEqualToString("editAppunto")

      appunto = @controller.objectAtIndexPath(self.tableView.indexPathForCell(sender)) || @controller.objectAtIndexPath(self.tableView.indexPathForSelectedRow)

      controller = segue.destinationViewController.topViewController
      controller.cliente = appunto.cliente
      indexPath = self.tableView.indexPathForCell(sender)
      controller.appunto = appunto
      controller.isNew = false
      controller.presentedAsModal = true
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


  # tableViewDelegates

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

      cell = tableView.dequeueReusableCellWithIdentifier("cellAppuntoAuto", forIndexPath:indexPath)
      appunto = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)
      filtro == 'tutti' ? showLabel = true : showLabel = false       
      cell.fill_data(appunto, withCliente:showLabel)
    end
    cell
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)

    if mode == KAppuntiMode
      cell = tableView.dequeueReusableCellWithIdentifier("cellAppuntoAuto")
      appunto = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)
      cell.get_height(appunto)
    else
      54
    end
  end

  
  def tableView(tableView, viewForHeaderInSection:section)

    if mode == KAppuntiMode
      clienteHeader = tableView.dequeueReusableHeaderFooterViewWithIdentifier("headerCliente")

      cliente = self.fetchControllerForTableView(tableView).sections[section].objects.firstObject.cliente

      clienteHeader.textLabel.text = cliente.nome
      clienteHeader.textLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
    
      clienteHeader.circle_button.setColor self.view.tintColor
      clienteHeader.circle_button.nel_baule = cliente.nel_baule
      
      clienteHeader.section = section
      clienteHeader.delegate = self

      # isOpened = @sectionsOpened.include? section
      # clienteHeader.nel_baule.selected = isOpened

      # clienteHeader.titolo   = self.fetchControllerForTableView(tableView).sections[section].name
      # clienteHeader.quantita = self.fetchControllerForTableView(tableView).sections[section].objects.valueForKeyPath("@count").to_i.to_s
      
      # clienteHeader.contentView.backgroundColor = UIColor.darkGrayColor
      # clienteHeader.section = section
      # clienteHeader.delegate = self
      
      clienteHeader
    else
      nil
    end
  end

  
  def tableView(tableView, estimatedHeightForRowAtIndexPath:indexPath)
    if mode == KAppuntiMode
      100
    else
      54
    end
  end


  def tableView(tableView, accessoryButtonTappedForRowWithIndexPath:indexPath)
    
    if mode == KAppuntiMode
      self.performSegueWithIdentifier("editAppunto", sender:tableView.cellForRowAtIndexPath(indexPath))
    end
  end

  #
  # headerCliente delegate
  #
  def headerCliente(headerCliente, didTapBaule:section)

    cliente = @controller.sections[section].objects.firstObject.cliente
    if cliente.nel_baule == 0 
      cliente.nel_baule = 1
    else
      cliente.nel_baule = 0
    end
    Store.shared.save
    Store.shared.persist

    headerCliente.circle_button.nel_baule = cliente.nel_baule
  end


  private

    def loadFromBackend
      
      Store.shared.login do
        
        if mode == KClientiMode

          DataImporter.default.importa_clienti(nil) do |result|
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