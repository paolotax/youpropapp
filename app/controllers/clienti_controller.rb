class ClientiController < UITableViewController

  attr_accessor :filtro_clienti, :menuVC

  def viewDidLoad
    super
    @refreshControl = UIRefreshControl.alloc.init
    @refreshControl.addTarget(self, action:"loadFromBackend", forControlEvents:UIControlEventValueChanged)
    self.tableView.addSubview(@refreshControl)

    self.navigationController.toolbarHidden = false

    @segmentedControl = UISegmentedControl.alloc.initWithItems(["Clienti", "Appunti"])
    @segmentedControl.delegate = self

    # segmentedControl.insertSegmentWithTitle("Appunti", atIndex:0,animated:false)
    #   segmentedControl.insertSegmentWithTitle("Classi", atIndex:1,animated:false)
    #   segmentedControl.selectedSegmentIndex = 0

    segItem = UIBarButtonItem.alloc.initWithCustomView(@segmentedControl)

 
    sep =     UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)


    self.toolbarItems = [ sep, segItem, sep]
  end

  def viewWillAppear(animated)
    super
    if Device.ipad?
      "clientiDidChange".add_observer(self, :reload)
      reload
    end
  end

  def onCancel(sender)
  end

  def viewWillDisappear(animated)
    super
    if Device.ipad?
      "clientiDidChange".remove_observer(self, :reload)
    end
  end

  def viewDidAppear(animated)
    super
    "#{filtro_clienti}changeTitolo".post_notification( self, titolo: filtro_clienti )
  end

  def reload
    @controller = nil
    self.tableView.reloadData
  end

  # Storyboard methods
  def prepareForSegue(segue, sender:sender)
    cliente = @controller.objectAtIndexPath self.tableView.indexPathForSelectedRow
    if segue.identifier.isEqualToString("showCliente")
      segue.destinationViewController.cliente = cliente
      segue.destinationViewController.titolo = filtro_clienti
    end
  end


  def fetchControllerForTableView(tableView)
    @controller ||= begin
      Cliente.reset    
      if filtro_clienti == "tutti"
        Cliente.setSectionKey nil
        @controller = Cliente.controller 
      else
        Cliente.setSectionKey nil
        if filtro_clienti == "in sospeso"
          @controller = Cliente.con_appunti_in_sospeso_controller         
        elsif filtro_clienti == "da fare"
          @controller = Cliente.con_appunti_da_fare_controller         
        else
          @controller = Cliente.nel_baule_controller
        end
      end
      @controller
    end
  end

  def numberOfSectionsInTableView(tableView)
    self.fetchControllerForTableView(tableView).sections.size
  end

  def tableView(tableView, heightForHeaderInSection:section)
    if filtro_clienti == 'tutti'
      return 20
    else
      return 1
    end
  end

  # def tableView(tableView, titleForHeaderInSection:section)
  #   self.fetchControllerForTableView(tableView).sections[section].name
  # end
  
  def tableView(tableView, numberOfRowsInSection:section)
    self.fetchControllerForTableView(tableView).sections[section].numberOfObjects
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    
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

    cell
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
        Store.shared.backend.getObjectsAtPath("api/v1/clienti",
                                    parameters: nil,
                                    success: lambda do |operation, result|
                                                      @refreshControl.endRefreshing unless @refreshControl.nil?
                                                      "bauleDidChange".post_notification
                                                      self.tableView.reloadData
                                                    end,
                                    failure: lambda do |operation, error|
                                                      @refreshControl.endRefreshing unless @refreshControl.nil?
                                                      App.alert("#{error.localizedDescription}")
                                                    end)
      end
    end



end