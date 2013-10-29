class DataImporter


  def self.default
    # Our store is a singleton object.
    @default ||= DataImporter.new
  end

  def importa_clienti(&block)
    Store.shared.login do
      puts "loggato"
      Store.shared.backend.getObjectsAtPath("api/v1/clienti",
                              parameters: nil,
                              success: lambda do |operation, result|
                                                puts "Clienti: #{result.array.count}"
                                                block.call(result)
                                              end,
                              failure: lambda do |operation, error|
                                                puts error
                                              end)
    end
  end

  def importa_appunti(&block)
    Store.shared.backend.getObjectsAtPath("api/v1/appunti",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Appunti: #{result.array.count}"
                                                  block.call(result)
                                                end,
                                failure: lambda do |operation, error|
                                                  puts error
                                                end)
  end

  def importa_libri(&block)
    Store.shared.backend.getObjectsAtPath("api/v1/libri",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Libri: #{result.array.count}"
                                                  block.call(result)
                                                end,
                                failure: lambda do |operation, error|
                                                  puts error
                                                end)
  end

  def importa_righe(&block)
    Store.shared.backend.getObjectsAtPath("api/v1/righe",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Righe: #{result.array.count}"
                                                  block.call(result)
                                                end,
                                failure: lambda do |operation, error|
                                                  puts error
                                                end)
  end

  def importa_classi(&block)
    Store.shared.backend.getObjectsAtPath("api/v1/classi",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Classi: #{result.array.count}"
                                                  block.call(result)
                                                end,
                                failure: lambda do |operation, error|
                                                  puts error
                                                end)
  end

  def importa_adozioni(&block)
    Store.shared.backend.getObjectsAtPath("api/v1/adozioni",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Adozioni: #{result.array.count}"
                                                  block.call(result)
                                                end,
                                failure: lambda do |operation, error|
                                                  puts error
                                                end)
  end

end