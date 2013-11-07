class ImporterResult
  
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

  def importa_clienti(&callback)
    Store.shared.login do
      puts "loggato"
      Store.shared.backend.getObjectsAtPath("api/v1/clienti",
                              parameters: nil,
                              success: lambda do |operation, responseObject|

                                                result = ImporterResult.new(operation, responseObject, nil)
                                                callback.call(result) 

                                                puts "Clienti: #{result.object.array.count}"
          
                                              end,
                              failure: lambda do |operation, error|
                                                
                                                result = ImporterResult.new(operation, nil, error)
                                                
                                                callback.call(result)
                                                
                                                App.alert("#{error.localizedDescription}")
                                              end)
    end
  end

  def importa_appunti(parameters, &callback)
    Store.shared.login do
      puts "loggato"
      Store.shared.backend.getObjectsAtPath("api/v1/appunti",
                           parameters: parameters,
                              success: lambda do |operation, responseObject|

                                                result = ImporterResult.new(operation, responseObject, nil)
                                                callback.call(result) 

                                                puts "Appunti: #{result.object.array.count}"
          
                                              end,
                              failure: lambda do |operation, error|
                                                
                                                result = ImporterResult.new(operation, nil, error)
                                                
                                                callback.call(result)
                                                
                                                App.alert("#{error.localizedDescription}")
                                              end)
    end
  end

  def importa_libri(&callback)
    Store.shared.backend.getObjectsAtPath("api/v1/libri",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Libri: #{result.array.count}"
                                                  callback.call(result)
                                                end,
                                failure: lambda do |operation, error|
                                                  App.alert("#{error.localizedDescription}")
                                                end)
  end

  def importa_righe(&callback)
    Store.shared.backend.getObjectsAtPath("api/v1/righe",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Righe: #{result.array.count}"
                                                  callback.call(result)
                                                end,
                                failure: lambda do |operation, error|
                                                  App.alert("#{error.localizedDescription}")
                                                end)
  end

  def importa_classi(&callback)
    Store.shared.backend.getObjectsAtPath("api/v1/classi",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Classi: #{result.array.count}"
                                                  callback.call(result)
                                                end,
                                failure: lambda do |operation, error|
                                                  App.alert("#{error.localizedDescription}")
                                                end)
  end

  def importa_adozioni(&callback)
    Store.shared.backend.getObjectsAtPath("api/v1/adozioni",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Adozioni: #{result.array.count}"
                                                  callback.call(result)
                                                end,
                                failure: lambda do |operation, error|
                                                  App.alert("#{error.localizedDescription}")
                                                end)
  end

end