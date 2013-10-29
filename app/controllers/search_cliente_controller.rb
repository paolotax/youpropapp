class SearchClienteController  < UIViewController

  extend IB

  outlet :fakeTableView
  outlet :menuContainer

  attr_accessor :menuVC, :detailVC, :mainVC

  def viewDidLoad
    super
    self.fakeTableView.hidden = true

    self.searchDisplayController.searchResultsTableView.separatorColor = UIColor.lightGrayColor
    self.searchDisplayController.searchResultsTableView.backgroundColor = UIColor.clearColor
    
    self.searchDisplayController.searchResultsTableView.indicatorStyle = UIScrollViewIndicatorStyleWhite

  end

  def prepareForSegue(segue, sender:sender)
    if (segue.identifier.isEqualToString("menuSegue"))  
      self.menuVC = segue.destinationViewController
      self.menuVC.mainVC = self.mainVC
    end
  end


  # fetch data for searchDisplayController

  def fetchControllerForTableView(tableView)
    Cliente.searchController(@searchString, withScope:nil) 
  end

  # searchDisplayDelegates

  def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
    Cliente.reset
    Cliente.setSectionKey nil 
    @searchString = searchString
    true
  end

  def searchDisplayControllerWillBeginSearch controller
    self.menuContainer.hidden = true
  end

  def searchDisplayControllerDidEndSearch controller
    self.menuContainer.hidden = false
  end

  # tableView Delegates

  def numberOfSectionsInTableView(tableView)
    if tableView == self.fakeTableView
      0
    else
      self.fetchControllerForTableView(tableView).sections.size
    end
  end

  # def tableView(tableView, titleForHeaderInSection:section)
  #   self.fetchControllerForTableView(tableView).sections[section].name
  # end
  
  def tableView(tableView, numberOfRowsInSection:section)
    if tableView == self.fakeTableView
      0
    else
      self.fetchControllerForTableView(tableView).sections[section].numberOfObjects
    end    
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    54   
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)

    cellIdentifier = "cellCliente"

    if tableView == self.searchDisplayController.searchResultsTableView 
      cell = self.fakeTableView.dequeueReusableCellWithIdentifier cellIdentifier
    else
      cell = self.fakeTableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath:indexPath)
    end

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
    buttonPosition = sender.convertPoint(CGPointZero, toView:self.searchDisplayController.searchResultsTableView)
    
    indexPath = self.searchDisplayController.searchResultsTableView.indexPathForRowAtPoint buttonPosition

    if indexPath
      cliente = self.fetchControllerForTableView(self.searchDisplayController.searchResultsTableView).objectAtIndexPath(indexPath)
      if cliente.nel_baule == 0
        cliente.nel_baule = 1
      else
        cliente.nel_baule = 0
      end
      sender.nel_baule = cliente.nel_baule
    end

    "bauleDidChange".post_notification
    "clientiDidChange".post_notification
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)

    if tableView == self.searchDisplayController.searchResultsTableView 

      cell = tableView.cellForRowAtIndexPath indexPath
      cliente = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)
      
      nav = mainVC.detailVC.clientiVC.navigationController
      dvc = self.storyboard.instantiateViewControllerWithIdentifier("ClienteDetail")
      dvc.cliente = cliente
      nav.pushViewController(dvc, animated:true)
      self.searchDisplayController.setActive false
    end

  end
  
  def tableView(tableView, willDisplayCell:cell, forRowAtIndexPath:indexPath)
    cell.backgroundColor = UIColor.clearColor
    bgColorView = UIView.alloc.init
    bgColorView.backgroundColor = UIColor.colorWithRed(65.0/255.0, green:117.0/255.0, blue:209.0/255.0, alpha:1.0)
    bgColorView.layer.masksToBounds = true
    cell.selectedBackgroundView = bgColorView
  end


end