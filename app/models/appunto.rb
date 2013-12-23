class Appunto < NSManagedObject


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


  def calcola_importo
    importi = [0]
    self.righe.each do |r|
      importi << r.importo.round(2)
    end    
    importi.reduce(:+).round(2)
  end


  def calcola_copie
    copie = [0]
    self.righe.each do |r|
      copie << r.quantita
    end    
    copie.reduce(:+)
  end


  def remove(&callback)
    puts "willRemove"
    if remote_id != 0
      remove_from_backend do |result|
        if result.success?
          Store.shared.context.deleteObject(self)
          Store.shared.save
          Store.shared.persist
          callback.call
        else
          App.alert("Inpossibile eliminare l'appunto. Riprova più tardi")
        end
      end
    else
      Store.shared.context.deleteObject(self)
      Store.shared.save
      Store.shared.persist
      callback.call
    end
  end


  # FILTRI


  ["tutti", "nel_baule", "da_fare", "in_sospeso"].each do |scope|

    define_singleton_method("#{scope}") do
  
      context = Store.shared.context
      request = NSFetchRequest.alloc.init
      request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)

      request = ScopeInjector.setScopeWithName("appunti_#{scope}", toFetchRequest:request)
      
      error_ptr = Pointer.new(:object)
      data = context.executeFetchRequest(request, error:error_ptr)
      if data == nil
        raise "Error when fetching data: #{error_ptr[0].description}"
      end
      data
    end

    define_singleton_method("#{scope}_controller") do |provincia|
  
      context = Store.shared.context
      request = NSFetchRequest.alloc.init
      request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)

      request = ScopeInjector.setScopeWithName("appunti_#{scope}", toFetchRequest:request)
      if provincia
        request = ScopeInjector.addProvinciaScope(provincia, toFetchRequest:request)
      end   

      error_ptr = Pointer.new(:object)
      controller = NSFetchedResultsController.alloc.initWithFetchRequest(request, managedObjectContext:context, sectionNameKeyPath:@sectionKey, cacheName:nil)      
      unless controller.performFetch(error_ptr)
        raise "Error when fetching data: #{error_ptr[0].description}"
      end
      
      controller
    end
  end

end
