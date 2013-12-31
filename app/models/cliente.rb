class Cliente < NSManagedObject
  
  attr_accessor :cliente
  
  @sortKeys   = ['provincia', 'comune', 'nome']
  @sortOrders = [true, true, true]

  @sectionKey = "provincia_e_comune"
  @searchKey  = ['nome', 'comune', 'frazione']

  @attributes = [
    { name: 'remote_id', type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'nome',      type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'comune',    type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'frazione',  type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'cliente_tipo', type: NSStringAttributeType, default: '',  optional: true, transient: false, indexed: false},
    { name: 'indirizzo', type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'cap',       type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'provincia', type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'telefono',  type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'email',     type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'latitude',  type: NSDoubleAttributeType,   default: 0.0, optional: true, transient: false, indexed: false},
    { name: 'longitude', type: NSDoubleAttributeType,   default: 0.0, optional: true, transient: false, indexed: false},
    { name: 'ragione_sociale',  type: NSStringAttributeType, default: '', optional: true, transient: false, indexed: false},
    { name: 'codice_fiscale',   type: NSStringAttributeType, default: '', optional: true, transient: false, indexed: false},
    { name: 'partita_iva',      type: NSStringAttributeType, default: '', optional: true, transient: false, indexed: false},
    { name: 'appunti_da_fare',    type: NSInteger16AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'appunti_in_sospeso', type: NSInteger16AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'nel_baule',          type: NSBooleanAttributeType, default: 0, optional: true, transient: false, indexed: false},
    { name: 'fatto',              type: NSBooleanAttributeType, default: 0, optional: true, transient: false, indexed: false},
    { name: 'provincia_e_comune', type: NSStringAttributeType,  default: nil, optional: true, transient: true,  indexed: false},
    { name: 'uuid',              type: NSStringAttributeType,    default: nil,  optional: true, transient: false, indexed: false},
    { name: 'created_at',   type: NSDateAttributeType,      default: nil, optional: true, transient: false, indexed: false},
    { name: 'updated_at',   type: NSDateAttributeType,      default: nil, optional: true, transient: false, indexed: false},
    { name: 'deleted_at',   type: NSDateAttributeType,      default: nil, optional: true, transient: false, indexed: false} 
  ]

  @relationships = [
    { name: 'appunti', destination: 'Appunto', inverse: 'cliente', json: 'appunti', optional: true, transient: false, indexed: false, ordered: true, min: 0, max: NSIntegerMax, del: NSCascadeDeleteRule },
    { name: 'classi', destination: 'Classe', inverse: 'cliente', json: 'classi', optional: true, transient: false, indexed: false, ordered: true, min: 0, max: NSIntegerMax, del: NSCascadeDeleteRule }
  ]

  def provincia_e_comune
    #self.willAccessValueForKey("provincia_e_comune")
    tmp = "#{self.provincia} #{self.comune} - #{self.nome}"
    #self.didAccessValueForKey("provincia_e_comune")
    tmp
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

  def whichGroup
    if nel_baule && nel_baule == 1
      return 0
    elsif appunti_da_fare && appunti_da_fare > 0
      return 1
    elsif appunti_in_sospeso && appunti_in_sospeso > 0
      return 2
    else
      return 3
    end
  end


  def citta
    (self.frazione.nil? || self.frazione == "") ? self.comune : self.frazione
  end

  def title
    nome
  end

  def coordinate
    CLLocationCoordinate2D.new(latitude, longitude)
  end

  # def addAppuntiObject(value)
  #   # override default core-data generated accessor, faulty in iOS5.1
  #   # see http://stackoverflow.com/questions/7385439/problems-with-nsorderedset
  #   tempSet = NSMutableOrderedSet.orderedSetWithOrderedSet(self.appunti)
  #   tempSet.addObject(value)
  #   self.appunti = tempSet
  # end  

  def mapItem
    
    # addressDict = {
    #   kABPersonAddressCountryKey: "IT",
    #   kABPersonAddressCityKey: "#{frazione} #{comune}",
    #   kABPersonAddressStreetKey: "#{indirizzo}",
    #   kABPersonAddressZIPKey: "#{cap}"
    # }

    placemark = MKPlacemark.alloc.initWithCoordinate(self.coordinate, addressDictionary:nil)
    mapItem = MKMapItem.alloc.initWithPlacemark(placemark)
    mapItem.name = self.title
    mapItem.phoneNumber = "#{telefono}";
    mapItem.url = NSURL.URLWithString("http://youpropa.com/clienti/#{self.ClienteId}")
    mapItem
  end


  ["tutti", "nel_baule", "da_fare", "in_sospeso"].each do |scope|

    # define_singleton_method("#{scope}") do
  
    #   context = Store.shared.context
    #   request = NSFetchRequest.alloc.init
    #   request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)

    #   request = ScopeInjector.setScopeWithName(scope, toFetchRequest:request)
      
    #   error_ptr = Pointer.new(:object)
    #   data = context.executeFetchRequest(request, error:error_ptr)
    #   if data == nil
    #     raise "Error when fetching data: #{error_ptr[0].description}"
    #   end
    #   data
    # end

    define_singleton_method("#{scope}_controller") do |provincia|
  
      context = Store.shared.context
      request = NSFetchRequest.alloc.init
      request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)

      request = ScopeInjector.setScopeWithName(scope, toFetchRequest:request)
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


  def nel_baule?
    nel_baule == 1
  end
end