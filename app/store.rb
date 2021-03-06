class Store
  
  DB = 'Libri.sqlite'
  ManagedObjectClasses = [Libro, Cliente, Appunto, Riga, Classe, Adozione]
  
  BASE_URL = "http://youpropa.com"
  #BASE_URL = "http://localhost:3000"
  
  #server 
  APP_ID = "36e1b9ed802dc7ee45e375bf318924dc3ae0f0f842c690611fde8336687960eb"
  SECRET = "11ab577f8fabf2ac33bdd75e951fc6507ef7bc21ef993c2a77a1383bed438224"


# login

  def login(&block)
    
    SVProgressHUD.show

    data = {
      grant_type: 'password',
      client_id: APP_ID,
      client_secret: SECRET,
      username: CredentialStore.default.username,
      password: CredentialStore.default.password
    }
    
    self.client.postPath("oauth/token",
                         parameters:data,
                            success:lambda do |operation, responseObject|
                              puts "gino"
                              token = responseObject.objectForKey "access_token"
                              CredentialStore.default.token = token
                              SVProgressHUD.dismiss
                              set_token_header
                              block.call
                            end,
                                 
                            failure:lambda do |operation, error|
                              puts "error gino"
                              if operation.response
                                if (operation.response.statusCode == 500)
                                  SVProgressHUD.showErrorWithStatus("Ooops! Something went wrong!")
                                else
                                  jsonData = operation.responseString.dataUsingEncoding NSUTF8StringEncoding
                                  json = NSJSONSerialization.JSONObjectWithData jsonData, options:0, error:nil
                                  errorMessage = json.objectForKey "error"
                                  SVProgressHUD.showErrorWithStatus errorMessage
                                end
                              else
                                SVProgressHUD.showErrorWithStatus("No Connection")
                              end

                            end)
  end




  def set_token_header
    token = CredentialStore.default.token
    self.client.setDefaultHeader("Authorization", value: "Bearer #{token}")
  end

  
  def token_changed(notification)
    set_token_header
  end


  def client
    self.backend.HTTPClient
  end


  def baseURL
    BASE_URL
  end


  def setupReachability

    client.operationQueue.maxConcurrentOperationCount = 1
    client.operationQueue.suspended = true
    client.reachabilityStatusChangeBlock = lambda do |status| 
      if (status == AFNetworkReachabilityStatusNotReachable)
        puts "Not reachable"
      else
        client.operationQueue.suspended = false
        DataImporter.default.synchronize( 
            lambda do
              "reload_clienti_and_views".post_notification(self, filtro: nil)
              "reload_cliente".post_notification
            end,
            failure:lambda do
              App.alert "Impossibile salvare dati sul server"
            end) 
      end

      if status == AFNetworkReachabilityStatusReachableViaWiFi
        puts "on WiFi"
      end
    end    

    # client.operationQueue.maxConcurrentOperationCount = 1
    # client.operationQueue.suspended = true

    # @reachability = Reachability.reachabilityWithHostname("youpropa.com")
    
    # @reachability.reachableBlock = lambda do |reachable| 
    #   #client.operationQueue.suspended = false
    #   puts "reachable"
    # end    
    
    # @reachability.unreachableBlock = lambda do |reachable| 
    #   #client.operationQueue.suspended = true
    #   puts "unreachable"
    # end
    
    # @reachability.startNotifier
  end


  def isReachable?
    #@reachability.isReachable == true
    client.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable 
  end



  # NO NEED TO CHANGE ANYTHING BELOW THIS LINE
  
  def self.shared
    # Our store is a singleton object.
    @shared ||= Store.new
  end
  
  def context
    @context
  end

  def persistent_context
    @persistent_context
  end

  def store
    @store
  end

  def backend
    @backend
  end

  def save
    error_ptr = Pointer.new(:object)
    unless @context.save(error_ptr)
      raise "Error when saving the model: #{error_ptr[0].description}"
    end
    
    # Clear caches, they will be reloaded on demand
    ManagedObjectClasses.each {|c| c.reset}
  end

  def persist
    error_ptr = Pointer.new(:object)
    unless @persistent_context.save(error_ptr)
      raise "Error when saving the model: #{error_ptr[0].description}"
    end
    
    # Clear caches, they will be reloaded on demand
    ManagedObjectClasses.each {|c| c.reset}
  end

  def clear

    error = Pointer.new(:object)
    unless @store.resetPersistentStores(error)
      raise "Impossibile eliminare lo store"
    end
    initialize
  end

  def stats
    puts "context inserted: #{@context.insertedObjects.count}"
    puts "context updated: #{@context.updatedObjects.count}"
    puts "context deleted: #{@context.deletedObjects.count}"

    puts "persist inserted: #{@persistent_context.insertedObjects.count}"
    puts "persist updated: #{@persistent_context.updatedObjects.count}"
    puts "persist deleted: #{@persistent_context.deletedObjects.count}"
  end

  private

  def initialize

    url_cache = NSURLCache.alloc.initWithMemoryCapacity(4 * 1024 * 1024, diskCapacity:20 * 1024 * 1024, diskPath:nil)
    NSURLCache.setSharedURLCache(url_cache)
    
    @model ||= NSManagedObjectModel.alloc.init.tap do |m|
      m.entities = ManagedObjectClasses.collect {|c| c.entity}
      m.entities.each {|entity| entity.wireRelationships}
    end

    url = NSURL.URLWithString(BASE_URL)
    @backend = RKObjectManager.managerWithBaseURL(url)

    formatter = NSDateFormatter.new
    formatter.setDateFormat("yyyy-MM-dd'T'HH:mm:ssz")
    RKObjectMapping.addDefaultDateFormatter(formatter)

    @store = RKManagedObjectStore.alloc.initWithManagedObjectModel(@model)
    @backend.managedObjectStore = @store
    @backend.requestSerializationMIMEType = RKMIMETypeJSON

    store_path = RKApplicationDataDirectory().stringByAppendingPathComponent(DB)

    #elimina il db
    #error = Pointer.new(:object)
    #NSFileManager.defaultManager.removeItemAtPath(store_path, error:error)

    error_ptr = Pointer.new(:object)
    unless @store.addSQLitePersistentStoreAtPath(store_path,
                              fromSeedDatabaseAtPath:nil,
                                   withConfiguration:nil,
                                             options:{
                                                       NSInferMappingModelAutomaticallyOption: true,
                                                       NSMigratePersistentStoresAutomaticallyOption: true
                                                     },
                                               error:error_ptr)
      raise "Errore Inpossibile creare lo Store #{error_ptr[0].description}"
    end
    
    @store.createManagedObjectContexts
    
    @persistent_context = @store.persistentStoreManagedObjectContext
    @context = @store.mainQueueManagedObjectContext

    #RKlcl_configure_by_name("RestKit/Network", RKLogLevelTrace)
    #RKlcl_configure_by_name("RestKit/ObjectMapping", RKLogLevelTrace)

    MappingProvider.shared.init_mappings(@store, @backend)
  end

  


end