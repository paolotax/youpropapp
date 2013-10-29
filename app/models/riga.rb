class Riga < NSManagedObject
  
  @sortKeys = ['titolo']
  @sortOrders = [true]
  
  @sectionKey = nil
  @searchKey  = 'titolo'

  @attributes = [
    { name: 'remote_id',         type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'remote_appunto_id', type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'libro_id',          type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'fattura_id',        type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'quantita',          type: NSInteger16AttributeType, default: 1,   optional: true, transient: false, indexed: false},
    { name: 'titolo',            type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false},
    { name: 'prezzo_unitario',   type: NSDecimalAttributeType,   default: 0.0, optional: true, transient: false, indexed: false},
    { name: 'prezzo_copertina',  type: NSDecimalAttributeType,   default: 0.0, optional: true, transient: false, indexed: false},
    { name: 'prezzo_consigliato',type: NSDecimalAttributeType,   default: 0.0, optional: true, transient: false, indexed: false},
    { name: 'sconto',            type: NSDecimalAttributeType,   default: 0.0, optional: true, transient: false, indexed: false},
    { name: 'importo',           type: NSDecimalAttributeType,   default: 0.0, optional: true, transient: false, indexed: false}    
  ]

  @relationships = [
    {:name => 'appunto', :destination => 'Appunto', :inverse => 'righe' },
    {:name => 'libro',   :destination => 'Libro',   :inverse => 'libro_righe' }
  ]


  def self.nel_baule
    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)

    pred = nil
    predicates = [] 
    predicates.addObject(NSPredicate.predicateWithFormat("appunto.cliente.nel_baule = 1"))
    predicates.addObject(NSPredicate.predicateWithFormat("appunto.status != 'completato'"))
    pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    request.predicate = pred

    request.sortDescriptors = ["appunto.remote_id", "libro_id"].collect { |sortKey|
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