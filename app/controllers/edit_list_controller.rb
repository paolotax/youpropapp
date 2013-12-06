class EditListController < UITableViewController


  attr_accessor :delegate, :value


  def initWithItems(items)
    init
    @items = items
    self
  end


  def viewDidLoad
    super
    # self.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel do |button|
    #   cancel(button) 
    # end
  end


# pragma mark - Actions


  def cancel(sender)
    self.navigationController.popViewControllerAnimated(true)
  end


# pragma mark - UITableView delegate


  def tableView(tableView, numberOfRowsInSection:section)
    @items.size
  end


  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    unless cell = tableView.dequeueReusableCellWithIdentifier('statoCell')
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:'statoCell')
    end
    status = @items[indexPath.row]
    cell.textLabel.text = status
    cell.accessoryType = UITableViewCellAccessoryCheckmark if status == value.split("_").join(" ")
    cell
  end


  def tableView(tableView, didSelectRowAtIndexPath:indexPath)

    if value
      previousIndexPath = NSIndexPath.indexPathForRow(@items.index(value.split("_").join(" ")), inSection:0)
      cell = tableView.cellForRowAtIndexPath(previousIndexPath)
      cell.accessoryType = UITableViewCellAccessoryNone
    end
    
    tableView.cellForRowAtIndexPath(indexPath).accessoryType = UITableViewCellAccessoryCheckmark
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    self.delegate.editListController(self, didSelectItem:@items[indexPath.row].split(" ").join("_"))

  end


end