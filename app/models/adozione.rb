class Adozione < NSManagedObject
  
  PROPERTIES = [:remote_id, :remote_libro_id, :sigla, :remote_classe_id]
  
  @sortKeys = ['remote_classe_id']
  @sortOrders = [true]
  
  @sectionKey = nil
  @searchKey  = nil

  @attributes = [
    { name: 'remote_id',        type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'remote_classe_id', type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'remote_libro_id',  type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'sigla',            type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false},
    { name: 'kit_1',            type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false},
    { name: 'kit_2',            type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false},
    { name: 'created_at',       type: NSDateAttributeType,    default: nil,  optional: true, transient: false, indexed: false},
    { name: 'updated_at',       type: NSDateAttributeType,    default: nil,  optional: true, transient: false, indexed: false}
        
  ]

  @relationships = [
    { name: 'classe', destination: 'Classe', inverse: 'adozioni' },
    { name: 'libro',  destination: 'Libro',  inverse: 'libro_adozioni' }
  ]

  def save_to_backend
    if self.remote_id == 0  
      Store.shared.backend.postObject(self, path:nil, parameters:nil, 
                          success:lambda do |operation, result|
                                    Store.shared.persist
                                  end, 
                          failure:lambda do |operation, error|
                                  end)
    else
      Store.shared.backend.putObject(self, path:nil, parameters:nil, 
                          success:lambda do |operation, result|
                                    Store.shared.persist  
                                  end, 
                          failure:lambda do |operation, error|
                                  end)
    end
  end

  def self.nel_baule
    
    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)

    pred = nil
    predicates = [] 
    predicates.addObject(NSPredicate.predicateWithFormat("classe.cliente.nel_baule = 1"))
    pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    request.predicate = pred

    request.sortDescriptors = ["remote_libro_id", "classe.cliente.ClienteId", "classe.num_classe", "classe.sezione"].collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
    }
    
    error_ptr = Pointer.new(:object)
    data = context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end

  def self.nel_baule_sum
    
    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)

    pred = nil
    predicates = [] 
    predicates.addObject(NSPredicate.predicateWithFormat("classe.cliente.nel_baule = 1"))
    pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    request.predicate = pred

    # request.sortDescriptors = ["remote_libro_id", "classe.cliente.ClienteId", "classe.num_classe", "classe.sezione"].collect { |sortKey|
    #   NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
    # }
    

    key = NSExpression.expressionForKeyPath "remote_libro_id" 
    countExpression = NSExpression.expressionForFunction("count:", arguments:[key])

    ex = NSExpressionDescription.alloc.init
    ex.setExpression(countExpression)
    ex.setExpressionResultType(NSInteger32AttributeType)
    ex.setName("tot sezioni")
    request.setPropertiesToFetch(["remote_libro_id", ex])
    request.setPropertiesToGroupBy(["remote_libro_id"])
    request.setResultType(NSDictionaryResultType )


    error_ptr = Pointer.new(:object)
    data = context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data

    data
  end



end

