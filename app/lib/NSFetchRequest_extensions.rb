class NSFetchRequest
  
  def self.requestForEntityForName(entityName, withSortKeys:sortKeys, ascending:sortOrders, withsearchKey:searchKey, withSearchString:searchString, inManagedObjectContext:context)
    # Fetch all entityName from the model, filtering by searchKey and sorting by sortKey
    request = self.alloc.init
    request.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext:context)

      if searchKey 
        predicates = []
        searchKey.each do |sk|
          predicates.addObject(NSPredicate.predicateWithFormat("#{sk} contains[cd] %@", argumentArray:[searchString]))
        end
        request.predicate = NSCompoundPredicate.orPredicateWithSubpredicates(predicates)
        # request.predicate = NSPredicate.predicateWithFormat("#{searchKey} contains[cd] %@", argumentArray:[searchString]) if searchKey
      end
      
    request.sortDescriptors = sortKeys.collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:sortOrders[sortKeys.indexOfObject(sortKey)])
    } unless sortKeys == nil
    
    request
  end

  def self.requestForEntityForName(entityName, withSortKeys:sortKeys, ascending:sortOrders, withsearchKey:searchKey, withSearchString:searchString, withSearchScope:searchScope, inManagedObjectContext:context)
    # Fetch all entityName from the model, filtering by searchKey and sorting by sortKey
    request = self.alloc.init
    request.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext:context)

    pred = nil
    
    if searchKey && searchString
      searchPredicates = [] 
      searchKey.each do |sk|
        searchPredicates.addObject(NSPredicate.predicateWithFormat("#{sk} contains[cd] %@", argumentArray:[searchString]))
      end
      pred = NSCompoundPredicate.orPredicateWithSubpredicates(searchPredicates)
    end

    if searchScope && searchScope != "tutti"
      
      tmpPred = [pred]  
      tmpPred.addObject(NSPredicate.predicateWithFormat("status contains[cd] %@", argumentArray:[searchScope]))
      pred = NSCompoundPredicate.andPredicateWithSubpredicates(tmpPred)
    end

    request.predicate = pred
      
    request.sortDescriptors = sortKeys.collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:sortOrders[sortKeys.indexOfObject(sortKey)])
    } unless sortKeys == nil
    
    request
  end
  
  def self.fetchObjectsForEntityForName(entityName, withSortKeys:sortKeys, ascending:sortOrders, inManagedObjectContext:context)
    
    request = self.requestForEntityForName(entityName, withSortKeys:sortKeys, ascending:sortOrders, withsearchKey:nil, withSearchString:nil, inManagedObjectContext:context)
    
    error_ptr = Pointer.new(:object)
    data = context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end

  def self.fetchObjectsForEntityForName(entityName, withSectionKey:sectionKey, withSortKeys:sortKeys, ascending:sortOrders, withsearchKey:searchKey, withSearchString:searchString, inManagedObjectContext:context)
    
    request = self.requestForEntityForName(entityName, withSortKeys:sortKeys, ascending:sortOrders, withsearchKey:searchKey, withSearchString:searchString, inManagedObjectContext:context)
    
    error_ptr = Pointer.new(:object)
    controller = NSFetchedResultsController.alloc.initWithFetchRequest(request, managedObjectContext:context, sectionNameKeyPath:sectionKey, cacheName:nil)      
    unless controller.performFetch(error_ptr)
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    
    controller
  end

  def self.fetchObjectsForEntityForName(entityName, withSectionKey:sectionKey, withSortKeys:sortKeys, ascending:sortOrders, withsearchKey:searchKey, withSearchString:searchString, withSearchScope:searchScope, inManagedObjectContext:context)
    
    request = self.requestForEntityForName(entityName, withSortKeys:sortKeys, ascending:sortOrders, withsearchKey:searchKey, withSearchString:searchString, withSearchScope:searchScope,inManagedObjectContext:context)
    
    error_ptr = Pointer.new(:object)
    controller = NSFetchedResultsController.alloc.initWithFetchRequest(request, managedObjectContext:context, sectionNameKeyPath:sectionKey, cacheName:nil)      
    unless controller.performFetch(error_ptr)
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    
    controller
  end
end