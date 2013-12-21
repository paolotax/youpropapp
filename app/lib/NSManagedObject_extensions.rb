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

  
  def remove_from_backend(&callback)
    if self.remote_id != 0  
      Store.shared.backend.deleteObject(self, path:nil, parameters:nil, 
                          success:lambda do |operation, responseObject|
                                    result = DataImporterResult.new(operation, responseObject, nil)
                                    callback.call(result)
                                  end, 
                          failure:lambda do |operation, error|
                                    result = DataImporterResult.new(operation, nil, error)
                                    callback.call(result)
                                    App.alert("#{error.localizedDescription}")
                                  end)
    end
  end


  def save_to_backend(parameters, withNotification:notification, success:success, failure:
    failure)

    processSuccessBlock = lambda do
      success.call
    end
    
    processFailureBlock = lambda do
      failure.call
    end

    token = CredentialStore.default.token
    Store.shared.client.setDefaultHeader("Authorization", value: "Bearer #{token}")

    if remote_id == 0
      method = "postObject:path:parameters:success:failure:"
    else
      method = "putObject:path:parameters:success:failure:"
    end

    successBlock = lambda do |operation, responseObject|
      result = DataImporterResult.new(operation, responseObject, nil)
      NSLog "Postato #{self.remote_id}"
      processSuccessBlock.call
    end

    failureBlock = lambda do |operation, error|
      puts "status=#{operation.HTTPRequestOperation.response.statusCode}"
      if (operation.HTTPRequestOperation.response.statusCode == 401)
        CredentialStore.default.token = nil
        auth = UserAuthenticator.new
        auth.refreshTokenAndRetryOperation(operation,
             withNotification:notification,
                      success:lambda do
                        processSuccessBlock.call
                      end,
                      failure:lambda do
                        processFailureBlock.call
                      end)
      else
        processFailureBlock.call
      end
    end
    
    Store.shared.backend.send( method, self, nil, parameters, successBlock, failureBlock)
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