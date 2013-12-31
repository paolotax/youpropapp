class Libro < NSManagedObject
  
  @sortKeys = ['settore', 'titolo']
  @sortOrders = [true, true]
  @sectionKey = 'settore'
  @searchKey  = ['titolo', 'settore']

  @attributes = [
    { name: 'remote_id', type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'titolo',  type: NSStringAttributeType,    default: '', optional: true, transient: false, indexed: false},
    { name: 'sigla',   type: NSStringAttributeType,    default: '', optional: true, transient: false, indexed: false},

    { name: 'ean', type: NSStringAttributeType,    default: nil, optional: true, transient: false, indexed: false},
    { name: 'cm', type: NSStringAttributeType,    default: nil, optional: true, transient: false, indexed: false},

    { name: 'settore', type: NSStringAttributeType,    default: '', optional: true, transient: false, indexed: false},
    { name: 'image_url', type: NSStringAttributeType,    default: '', optional: true, transient: false, indexed: false},
    { name: 'prezzo_copertina',   type: NSDecimalAttributeType, default: 0.0, optional: true, transient: false, indexed: false},
    { name: 'prezzo_consigliato', type: NSDecimalAttributeType, default: 0.0, optional: true, transient: false, indexed: false},

    { name: 'created_at',   type: NSDateAttributeType,      default: nil, optional: true, transient: false, indexed: false},
    { name: 'updated_at',   type: NSDateAttributeType,      default: nil, optional: true, transient: false, indexed: false},
    { name: 'deleted_at',   type: NSDateAttributeType,      default: nil, optional: true, transient: false, indexed: false}
  ]

  @relationships = [
    { name: 'libro_righe', destination: 'Riga', inverse: 'libro', json: 'righe', optional: true, transient: false, indexed: false, ordered: true, min: 0, max: NSIntegerMax, del: NSCascadeDeleteRule },
    { name: 'libro_adozioni', destination: 'Adozione', inverse: 'libro', json: 'adozioni', optional: true, transient: false, indexed: false, ordered: true, min: 0, max: NSIntegerMax, del: NSCascadeDeleteRule }
  ]


  def self.find_by_barcode(barcode)
    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)

    pred = nil
    predicates = [] 
    predicates.addObject(NSPredicate.predicateWithFormat("ean == '#{barcode}'"))
    pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    request.predicate = pred
    
    error_ptr = Pointer.new(:object)
    libro = context.executeFetchRequest(request, error:error_ptr)
    if libro == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    libro
  end

  def self.create_from_google_book(google_book)
    libro = Libro.add do |l|
      l.titolo = google_book.title
      l.settore = "Eventuale"
      l.ean = google_book.isbn
      l.image_url = google_book.image
    end
    libro
  end 



  # def addPlayersObject(value)
  #   # override default core-data generated accessor, faulty in iOS5.1
  #   # see http://stackoverflow.com/questions/7385439/problems-with-nsorderedset
  #   tempSet = NSMutableOrderedSet.orderedSetWithOrderedSet(self.players)
  #   tempSet.addObject(value)
  #   self.players = tempSet
  # end  



end