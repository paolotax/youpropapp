class EditStatoViewController < UITableViewController

  STATUSES = ['da fare', 'in sospeso', 'preparato', 'completato']

  attr_accessor :appunto, :delegate


  def tableView(tableView, numberOfRowsInSection:section)
    STATUSES.size
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    unless cell = tableView.dequeueReusableCellWithIdentifier('statoCell')
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:'statoCell')
    end
    status = STATUSES[indexPath.row]
    cell.textLabel.text = status
    cell.accessoryType = UITableViewCellAccessoryCheckmark if status == @appunto.status.split("_").join(" ")
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)

    if @appunto.status
      previousIndexPath = NSIndexPath.indexPathForRow(STATUSES.index(@appunto.status.split("_").join(" ")), inSection:0)
      cell = tableView.cellForRowAtIndexPath(previousIndexPath)
      cell.accessoryType = UITableViewCellAccessoryNone
    end
    
    tableView.cellForRowAtIndexPath(indexPath).accessoryType = UITableViewCellAccessoryCheckmark
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    self.delegate.editStatoController(self, didSelectStato:STATUSES[indexPath.row].split(" ").join("_"))

  end

  def close(sender)
    self.navigationController.popViewControllerAnimated(true)
  end
end