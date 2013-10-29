class Classe < NSManagedObject
  
  
  attr_accessor :primitiveGiornoSection, :primitiveUpdatedAt

  PROPERTIES = [:remote_id, :classe, :sezione, :nr_alunni, :remote_cliente_id, :adozioni]
  
  @sortKeys = ['remote_cliente_id', 'num_classe', 'sezione']
  @sortOrders = [true, true, true]
  
  @sectionKey = nil
  @searchKey  = nil

  @attributes = [
    { name: 'remote_id',         type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'remote_cliente_id', type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'num_classe',        type: NSInteger16AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'sezione',           type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false},
    { name: 'nr_alunni',         type: NSInteger16AttributeType, default: 0,   optional: true, transient: false, indexed: false},
    { name: 'insegnanti',        type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false},
    { name: 'note',              type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false},
    { name: 'libro_1',           type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false},
    { name: 'libro_2',           type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false},
    { name: 'libro_3',           type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false},
    { name: 'libro_4',           type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false},
    { name: 'anno',              type: NSStringAttributeType,    default: nil,  optional: true, transient: false, indexed: false},
    { name: 'created_at',        type: NSDateAttributeType,      default: nil,  optional: true, transient: false, indexed: false},
    { name: 'updated_at',        type: NSDateAttributeType,      default: nil,  optional: true, transient: false, indexed: false},
    { name: 'giornoSection',     type: NSStringAttributeType,    default: nil,  optional: true, transient: true, indexed: false}
  ]

  @relationships = [
    { name: 'cliente',  destination: 'Cliente',  inverse: 'classi' },
    { name: 'adozioni', destination: 'Adozione', inverse: 'classe', json: 'adozioni', optional: true, transient: false, indexed: false, ordered: true, min: 0, max: NSIntegerMax, del: NSCascadeDeleteRule }
  ]


  def giornoSection 

    self.willAccessValueForKey("giornoSection")
    tmp = self.primitiveGiornoSection
    self.didAccessValueForKey("giornoSection")
        
    if tmp.nil?

      calendar = NSCalendar.currentCalendar
      components = calendar.components((NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit), fromDate:self.updated_at)

      tmp = NSString.stringWithFormat("%d", (components.year * 1000) + components.month + components.day)
      self.setPrimitiveGiornoSection(tmp)
    
    end 
    return tmp
  end

  def updated_at=(newDate)
    self.setPrimitiveUpdatedAt(newDate)
    self.didChangeValueForKey("updated_at")   
    self.setPrimitiveGiornoSection(nil)
  end

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


  def giorno_modifica
    updated_at.day
  end
  
  def self.recent_updates

    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)

    # pred = nil
    # predicates = [] 
    # predicates.addObject(NSPredicate.predicateWithFormat("cliente.nel_baule = 1"))
    # predicates.addObject(NSPredicate.predicateWithFormat("status != 'completato'"))
    # pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    # request.predicate = pred

    request.sortDescriptors = ["updated_at"].collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:false)
    }
    
    error_ptr = Pointer.new(:object)
    data = context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end


  def self.nel_baule
    
    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)

    pred = nil
    predicates = [] 
    predicates.addObject(NSPredicate.predicateWithFormat("cliente.nel_baule = 1"))
    pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    request.predicate = pred

    request.sortDescriptors = ["remote_cliente_id", "num_classe"].collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
    }
    
    error_ptr = Pointer.new(:object)
    data = context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end

end