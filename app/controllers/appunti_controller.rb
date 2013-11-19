class AppuntiController < UITableViewController

  extend IB
  
  attr_accessor :appunti
  attr_accessor :cliente

  attr_accessor :refreshControl
  attr_accessor :color

  def viewDidLoad
    super
    
    @refreshControl = UIRefreshControl.alloc.init
    @refreshControl.addTarget(self, action:"loadFromBackend", forControlEvents:UIControlEventValueChanged)
    self.tableView.addSubview(@refreshControl)

    self.tableView.registerClass(AppuntoCellAuto, forCellReuseIdentifier:"cellAppuntoAuto")

  end

  def viewWillAppear(animated)
    super    
    reload
  end

  def viewDidAppear(animated)
    super
    contentSizeChange = UIContentSizeCategoryDidChangeNotification
    contentSizeChange.add_observer(self, "contentSizeCategoryChanged:", nil)
  end

  def viewDidDisappear(animated)
    super
    contentSizeChange = UIContentSizeCategoryDidChangeNotification
    contentSizeChange.remove_observer(self, "contentSizeCategoryChanged:")
  end

  def contentSizeCategoryChanged(notification)
    reload
  end

  def reload
    self.tableView.reloadData
  end

  # Storyboard methods
  def prepareForSegue(segue, sender:sender)
    
    if segue.identifier.isEqualToString("editAppunto")
      controller = segue.destinationViewController.topViewController
      indexPath = self.tableView.indexPathForCell(sender)
      appunto = self.appunti[indexPath.row]
      controller.appunto = appunto
      controller.cliente = appunto.cliente
      controller.isNew = false
      controller.presentedAsModal = true
    end
  end


  def numberOfSectionsInTableView(tableView)
    1
  end
  
  def tableView(tableView, numberOfRowsInSection:section)
    self.appunti.count
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier("cellAppuntoAuto", forIndexPath:indexPath)
    appunto = self.appunti[indexPath.row]
    cell.fill_data(appunto, withCliente:false)
    cell
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier("cellAppuntoAuto")
    appunto = self.appunti[indexPath.row]
    cell.get_height(appunto)
  end

  def tableView(tableView, estimatedHeightForRowAtIndexPath:indexPath)
    200
  end

  def tableView(tableView, accessoryButtonTappedForRowWithIndexPath:indexPath)
    self.performSegueWithIdentifier("editAppunto", sender:tableView.cellForRowAtIndexPath(indexPath))
  end




  private

    def loadFromBackend
      params = { q: cliente.ClienteId }
      DataImporter.default.importa_appunti(params) do |result|
        @refreshControl.endRefreshing unless @refreshControl.nil?
        if result.success?
          reload
        end  
      end
    end


end