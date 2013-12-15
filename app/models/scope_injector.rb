class ScopeInjector


  def self.addProvinciaScope(provincia, toFetchRequest:request)

    if provincia != "tutte"

      if request.entity.name == "Cliente"
        column = "provincia"
      else
        column = "cliente.provincia"
      end
      old_predicate = request.predicate
      predicates = []
      predicates.addObject(NSPredicate.predicateWithFormat("#{column} = '#{provincia}'"))
      temp_predicate = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
      if old_predicate 
        pred = NSCompoundPredicate.andPredicateWithSubpredicates([old_predicate, temp_predicate])
        request.predicate = pred
      else
        request.predicate = temp_predicate
      end
    end
    request
  end


  def self.setScopeWithName(name, toFetchRequest:request)

    pred = request.predicate
    predicates = []

    if name == "tutti"

      request.sortDescriptors = ["provincia", "comune", "nome"].collect { |sortKey|
        NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
      }

    elsif name == "nel_baule"

      predicates.addObject(NSPredicate.predicateWithFormat("nel_baule = 1"))
      pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
      request.predicate = pred

      request.sortDescriptors = ["provincia", "comune", "nome"].collect { |sortKey|
        NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
      }
    
    elsif name == "in_sospeso"

      predicates.addObject(NSPredicate.predicateWithFormat("nel_baule != 1"))
      predicates.addObject(NSPredicate.predicateWithFormat("appunti_da_fare = null"))
      predicates.addObject(NSPredicate.predicateWithFormat("appunti_in_sospeso > 0"))
      pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
      request.predicate = pred

      request.sortDescriptors = ["provincia", "comune", "nome"].collect { |sortKey|
        NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
      }

    elsif name == "da_fare"

      predicates.addObject(NSPredicate.predicateWithFormat("nel_baule != 1"))
      predicates.addObject(NSPredicate.predicateWithFormat("appunti_da_fare > 0"))
      pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
      request.predicate = pred

      request.sortDescriptors = ["provincia", "comune", "nome"].collect { |sortKey|
        NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
      }

    elsif name == "appunti_tutti"

      request.sortDescriptors = ["updated_at"].collect { |sortKey|
        NSSortDescriptor.alloc.initWithKey(sortKey, ascending:false)
      }
 
    elsif name == "appunti_nel_baule"

      predicates.addObject(NSPredicate.predicateWithFormat("cliente.nel_baule = 1"))
      predicates.addObject(NSPredicate.predicateWithFormat("status != 'completato'"))
      pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
      request.predicate = pred

      request.sortDescriptors = ["cliente.provincia", "cliente.comune", "cliente.nome"].collect { |sortKey|
        NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
      }

    elsif name == "appunti_in_sospeso"

      predicates.addObject(NSPredicate.predicateWithFormat("cliente.nel_baule != 1"))
      predicates.addObject(NSPredicate.predicateWithFormat("status = 'in_sospeso'"))
      pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
      request.predicate = pred
      
      request.sortDescriptors = ["cliente.provincia", "cliente.comune", "cliente.nome"].collect { |sortKey|
        NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
      }

    elsif name == "appunti_da_fare"

      predicates.addObject(NSPredicate.predicateWithFormat("cliente.nel_baule != 1"))
      predicates.addObject(NSPredicate.predicateWithFormat("status != 'in_sospeso' and status != 'completato'"))
      pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
      request.predicate = pred

      request.sortDescriptors = ["cliente.provincia", "cliente.comune", "cliente.nome"].collect { |sortKey|
        NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
      }

    end
    request
    
  end




end