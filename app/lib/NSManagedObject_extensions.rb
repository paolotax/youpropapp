class NSManagedObject
  
  def self.setSectionKey(sectionKey)
    @sectionKey = sectionKey
  end  

  def self.setSortKeys(sortKeys)
    @sortKeys = sortKeys
  end  

  def self.setSortOrders(sortOrders)
    @sortOrders = sortOrders
  end  
  
  def self.entity
    @entity ||= NSEntityDescription.newEntityDescriptionWithName(name, attributes:@attributes, relationships:@relationships)
  end

  def self.objects
    # Use if you do not need any section in your table view
    @objects ||= NSFetchRequest.fetchObjectsForEntityForName(name, withSortKeys:@sortKeys, ascending:@sortOrders, inManagedObjectContext:Store.shared.context)
  end

  def self.controller
    # Use if you require sections in your table view
    @controller ||= NSFetchRequest.fetchObjectsForEntityForName(name, withSectionKey:@sectionKey, withSortKeys:@sortKeys, ascending:@sortOrders, withsearchKey:nil, withSearchString:nil, inManagedObjectContext:Store.shared.context)
  end
  
  def self.searchController(searchString)
    # Use if you have a search bar in your table view
    @searchController ||= NSFetchRequest.fetchObjectsForEntityForName(name, withSectionKey:@sectionKey, withSortKeys:@sortKeys, ascending:@sortOrders, withsearchKey:@searchKey, withSearchString:searchString, inManagedObjectContext:Store.shared.context)
  end

  def self.searchController(searchString, withScope:searchScope)
    # Use if you have a search bar in your table view
    @searchController ||= NSFetchRequest.fetchObjectsForEntityForName(name, withSectionKey:@sectionKey, withSortKeys:@sortKeys, ascending:@sortOrders, withsearchKey:@searchKey, withSearchString:searchString, withSearchScope:searchScope, inManagedObjectContext:Store.shared.context)
  end

  def refresh_backend
    Store.shared.backend.getObject(self, path:nil, parameters:nil, 
                        success:lambda do |operation, result|
                                  Store.shared.persist                                    
                                  "appuntiListDidLoadBackend".post_notification
                                  "reload_appunti_collections".post_notification
                                  "clientiListDidLoadBackend".post_notification
                                end, 
                        failure:lambda do |operation, error|
                                end)
  end
  
  def remove_from_backend


    if self.remote_id != 0  
      
      Store.shared.backend.deleteObject(self, path:nil, parameters:nil, 
                          success:lambda do |operation, result|
                                    Store.shared.persist
                                    "appuntiListDidLoadBackend".post_notification
                                    "reload_appunti_collections".post_notification
                                    "clientiListDidLoadBackend".post_notification
                                  end, 
                          failure:lambda do |operation, error|
                                  end)
    end
  end

  def save_to_backend(&callback)
    Store.shared.login do
      if self.remote_id == 0  
        Store.shared.backend.postObject(self, path:nil, parameters:nil, 
                            success:lambda do |operation, responseObject|

                                      result = ImporterResult.new(operation, responseObject, nil)
                                      
                                      callback.call(result)

                                    end, 
                            failure:lambda do |operation, error|
                                      result = ImporterResult.new(operation, nil, error)

                                      callback.call(result)
                                      App.alert("#{error.localizedDescription}")
                                    end)
      else
        Store.shared.backend.putObject(self, path:nil, parameters:nil, 
                            success:lambda do |operation, responseObject|

                                      result = ImporterResult.new(operation, responseObject, nil)
                                      
                                      callback.call(result)

                                    end, 
                            failure:lambda do |operation, error|
                                      result = ImporterResult.new(operation, nil, error)

                                      callback.call(result)
                                      App.alert("#{error.localizedDescription}")
                                    end)
      end
    end
  end


  def self.aggregateOperation(function, onAttribute:attributeName, withPredicate:predicate, inManagedObjectContext:context)

    ex = NSExpression.expressionForFunction(function,arguments:NSArray.arrayWithObject(NSExpression.expressionForKeyPath(attributeName)))

    ed = NSExpressionDescription.alloc.init
    ed.setName("result")
    ed.setExpression(ex)
    ed.setExpressionResultType(NSInteger64AttributeType)

    properties = NSArray.arrayWithObject(ed)

    request = NSFetchRequest.alloc.init
    request.setPropertiesToFetch(properties)
    request.setResultType(NSDictionaryResultType)
 
    request.setPredicate(predicate) unless predicate.nil?

    entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)
    request.setEntity(entity)

    results = context.executeFetchRequest(request, error:nil)
    resultsDictionary = results.objectAtIndex(0)
    resultValue = resultsDictionary.objectForKey("result")
    resultValue
  end



  
  def self.reset
    @objects = @controller = @searchController = nil
  end

  def self.add
    yield obj = NSEntityDescription.insertNewObjectForEntityForName(name, inManagedObjectContext:Store.shared.context)
    Store.shared.save
    obj
  end
  
  def update
    Store.shared.save
  end

  def remove
    Store.shared.context.deleteObject(self)
    Store.shared.save
  end

  def persist
    Store.shared.persist
  end

  def self.sections
    @sections
  end
  
  def self.numTextSections
    @sections.flatten.select{|x| x == :text or x == :longtext}.size
  end
  
  def managedObjectClass
    # Core data objects are not instances of NSManagedObjects, although they behave the same
    # Allow access to the real class
    NSClassFromString(self.entity.managedObjectClassName)
  end

end