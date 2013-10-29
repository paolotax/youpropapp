class MenuController < UITableViewController

  attr_accessor :mainVC

  def viewDidLoad
    super
    @selectedIndexPaths = [nil, nil]
    self.tableView.allowsMultipleSelection = true
  end

  def viewWillAppear(animated)
    super
    "bauleDidChange".add_observer(self, :ricalcola)
    ricalcola
  end

  def viewWillDisappear(animated)
    super
    "bauleDidChange".remove_observer(self, :ricalcola)
  end

  def ricalcola
    self.tableView.indexPathsForVisibleRows.each do |indexPath|
      if indexPath.row == 0
        count =  "#{self.nel_baule_count}"
      elsif indexPath.row == 1
        count =  "#{self.da_fare_count}"
      elsif indexPath.row == 2
        count =  "#{self.in_sospeso_count}"
      elsif indexPath.row == 3
        count =  "#{self.tutti_count}"
      end
      cell = self.tableView.cellForRowAtIndexPath indexPath
      cell.detailTextLabel.text = count
    end
  end

  def tableView(tableView, willDisplayCell:cell, forRowAtIndexPath:indexPath)
    cell.backgroundColor = UIColor.clearColor
    bgColorView = UIView.alloc.init
    bgColorView.backgroundColor = UIColor.colorWithRed(65.0/255.0, green:117.0/255.0, blue:209.0/255.0, alpha:1.0)
    bgColorView.layer.masksToBounds = true
    cell.selectedBackgroundView = bgColorView  
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    cell = tableView.cellForRowAtIndexPath indexPath
    
    self.mainVC.detailVC.color = cell.textLabel.color
    self.mainVC.detailVC.loadData(cell.textLabel.text)
  
  end

  def tableView(tableView, willSelectRowAtIndexPath:indexPath)
    section = indexPath.section
    oldIndex = @selectedIndexPaths[section]
    if oldIndex
      cell = tableView.cellForRowAtIndexPath oldIndex
      cell.setSelected(false, animated:false)
    end
    @selectedIndexPaths[section] = indexPath
    indexPath
  end


  # data count methods

  def nel_baule_count
    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName("Cliente", inManagedObjectContext:context)

    request.setIncludesPropertyValues false
    request.setIncludesSubentities false

    request.predicate = NSPredicate.predicateWithFormat("nel_baule = 1")
    
    error_ptr = Pointer.new(:object)
    data = context.countForFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end

  def in_sospeso_count
    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName("Cliente", inManagedObjectContext:context)

    request.setIncludesPropertyValues false
    request.setIncludesSubentities false

    pred = nil
    predicates = [] 
    predicates.addObject(NSPredicate.predicateWithFormat("nel_baule != 1"))
    predicates.addObject(NSPredicate.predicateWithFormat("appunti_da_fare = null"))
    predicates.addObject(NSPredicate.predicateWithFormat("appunti_in_sospeso > 0"))
    pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    request.predicate = pred
     
    error_ptr = Pointer.new(:object)
    data = context.countForFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end

  def da_fare_count
    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName("Cliente", inManagedObjectContext:context)

    request.setIncludesPropertyValues false
    request.setIncludesSubentities false

    pred = nil
    predicates = [] 
    predicates.addObject(NSPredicate.predicateWithFormat("nel_baule != 1"))
    predicates.addObject(NSPredicate.predicateWithFormat("appunti_da_fare > 0"))
    pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    request.predicate = pred
    
    error_ptr = Pointer.new(:object)
    data = context.countForFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end

  def tutti_count
    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName("Cliente", inManagedObjectContext:context)

    request.setIncludesPropertyValues false
    request.setIncludesSubentities false

    error_ptr = Pointer.new(:object)
    data = context.countForFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end

end