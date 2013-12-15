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

    @segmentedControl = UISegmentedControl.alloc.initWithItems(["Clienti", "Appunti"])
    @segmentedControl.setSelectedSegmentIndex(0)
    @segmentedControl.addTarget(self, action:"changeMode:", forControlEvents:UIControlEventValueChanged)
    @segmentedControl.delegate = self
    segItem = UIBarButtonItem.alloc.initWithCustomView(@segmentedControl) 
    sep =     UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)
    self.toolbarItems = [sep, segItem, sep]

    self.tableView.registerClass(AppuntoCellAuto, forCellReuseIdentifier:"cellAppuntoAuto")
    self.tableView.registerClass(HeaderCliente, forHeaderFooterViewReuseIdentifier:"headerCliente")    
  end


  def loadProvince
    items = ["tutte"]
    items += fetchProvince(@filtro.split.join("_"))

    @segmentedProvince = UISegmentedControl.alloc.initWithItems(items)
    @segmentedProvince.setSelectedSegmentIndex(0)
    @segmentedProvince.addTarget(self, action:"changeProvincia:", forControlEvents:UIControlEventValueChanged)
    @segmentedProvince.delegate = self
    self.navigationItem.titleView = @segmentedProvince
  end


  def viewWillAppear(animated)
    super
    if Device.ipad?
      "clientiDidChange".add_observer(self, :reload)
    end
    
    "#{filtro}_retry_sync".add_observer(self, :reloadBackend)

    contentSizeChange = UIContentSizeCategoryDidChangeNotification
    contentSizeChange.add_observer(self, "contentSizeCategoryChanged:", nil)
    reload


  end


  def viewWillDisappear(animated)
    super
    if Device.ipad?
      "clientiDidChange".remove_observer(self, :reload)
    end
    
    "#{filtro}_retry_sync".remove_observer(self, :reloadBackend)
    
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
    @provincia = @segmentedProvince.titleForSegmentAtIndex sender.selectedSegmentIndex
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
        if filtro != "tutti"
          key = "cliente.provincia_e_comune"
        else
          key = nil
        end
      end

      klass.reset
      klass.setSectionKey key
      @controller = klass.send("#{@filtro.split.join("_")}_controller", @provincia)
      @controller
    end
  end


  # tableViewDelegates


  def numberOfSectionsInTableView(tableView)
    self.fetchControllerForTableView(tableView).sections.size
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


  def tableView(tableView, heightForHeaderInSection:section)
    if mode == KClientiMode || (mode == KAppuntiMode && @filtro == "tutti")
      1
    else
      50
    end
  end

  
  def tableView(tableView, viewForHeaderInSection:section)

    if mode == KAppuntiMode && @filtro != "tutti"
      clienteHeader = tableView.dequeueReusableHeaderFooterViewWithIdentifier("headerCliente")

      cliente = self.fetchControllerForTableView(tableView).sections[section].objects.firstObject.cliente

      clienteHeader.textLabel.text = cliente.nome
      clienteHeader.textLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
    
      clienteHeader.circle_button.setColor self.view.tintColor
      clienteHeader.circle_button.nel_baule = cliente.nel_baule
      
      clienteHeader.section = section
      clienteHeader.delegate = self
      
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
    else
      cliente = @controller.objectAtIndexPath indexPath
      clienteForm = ClienteFormController.alloc.initWithCliente(cliente)
      nav = UINavigationController.alloc.initWithRootViewController clienteForm
      self.presentModalViewController nav, animated: true
    end
  end


  # headerCliente delegate


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


  def reloadBackend
    # se tolgo questo flag parte due volte loadFromBackend
    unless @retry_load_backend
      loadFromBackend
      @retry_load_backend = true
    end
  end


  def fetchProvince(scope)

    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    entity = NSEntityDescription.entityForName "Cliente", inManagedObjectContext:context
    request.entity = entity

    request = ScopeInjector.setScopeWithName("#{scope}", toFetchRequest: request)
    
    request.propertiesToFetch = NSArray.arrayWithObject(entity.propertiesByName.objectForKey("provincia"))
    request.returnsDistinctResults = true
    request.resultType = NSDictionaryResultType;

    #sortDescriptor = NSSortDescriptor.alloc.initWithKey("provincia", ascending:true)
    #request.setSortDescriptors(NSArray.arrayWithObject(sortDescriptor))


    error = Pointer.new(:object)
    distincResults = context.executeFetchRequest(request, error:error)

    return distincResults.map {|a| a[:provincia]}
  end


  private


    def loadFromBackend
        
      if mode == KClientiMode

        DataImporter.default.importa_clienti_bis(nil,
                                 withNotification:"#{filtro}_retry_sync",
                                          success:lambda do
                                            @refreshControl.endRefreshing unless @refreshControl.nil?
                                            reload
                                            @retry_load_backend = nil
                                          end,
                                          failure:lambda do
                                            @refresControl.endRefreshing unless @refreshControl.nil?
                                          end)         
      else

        DataImporter.default.importa_appunti_bis(nil,
                                 withNotification:"#{filtro}_reload_clienti",
                                          success:lambda do
                                            @refreshControl.endRefreshing unless @refreshControl.nil?
                                            reload
                                          end,
                                          failure:lambda do
                                            @refresControl.endRefreshing unless @refreshControl.nil?
                                          end)    
        
      end
    end


end