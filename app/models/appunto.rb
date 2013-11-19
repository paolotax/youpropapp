class Appunto < NSManagedObject


  attr_accessor :primitiveData, :setPrimitiveCreatedAt

  @sortKeys   = ['cliente.provincia', 'cliente.comune', 'cliente.nome']
  @sortOrders = [true, true, true]
  
  @sectionKey = "cliente.provincia_e_comune"
  @searchKey  = ["cliente_nome", "destinatario", "note", "cliente.comune", "cliente.frazione"]

  @attributes = [
    { name: 'remote_id',    type: NSInteger32AttributeType, default: nil,   optional: true, transient: false, indexed: false},
    { name: 'ClienteId',    type: NSInteger32AttributeType, default: nil,   optional: true, transient: false, indexed: false},
    { name: 'status',       type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'cliente_nome', type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'destinatario', type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'note',         type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'telefono',     type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'email',        type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'created_at',   type: NSDateAttributeType,    default: nil,  optional: true, transient: false, indexed: false},
    { name: 'updated_at',   type: NSDateAttributeType,    default: nil,  optional: true, transient: false, indexed: false},
    { name: 'totale_copie', type: NSInteger32AttributeType, default: 0,   optional: true, transient: false, indexed: false},
    { name: 'totale_importo', type: NSDecimalAttributeType, default: 0.0, optional: true, transient: false, indexed: false},
    { name: 'data',           type: NSStringAttributeType,  default: nil, optional: true, transient: true,  indexed: false},
    { name: 'note_e_righe',   type: NSStringAttributeType,  default: nil, optional: true, transient: true,  indexed: false},
    { name: 'uuid',           type: NSStringAttributeType,  default: nil,  optional: true, transient: false, indexed: false}
  ]

  @relationships = [
    { name: 'cliente', destination: 'Cliente', inverse: 'appunti' },
    { name: 'righe',   destination: 'Riga', inverse: 'appunto', json: 'righe', optional: true, transient: false, indexed: false, ordered: true, min: 0, max: NSIntegerMax, del: NSCascadeDeleteRule }
  ]

  @sections = [
    [nil, ['Destinatario', 'destinatario', :text, 'Stato', 'status', :text]],
    ['Note', ['Note', 'note', :longtext]]
  ]


  def self.load

    super
    puts "load"
    
    NSNotificationCenter.defaultCenter.addObserver(self.class,
                                              selector:"objectContextWillSave:",
                                                    name: NSManagedObjectContextWillSaveNotification,
                                                  object: nil)

  end

  def self.objectContextWillSave(notification)


   context = notification.object

   puts context
   # allModified = context.insertedObjects.setByAddingObjectsFromSet(context.updatedObjects)
   # predicate = NSPredicate.predicateWithFormat("self isKindOfClass: %@", self.class)
   # modifiable = allModified.filteredSetUsingPredicate(predicate)
   # modifiable.makeObjectsPerformSelector("setLastModified:", withObject: NSDate.date)
 end



  def data        
    #  "#{(self.created_at.year * 10000) + (self.created_at.month * 100) + self.created_at.day}"
  end

  def note_e_righe
    note_e_righe = ""
    unless self.note.nil? || self.note == ""
      note_e_righe += self.note + "\r\n\r\n"
    end 
    self.righe.each do |r|
      note_e_righe += "#{r.quantita} - #{r.titolo}\r\n"
    end
    note_e_righe    
  end

  # #pragma mark -
  # #pragma mark Time stamp setter

  # def created_at=(newDate)
      
  #   self.willChangeValueForKey("created_at")
  #   @primitiveCreatedAt = newDate
  #   self.didChangeValueForKey("created_at")
    
  #   @primitiveData = nil
  # end


  # #pragma mark -
  # #pragma mark Key path dependencies

  # def self.keyPathsForValuesAffectingSectionIdentifier
  #   NSSet.setWithObject("created_at")
  # end

  def remove

    # qui isNew? o isInserted mi da sempre false quando cancello un nuovo inserimento
    # uso lo 0 nell id ma non so
    unless self.remote_id == 0

      if self.status == "da_fare"
        self.cliente.appunti_da_fare -= 1
      elsif self.status == "in_sospeso"
        self.cliente.appunti_in_sospeso -= 1
      end

      remove_from_backend do |result|
        if result.success?
          Store.shared.context.deleteObject(self)
          Store.shared.save
          Store.shared.persist
        else
          puts "error"
        end
      end
    else
      Store.shared.context.deleteObject(self)
      Store.shared.save
      Store.shared.persist
    end
  end

  def isNew? 
    vals = self.committedValuesForKeys(nil)
    return vals.count == 0
  end

  def self.filtra_status(status)
  
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:Store.shared.context)

    predicates = []
    predicates.addObject(NSPredicate.predicateWithFormat("status contains[cd] %@", argumentArray:[status]))
    request.predicate = NSCompoundPredicate.orPredicateWithSubpredicates(predicates)

    request.sortDescriptors = ["updated_at"].collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:false)
    }

    error_ptr = Pointer.new(:object)
    data = Store.shared.context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end



  # FILTRI

  def self.nel_baule
    
    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)

    pred = nil
    predicates = [] 
    predicates.addObject(NSPredicate.predicateWithFormat("cliente.nel_baule = 1"))
    predicates.addObject(NSPredicate.predicateWithFormat("status != 'completato'"))
    pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    request.predicate = pred

    request.sortDescriptors = ["cliente.provincia", "cliente.comune", "cliente.nome"].collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
    }
    
    error_ptr = Pointer.new(:object)
    data = context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end

  def self.nel_baule_controller
    
    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)
    pred = nil
    predicates = [] 
    predicates.addObject(NSPredicate.predicateWithFormat("cliente.nel_baule = 1"))
    predicates.addObject(NSPredicate.predicateWithFormat("status != 'completato'"))
    pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    request.predicate = pred

    request.sortDescriptors = ["cliente.provincia", "cliente.comune", "cliente.nome"].collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
    }
        
    error_ptr = Pointer.new(:object)
    controller = NSFetchedResultsController.alloc.initWithFetchRequest(request, managedObjectContext:context, sectionNameKeyPath:@sectionKey, cacheName:nil)      
    unless controller.performFetch(error_ptr)
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    controller
  end

  def self.in_sospeso

    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)

    pred = nil
    predicates = [] 
    predicates.addObject(NSPredicate.predicateWithFormat("cliente.nel_baule != 1"))
    predicates.addObject(NSPredicate.predicateWithFormat("status = 'in_sospeso'"))
    pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    request.predicate = pred
    
    request.sortDescriptors = ["cliente.provincia", "cliente.comune", "cliente.nome"].collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
    }

    error_ptr = Pointer.new(:object)
    data = context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end

  def self.in_sospeso_controller

    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)

    pred = nil
    predicates = [] 
    predicates.addObject(NSPredicate.predicateWithFormat("cliente.nel_baule != 1"))
    predicates.addObject(NSPredicate.predicateWithFormat("status = 'in_sospeso'"))
    pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    request.predicate = pred

    request.sortDescriptors = ["cliente.provincia", "cliente.comune", "cliente.nome"].collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
    }

    error_ptr = Pointer.new(:object)
    controller = NSFetchedResultsController.alloc.initWithFetchRequest(request, managedObjectContext:context, sectionNameKeyPath:@sectionKey, cacheName:nil)      
    unless controller.performFetch(error_ptr)
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    
    controller
  end

  def self.da_fare

    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)

    pred = nil
    predicates = [] 
    predicates.addObject(NSPredicate.predicateWithFormat("cliente.nel_baule != 1"))
    predicates.addObject(NSPredicate.predicateWithFormat("status != 'in_sospeso' and status != 'completato'"))
    pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    request.predicate = pred
    
    request.sortDescriptors = ["cliente.provincia", "cliente.comune", "cliente.nome"].collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
    }

    error_ptr = Pointer.new(:object)
    data = context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end

  def self.da_fare_controller

    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)

    pred = nil
    predicates = [] 
    predicates.addObject(NSPredicate.predicateWithFormat("cliente.nel_baule != 1"))
    predicates.addObject(NSPredicate.predicateWithFormat("status != 'in_sospeso' and status != 'completato'"))
    pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    request.predicate = pred

    request.sortDescriptors = ["cliente.provincia", "cliente.comune", "cliente.nome"].collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
    }

    error_ptr = Pointer.new(:object)
    controller = NSFetchedResultsController.alloc.initWithFetchRequest(request, managedObjectContext:context, sectionNameKeyPath:@sectionKey, cacheName:nil)      
    unless controller.performFetch(error_ptr)
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    
    controller
  end


end
