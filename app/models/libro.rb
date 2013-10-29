class Libro < NSManagedObject
  
  @sortKeys = ['settore', 'titolo']
  @sortOrders = [true, true]
  @sectionKey = 'settore'
  @searchKey  = ['titolo', 'settore']

  @attributes = [
    { name: 'LibroId', type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'titolo',  type: NSStringAttributeType,    default: '', optional: true, transient: false, indexed: false},
    { name: 'sigla',   type: NSStringAttributeType,    default: '', optional: true, transient: false, indexed: false},
    { name: 'settore', type: NSStringAttributeType,    default: '', optional: true, transient: false, indexed: false},
    { name: 'image_url', type: NSStringAttributeType,    default: '', optional: true, transient: false, indexed: false},
    { name: 'prezzo_copertina',   type: NSDecimalAttributeType, default: 0.0, optional: true, transient: false, indexed: false},
    { name: 'prezzo_consigliato', type: NSDecimalAttributeType, default: 0.0, optional: true, transient: false, indexed: false}
  ]

  @relationships = [
    { name: 'libro_righe', destination: 'Riga', inverse: 'libro', json: 'righe', optional: true, transient: false, indexed: false, ordered: true, min: 0, max: NSIntegerMax, del: NSCascadeDeleteRule },
    { name: 'libro_adozioni', destination: 'Adozione', inverse: 'libro', json: 'adozioni', optional: true, transient: false, indexed: false, ordered: true, min: 0, max: NSIntegerMax, del: NSCascadeDeleteRule }
  ]

  # def addPlayersObject(value)
  #   # override default core-data generated accessor, faulty in iOS5.1
  #   # see http://stackoverflow.com/questions/7385439/problems-with-nsorderedset
  #   tempSet = NSMutableOrderedSet.orderedSetWithOrderedSet(self.players)
  #   tempSet.addObject(value)
  #   self.players = tempSet
  # end  


  # def self.entity
  #   @entity ||= begin
  #     entity = NSEntityDescription.alloc.init
  #     entity.name = 'Libro'
  #     entity.managedObjectClassName = 'Libro'
  #     entity.properties = 
  #       ['LibroId',      NSInteger32AttributeType, true,
  #        'titolo',  NSStringAttributeType, true,
  #        'settore', NSStringAttributeType, true,
  #        'prezzo_copertina', NSDecimalAttributeType, true,
  #        'prezzo_consigliato', NSDecimalAttributeType, true].each_slice(3).map do |name, type, optional|
  #           property = NSAttributeDescription.alloc.init
  #           property.name = name
  #           property.attributeType = type
  #           property.optional = optional
  #           property
  #         end
  #     entity
  #   end
  # end


end