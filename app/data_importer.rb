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
  # da eliminare 
  ["clienti", "appunti", "righe", "classi", "libri", "adozioni"].each do |table|

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
  end


  ["clienti", "appunti", "righe", "classi", "libri", "adozioni"].each do |table|
        
    define_method("importa_#{table}_bis:withNotification:success:failure:") do |parameters, notification, success, failure|

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


  def sync_appunti
    #Store.shared.login do
      
      context = Store.shared.context

      request = NSFetchRequest.alloc.init
      entity = NSEntityDescription.entityForName("Appunto", inManagedObjectContext:context)
      request.setEntity(entity)

      predicate = NSPredicate.predicateWithFormat("remote_id == 0")
      request.setPredicate(predicate)

      error_ptr = Pointer.new(:object)
      data = context.executeFetchRequest(request, error:error_ptr)
      if data == nil
        raise "Error when fetching data: #{error_ptr[0].description}"
      end
      data

      for appunto in data do

        appunto.save_to_backend(nil, 
                     withNotification:"retrySave", 
                              success:lambda do
                                NSLog("loggo")
                                puts "success"
                              end, 
                              failure:lambda do
                                NSLog("loggo")
                                puts "failure"
                              end)

      end
    #end
  end


end