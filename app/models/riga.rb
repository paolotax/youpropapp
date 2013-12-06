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
    { name: 'importo',           type: NSDecimalAttributeType,   default: 0.0, optional: true, transient: false, indexed: false},
    { name: 'riga_uuid',              type: NSStringAttributeType,    default: nil,  optional: true, transient: false, indexed: false}    
  ]

  @relationships = [
    {:name => 'appunto', :destination => 'Appunto', :inverse => 'righe', optional: true },
    {:name => 'libro',   :destination => 'Libro',   :inverse => 'libro_righe' }
  ]





  def self.addToAppunto(appunto, withLibro:libro)
    riga = Riga.add do |r|
      
      r.riga_uuid = BubbleWrap.create_uuid.downcase
      r.appunto = appunto
      r.remote_appunto_id = appunto.remote_id 
      r.libro = libro  
      r.libro_id = libro.remote_id
      r.titolo   = libro.titolo
      r.prezzo_copertina    = libro.prezzo_copertina
      r.prezzo_consigliato  = libro.prezzo_consigliato

      if r.appunto.cliente.cliente_tipo == "Cartolibreria"
        r.prezzo_unitario  = libro.prezzo_copertina
        r.sconto   = 20
      else
        r.prezzo_unitario  = libro.prezzo_consigliato
        r.sconto   = 0
      end 

      r.quantita = 1
      #r.importo = 
    end
    riga
  end

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