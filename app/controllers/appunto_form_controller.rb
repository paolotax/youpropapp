class AppuntoFormController < UITableViewController

  attr_accessor :appunto, :cliente, 
                :presentedAsModal, :isNew, 
                :saveBlock


  def viewWillAppear(animated)
    super

    didChange = NSManagedObjectContextObjectsDidChangeNotification
    didChange.add_observer(self, "changes:", Store.shared.context)

    didSave = NSManagedObjectContextDidSaveNotification
    didSave.add_observer(self, "didSave:", Store.shared.context)

    if isNew? && !@appunto
      @appunto = Appunto.add do |a|
        a.uuid = BubbleWrap.create_uuid.downcase
        a.cliente = cliente
        a.ClienteId = cliente.ClienteId
        a.cliente_nome = cliente.nome
        a.destinatario = ""
        a.status = "da_fare"
        a.created_at = Time.now
      end
    end 
    view.reloadData

    if @appunto && @appunto.isUpdated
      @appunto.updated_at = Time.now
    end

    unless isNew?
      self.navigationItem.rightBarButtonItem = UIBarButtonItem.action {
        print_appunto
      }
    end

    if presentedAsModal?
      self.navigationItem.setLeftBarButtonItem(UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCancel, target:self, action:"cancel:"))
    end

  end


#pragma mark - Notifications


  def changes(sender)
    puts "---changes---"
    puts sender.userInfo
    puts Store.shared.stats
        
    self.navigationItem.setRightBarButtonItem(UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemDone, target:self, action:"save:"))
    self.navigationItem.setLeftBarButtonItem(UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCancel, target:self, action:"cancel:"))
  end


  def didSave(sender)
    puts "---didSave--- "
    sender.userInfo
    puts Store.shared.stats
  end


#pragma mark - Actions


  def cancel(sender)
  
    error = Pointer.new(:object)
    moc = @appunto.managedObjectContext

    if isNew?
      moc.deleteObject @appunto
    else
      moc.refreshObject @appunto, mergeChanges:false
    end

    if presentedAsModal?
      self.dismissViewControllerAnimated(true, completion:nil)
    end

  end
  

  def save(sender)

    if @appunto.isUpdated
      @appunto.updated_at = Time.now
    end
    
    Store.shared.save
    Store.shared.persist

    unless appunto.remote_id == 0
      self.appunto.save_to_backend {}
    end
    
    if presentedAsModal?
      
      self.dismissViewControllerAnimated(true, completion:nil)
      
      DataImporter.default.sync_appunti

      didChange = NSManagedObjectContextObjectsDidChangeNotification
      didChange.remove_observer(self, "changes:")
      didSave = NSManagedObjectContextDidSaveNotification
      didSave.remove_observer(self, "didSave:")
    end
    
  end


  def print_appunto

    data = { appunto_ids: ["#{@appunto.remote_id}"] }

    AFMotion::Client.shared.setDefaultHeader("Accept", value:"application/pdf")
    AFMotion::Client.shared.setDefaultHeader("Authorization", value: "Bearer #{Store.shared.token}")
    
    AFMotion::Client.shared.put("/api/v1/appunti/print_multiple", data) do |result|
      if result.success?
        
        resourceDocPath = NSString.alloc.initWithString(NSBundle.mainBundle.resourcePath.stringByDeletingLastPathComponent.stringByAppendingPathComponent("Documents"))
        filePath = resourceDocPath.stringByAppendingPathComponent("Sovrapacchi.pdf")
        result.object.writeToFile(filePath, atomically:true)
        url = NSURL.fileURLWithPath(filePath)
        if (url) 
          @documentInteractionController = UIDocumentInteractionController.interactionControllerWithURL(url)
          @documentInteractionController.setDelegate(self)
          @documentInteractionController.presentPreviewAnimated(true)
        end
      else

        App.alert("babbeo")
      end
    end
    Store.shared.login {} 
  end


#pragma mark - Document Interaction Controller Delegate Methods


  def documentInteractionControllerViewControllerForPreview(controller)
    self
  end


#pragma mark -  UITableViewDelegate

  
  def numberOfSectionsInTableView(tableView)
    5
  end


  def tableView(tableView, numberOfRowsInSection:section)
    if (section == 1)
      @appunto.righe.count > 0 ? @appunto.righe.count + 2 : 1
    elsif section == 0
       6
    else
      1
    end
  end


  def tableView(tableView, cellForRowAtIndexPath:indexPath)

    if indexPath.section == 0

      if indexPath.row == 2

        cellID = "noteCell"
        cell = self.tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleCustom, reuseIdentifier:cellID)
        field = cell.viewWithTag(1123)
        field.text = @appunto.note      
      
      else

        case indexPath.row
        when 0
          column = 'cliente_nome'
        when 1
          column = 'destinatario'
        when 3
          column = 'status'
        when 4
          column = 'email'
        when 5
          column = 'telefono'
        end

        cellID = "#{column}Cell"
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleRightDetail, reuseIdentifier:cellID)
        
        value = @appunto.valueForKey(column)
        if column == 'status'
          value = value.split("_").join(" ")
        end
        cell.detailTextLabel.text = value
      end

    elsif indexPath.section == 1

      if indexPath.row == 0
        cellID = "addRigaCell"
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellID)
        cell.textLabel.color = self.tableView.tintColor
      
      elsif indexPath.row == @appunto.righe.count + 1

        cellID = "totaliCellIb"
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= TotaliCellIb.alloc.initWithStyle(UITableViewCellStyleCustom, reuseIdentifier:cellID)
        cell.labelImporto.text = "totale importo € #{@appunto.calcola_importo}"
        cell.labelCopie.text = "totale copie #{@appunto.calcola_copie}"
      
      else
        cellID = "rigaCellIb"
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= RigaCellIb.alloc.initWithStyle(UITableViewCellStyleCustom, reuseIdentifier:cellID)
        #cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
        riga = @appunto.righe.objectAtIndex(indexPath.row - 1)
        cell.load_data riga
      end
    
    elsif indexPath.section == 2

      cellID = "scanBarcodeCell"
      cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellID)
      cell.textLabel.color = self.tableView.tintColor

    elsif indexPath.section == 3

      cellID = "addReminderCell"
      cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellID)
      cell.textLabel.color = self.tableView.tintColor

    elsif indexPath.section == 4

      cellID = "deleteCell"
      cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellID)

    end   
    cell
  end


  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    if indexPath.section == 0 && indexPath.row == 2
      97
    elsif indexPath.section == 1 && indexPath.row != 0
      50
    else
      44
    end
  end


  def tableView(tableView, canEditRowAtIndexPath:indexPath)
    if indexPath.section == 1 && indexPath.row > 0 && indexPath.row <= @appunto.righe.count 
      true
    else
      false
    end
  end


  def tableView(tableView, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    if indexPath.section == 1 && indexPath.row > 0
      riga = @appunto.righe.objectAtIndex(indexPath.row - 1)
      # devo per forza eliminare no _deleted
      #Store.shared.context.deleteObject(riga)
      riga.remove
      
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
      
    end
  end


  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    
    if indexPath.section == 4
      cell = tableView.cellForRowAtIndexPath(indexPath)
      @actionSheet = UIActionSheet.alloc.initWithTitle("Sei sicuro?",
                                              delegate:self,
                                          cancelButtonTitle:"Annulla",
                                          destructiveButtonTitle:"Elimina",
                                          otherButtonTitles:nil)

      @actionSheet.showFromRect(cell.frame, inView:self.view, animated:true)
      #appunto.remove
    
    elsif indexPath.section == 2
      cell = tableView.cellForRowAtIndexPath(indexPath)

      scanVC = ScanController.alloc.initWithAppunto(@appunto)
      self.presentModalViewController scanVC, animated:true
    end
  end


#pragma mark - ActionSheet delegate


  def actionSheet(actionSheet, didDismissWithButtonIndex:buttonIndex)
    if buttonIndex != @actionSheet.cancelButtonIndex

      cliente = @appunto.cliente
      
      @appunto.remove

      if presentedAsModal?
        self.dismissViewControllerAnimated(true, completion:nil)
      end

      #self.delegate playerDetailsViewController:self didDeletePlayer:self.playerToEdit
    end
    @actionSheet = nil
  end


#pragma mark - Segues
  

  def prepareForEditDestinatarioSegue(segue, sender:sender)
    editController = segue.destinationViewController
    editController.testo = @appunto.destinatario
    editController.setTextChangedBlock( lambda do |text, error|
        path = NSIndexPath.indexPathForRow(1, inSection:0)
        cell = self.tableView.cellForRowAtIndexPath(path)
        cell.detailTextLabel.setText(text)
        @appunto.destinatario = text
        return true
      end
    )
  end

 
  def prepareForEditNoteSegue(segue, sender:sender)
    editController = segue.destinationViewController
    editController.testo = @appunto.note
    editController.setTextChangedBlock( lambda do |text, error|
        path = NSIndexPath.indexPathForRow(2, inSection:0)
        cell = self.tableView.cellForRowAtIndexPath(path)
        temp = cell.viewWithTag(1123)
        temp.setText(text)
        @appunto.note = text
        return true
      end
    )
  end


  def prepareForEditEmailSegue(segue, sender:sender)
    editController = segue.destinationViewController
    editController.testo = @appunto.email
    editController.setTextChangedBlock( lambda do |text, error|
        path = NSIndexPath.indexPathForRow(4, inSection:0)
        cell = self.tableView.cellForRowAtIndexPath(path)
        cell.detailTextLabel.setText(text)
        @appunto.email = text
        return true
      end
    )
  end


  def prepareForEditTelefonoSegue(segue, sender:sender)
    editController = segue.destinationViewController
    editController.testo = @appunto.telefono
    editController.setTextChangedBlock( lambda do |text, error|
        path = NSIndexPath.indexPathForRow(5, inSection:0)
        cell = self.tableView.cellForRowAtIndexPath(path)
        cell.detailTextLabel.setText(text)
        @appunto.telefono = text
        return true
      end
    )
  end


  def prepareForEditStatoSegue(segue, sender:sender)
    statoController = segue.destinationViewController
    statoController.appunto = @appunto
    statoController.delegate = self
  end

  
  def editStatoController(controller, didSelectStato:stato)
    @appunto.status = stato
    self.navigationController.popViewControllerAnimated(true)
  end


  def prepareForAddRigaSegue(segue, sender:sender)
    segue.destinationViewController.appunto = @appunto
  end


  def prepareForEditRigaSegue(segue, sender:sender)
    indexPath = self.tableView.indexPathForCell(sender)
    @riga = @appunto.righe.objectAtIndex(indexPath.row - 1)
    if @riga.remote_appunto_id != @appunto.remote_id 
      @riga.remote_appunto_id = @appunto.remote_id 
    end
    segue.destinationViewController.riga = @riga
    segue.destinationViewController.appunto = @appunto
  end


  def prepareForAddReminderSegue(segue, sender:sender)
    editController = segue.destinationViewController
    editController.appunto = @appunto
    editController.setReminderChangedBlock( lambda do |text, date, error|
        path = NSIndexPath.indexPathForRow(0, inSection:2)
        cell = self.tableView.cellForRowAtIndexPath(path)
        main_queue = Dispatch::Queue.main
        main_queue.async do
          cell.textLabel.setText(text)
        end
        return true
      end
    )
  end


  def prepareForSegue(segue, sender:sender)
    if segue.identifier.isEqualToString("editDestinatario") 
      self.prepareForEditDestinatarioSegue(segue, sender:sender)
    
    elsif segue.identifier.isEqualToString("editNote") 
      self.prepareForEditNoteSegue(segue, sender:sender)
    
    elsif segue.identifier.isEqualToString("editStato") 
      self.prepareForEditStatoSegue(segue, sender:sender)
    
    elsif segue.identifier.isEqualToString("editTelefono") 
      self.prepareForEditTelefonoSegue(segue, sender:sender)
    
    elsif segue.identifier.isEqualToString("editEmail") 
      self.prepareForEditEmailSegue(segue, sender:sender)  
        
    elsif segue.identifier.isEqualToString("editRiga") 
      self.prepareForEditRigaSegue(segue, sender:sender)
    
    elsif segue.identifier.isEqualToString("addReminder") 
      self.prepareForAddReminderSegue(segue, sender:sender)
    
    elsif segue.identifier.isEqualToString("addRiga") 
      self.prepareForAddRigaSegue(segue, sender:sender)
    end
  end


  private


    def presentedAsModal?
      presentedAsModal == true
    end


    def isNew?
      isNew == true
    end


end