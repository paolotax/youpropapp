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

  ["clienti", "appunti", "righe", "classi", "libri", "adozioni"].each do |table|

    define_method("importa_#{table}") do |parameters, &callback|

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


  def sync_appunti
    Store.shared.login do
      puts "loggato"
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
        appunto.save_to_backend do |result|
          if result.success?
            puts appunto.remote_id
          else
            puts "error"
          end
        end
      end
    end
  end


end