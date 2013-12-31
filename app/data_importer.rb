class DataImporterResult
  
  attr_accessor :operation, :object, :error

  def initialize(operation, responseObject, error)
    self.operation = operation
    self.object = responseObject
    self.error = error
  end

  def success?
    !failure?
  end

  def failure?
    !!error
  end

  def body
    if operation && operation.responseString
      operation.responseString
    end
  end
end


class DataImporter

  def self.default
    @default ||= DataImporter.new
  end


  # importa_...  I love metaprogramming
  # da eliminare il primo metodo
  TABLES.each do |table|

    define_method("importa_#{table}:") do |parameters, &callback|

      Store.shared.login do
        Store.shared.backend.getObjectsAtPath("api/v1/#{table}",
                             parameters: parameters,
                                success: lambda do |operation, responseObject|
                                                  result = DataImporterResult.new(operation, responseObject, nil)
                                                  callback.call(result) 
                                                  NSLog "#{table}: #{result.object.array.count}"
                                                end,
                                failure: lambda do |operation, error|
                                                  result = DataImporterResult.new(operation, nil, error)
                                                  callback.call(result)
                                                  App.alert("#{error.localizedDescription}")
                                                end)
      end
    end
        
    define_method("importa_#{table}:withNotification:success:failure:") do |parameters, notification, success, failure|

      processSuccessBlock = lambda do
        success.call
      end
      
      processFailureBlock = lambda do
        failure.call
        # if (operation.HTTPRequestOperation.response.statusCode == 500)
        #   failure.call("Something went wrong!")
        # else
        #   errorMessage = self.errorMessageForResponse operation
        #   failure.call(errorMessage)
        # end
      end

      token = CredentialStore.default.token
      Store.shared.client.setDefaultHeader("Authorization", value: "Bearer #{token}")

      Store.shared.backend.getObjectsAtPath("/api/v1/#{table}",
                                 parameters:parameters,
                                    success:lambda do |operation, responseObject|
                                      result = DataImporterResult.new(operation, responseObject, nil)
                                      userDefaults = NSUserDefaults.standardUserDefaults.setObject Time.now, forKey:"last_#{table}_sync"
                                      userDefaults.synchronize                          
                                      NSLog "#{table}: #{result.object.array.count}"
                                      processSuccessBlock.call
                                    end,
                                    
                                    failure:lambda do |operation, error|
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
                                    end)
    end
  end


  def errorMessageForResponse(operation)
    puts operation.HTTPRequestOperation.responseString
    # jsonData = operation.HTTPRequestOperation.responseString.dataUsingEncoding(NSUTF8StringEncoding)
    # json = NSJSONSerialization.JSONObjectWithData(jsonData, options:0, error:nil)
    # errorMessage = json.objectForKey "error"
    # errorMessage
  end


  def sync_entity
    
    statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)
    
    MappingProvider.shared.store = Store.shared.store
    mapping = MappingProvider.shared.cliente_mapping 
    descriptor = RKResponseDescriptor.responseDescriptorWithMapping(mapping, 
                                                    pathPattern:nil,
                                                        keyPath:"clienti",
                                                    statusCodes:statusCodeSet)

    url = "http://youpropa.com/api/v1/clienti".nsurl    
    request = NSMutableURLRequest.requestWithURL(url)
    request.setValue "Bearer #{CredentialStore.default.token}", forHTTPHeaderField:"Authorization"

    operation = RKManagedObjectRequestOperation.alloc.initWithRequest(request, responseDescriptors:[descriptor])
    
    store = Store.shared.store
    operation.managedObjectCache = store.managedObjectCache
    operation.managedObjectContext = store.mainQueueManagedObjectContext
    operation.setCompletionBlockWithSuccess(lambda do |operation, mappingResult|
          puts "ok clienti"
        end,
      failure:lambda do |operation, error|
        NSLog("ERROR: %@", error)
        NSLog("Response: %@", operation.HTTPRequestOperation.responseString)
      end
    )

    mapping2 = MappingProvider.shared.appunto_mapping
    descriptor2 = RKResponseDescriptor.responseDescriptorWithMapping(mapping2, 
                                                    pathPattern:nil,
                                                        keyPath:"appunti",
                                                    statusCodes:statusCodeSet)
    mapping3 = MappingProvider.shared.riga_mapping
    descriptor3 = RKResponseDescriptor.responseDescriptorWithMapping(mapping3, 
                                                    pathPattern:nil,
                                                        keyPath:"righe",
                                                    statusCodes:statusCodeSet)
    
    mapping4 = MappingProvider.shared.appunto_mapping
    descriptor4 = RKResponseDescriptor.responseDescriptorWithMapping(mapping4, 
                                                    pathPattern:nil,
                                                        keyPath:"libro",
                                                    statusCodes:statusCodeSet)
    

    url2 = "http://youpropa.com/api/v1/appunti".nsurl
    token = CredentialStore.default.token
    
    request2 = NSMutableURLRequest.requestWithURL(url2)
    request2.setValue "Bearer #{token}", forHTTPHeaderField:"Authorization"

    operation2 = RKManagedObjectRequestOperation.alloc.initWithRequest(request2, responseDescriptors:[descriptor2, descriptor3, descriptor4])
    store = Store.shared.store
    operation2.managedObjectCache = store.managedObjectCache
    operation2.managedObjectContext = store.mainQueueManagedObjectContext
    operation2.setCompletionBlockWithSuccess(lambda do |operation, mappingResult|
          puts "ok appunti"
        end,
      failure:lambda do |operation, error|
        NSLog("ERROR: %@", error)
        NSLog("Response: %@", operation.HTTPRequestOperation.responseString)
      end
    )


    requestArray = [operation, operation2]

    Store.shared.client.operationQueue.maxConcurrentOperationCount = 1
    
    Store.shared.backend.enqueueBatchOfObjectRequestOperations(requestArray,
      progress:lambda do |numberOfFinishedOperations, totalNumberOfOperations|
        NSLog("#{numberOfFinishedOperations / totalNumberOfOperations}")
      end,
      completion:lambda do |operations|
        puts "puts #{operations}"
        "reload_clienti_and_views".post_notification(self, filtro: nil)
        "reload_cliente".post_notification
      end
    )

  end

  def objectsToSync(entity_name, sinceDate:last_sync_date)
    
    context = Store.shared.context

    request = NSFetchRequest.alloc.init
    entity = NSEntityDescription.entityForName(entity_name, inManagedObjectContext:context)
    request.setEntity(entity)
    
    if last_sync_date
      predicate = NSPredicate.predicateWithFormat("remote_id == 0 or updated_at > %@", argumentArray:[last_sync_date])
      request.setPredicate(predicate)
    end

    request.sortDescriptors = ["updated_at"].collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
    }

    error_ptr = Pointer.new(:object)
    data = context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end

  def synchronize(success, failure:failure)
    
    if Store.shared.isReachable? == true && @is_synching.nil?
      
      @is_synching = true

      Store.shared.login do

        ["Libro", "Cliente", "Appunto"].each do |entity_name|
          
          last_sync_date = NSUserDefaults.standardUserDefaults.objectForKey "last_#{entityToTable(entity_name)}_sync"

          data = objectsToSync(entity_name, sinceDate:last_sync_date)

          for entity in data do
            entity.save_to_backend(nil, 
                         withNotification:"retrySave", 
                                  success:lambda do
     
                                    userDefaults = NSUserDefaults.standardUserDefaults.setObject entity.updated_at, forKey:"last_#{entityToTable(entity_name)}_sync"
                                    userDefaults.synchronize
                                    success.call
                                  end, 
                                  failure:lambda do
                                    userDefaults = NSUserDefaults.standardUserDefaults.setObject last_sync_date, forKey:"last_#{entityToTable(entity_name)}_sync"
                                    userDefaults.synchronize
                                    failure.call
                                    return
                                  end)

          end

          if last_sync_date
            params = { updated_at: last_sync_date }
          else
            params = nil
          end

          DataImporter.default.send("importa_#{entityToTable(entity_name)}:withNotification:success:failure:", 
                          params,
                            nil,
                            lambda do
                                userDefaults = NSUserDefaults.standardUserDefaults.setObject Time.now, forKey:"last_#{entityToTable(entity_name)}_sync"
                                userDefaults.synchronize
                                @is_synching = nil
                                success.call
                              end,
                            lambda do
                              userDefaults = NSUserDefaults.standardUserDefaults.setObject last_sync_date, forKey:"last_#{entityToTable(entity_name)}_sync"
                              userDefaults.synchronize
                              @is_synching = nil
                              failure.call
                            end) 
        end
      end
    end
  end

  def entityToTable(entity_name)

    if entity_name == "Appunto"
      table = "appunti"
    elsif entity_name == "Cliente"
      table = "clienti"
    elsif entity_name == "Libro"
      table = "libri"
    end
  end

      

end