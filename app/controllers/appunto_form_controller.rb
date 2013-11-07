class AppuntoFormController < UITableViewController

  attr_accessor :appunto, :cliente, 
                :presentedAsModal, :isNew, 
                :presentedInPopover, :presentedInDetailView, :saveBlock



  def viewDidLoad
    super
    # funzia

  end

  def viewWillAppear(animated)
    super

    puts "0. willAppear"
    puts Store.shared.stats

    didChange = NSManagedObjectContextObjectsDidChangeNotification
    didChange.add_observer(self, "changes:", Store.shared.context)

    # didChange = NSManagedObjectContextObjectsDidChangeNotification
    # center = NSNotificationCenter.defaultCenter
    # center.addObserver(self, 
    #           selector:"changes:",
    #               name:didChange, 
    #             object:Store.shared.context)


    if isNew? && !@appunto
      @appunto = Appunto.add do |a|
        a.cliente = cliente
        a.ClienteId = cliente.ClienteId
        a.cliente_nome = cliente.nome
        a.destinatario = ""
        a.status = "da_fare"
        a.created_at = Time.now
      end

      puts "is inserted = #{@appunto.isInserted}"
    end 
    view.reloadData
    puts "is inserted reloaded = #{@appunto.isInserted}"

    if @appunto && @appunto.isUpdated
      @appunto.updated_at = Time.now
      puts "0. updated time"
      puts Store.shared.stats
    end
    # didSave = NSManagedObjectContextDidSaveNotification
    # center.addObserver(self, 
    #           selector:"didSave:",
    #               name:didSave,
    #             object:Store.shared.context)

    unless isNew?
      self.navigationItem.rightBarButtonItem = UIBarButtonItem.action {
        print_appunto
        # url = NSURL.URLWithString("http://youpropa.com/appunti/#{@appunto.remote_id}.pdf")
        # UIApplication.sharedApplication.openURL(url)

      }
    end

    if presentedAsModal?
      self.navigationItem.setLeftBarButtonItem(UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCancel, target:self, action:"cancel:"))
    end

    if presentedInDetailView?
      self.navigationItem.leftBarButtonItem = UIBarButtonItem.imaged("38-house".uiimage) {
        "pushClienteController".post_notification(self, cliente: @appunto.cliente)
      }
    end
  end


  def viewDidAppear(animated)
    self.contentSizeForViewInPopover = self.tableView.contentSize
  end


  def changes(sender)
    puts "---changes---"
    puts sender.userInfo
    puts Store.shared.stats
    
    if presentedInPopover?
      "unallow_dismiss_popover".post_notification
    end
    
    self.navigationItem.setRightBarButtonItem(UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemDone, target:self, action:"save:"))
    self.navigationItem.setLeftBarButtonItem(UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCancel, target:self, action:"cancel:"))
  end

  def didSave(sender)
    puts "---didSave---"
    puts Store.shared.stats
  end

  def viewWillDisappear(sender)
    super
    puts "---viewWillDisappear---"
    puts Store.shared.stats
  end




# save

  def save2(sender)
  
    error = Pointer.new(:object)
    moc = @appunto.managedObjectContext
    unless moc.save(error)
      raise "Error when saving the model: #{error_ptr[0].description}"
    end

    if presentedAsModal?
      self.dismissViewControllerAnimated(true, completion:nil)
    end
    
    if presentedInPopover?
      "allow_dismiss_popover".post_notification
      self.navigationController.popViewControllerAnimated(true)
    end

    if presentedInDetailView?
      self.navigationItem.title = "ce l'ho"
      self.navigationItem.leftBarButtonItem = UIBarButtonItem.imaged("38-house".uiimage) {
        "pushClienteController".post_notification(self, cliente: @appunto.cliente)
      }
      self.navigationItem.rightBarButtonItem = UIBarButtonItem.action {
        print_appunto
        # url = NSURL.URLWithString("http://youpropa.com/appunti/#{@appunto.remote_id}.pdf")
        # UIApplication.sharedApplication.openURL(url)
      }
    end
  end

  def cancel2(sender)
  
    error = Pointer.new(:object)
    moc = @appunto.managedObjectContext

    if (@appunto.isInserted)
      moc.deleteObject @appunto 
    else
      moc.refreshObject @appunto, mergeChanges:false
    end

    # if isNew?
    #   @appunto.remove
    # else
    #   Store.shared.context.rollback
    # end

    if presentedAsModal?
      self.dismissViewControllerAnimated(true, completion:nil)
    end

    if presentedInPopover?
      "allow_dismiss_popover".post_notification
      self.navigationController.popViewControllerAnimated(true)
    end

    if presentedInDetailView?
      self.navigationItem.leftBarButtonItem = UIBarButtonItem.imaged("38-house".uiimage) {
        "pushClienteController".post_notification(self, cliente: @appunto.cliente)
      }
      self.navigationItem.rightBarButtonItem = UIBarButtonItem.action {

        print_appunto
        # url = NSURL.URLWithString("http://youpropa.com/appunti/#{@appunto.remote_id}.pdf")
        # UIApplication.sharedApplication.openURL(url)
      }
    end
  end
  
  def save(sender)

    didChange = NSManagedObjectContextObjectsDidChangeNotification
    center = NSNotificationCenter.defaultCenter
    center.removeObserver(self, 
                     name:didChange, 
                   object:Store.shared.context)

    # didSave = NSManagedObjectContextDidSaveNotification
    # center.removeObserver(self, 
    #               name:didSave,
    #             object:Store.shared.context)

    puts "---removed NSManagedObjectContextObjectsDidChangeNotification---"
    # puts "---removed NSManagedObjectContextDidSaveNotification---"
    if @appunto.uuid.nil? || @appunto.uuid == ""
      @appunto.uuid = BubbleWrap.create_uuid.downcase
    end

    if @appunto.isUpdated
      @appunto.updated_at = Time.now
      puts "0. updated time"
      puts Store.shared.stats
    end
    

    Store.shared.save
    puts "1. save"
    puts Store.shared.stats

    Store.shared.persist
    puts "2. persist"
    puts Store.shared.stats
    
    self.appunto.save_to_backend do
      puts "savedToBackend"
      self.tableView.reloadData
    end  
    puts "3. backend"
    puts Store.shared.stats
    
    # "appuntiListDidLoadBackend".post_notification
    # "reload_appunti_collections".post_notification
    # "allow_dismiss_popover".post_notification

    if presentedAsModal?
      puts "4. presentedAsModal"  
      puts Store.shared.stats
      self.dismissViewControllerAnimated(true, completion:nil)
    end
    
    if presentedInPopover?
      puts "4. presentedInPopover"  
      puts Store.shared.stats
      "allow_dismiss_popover".post_notification
      self.navigationController.popViewControllerAnimated(true)
    end

    if presentedInDetailView?
      puts "4. presentedInDetailView"
      puts Store.shared.stats
      puts "ce l'ho"
      self.navigationItem.title = "ce l'ho"
      self.navigationItem.leftBarButtonItem = UIBarButtonItem.imaged("38-house".uiimage) {
        "pushClienteController".post_notification(self, cliente: @appunto.cliente)
      }
      self.navigationItem.rightBarButtonItem = UIBarButtonItem.action {

        print_appunto
        # url = NSURL.URLWithString("http://youpropa.com/appunti/#{@appunto.remote_id}.pdf")
        # UIApplication.sharedApplication.openURL(url)
      }
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



  def cancel(sender)

    

    puts "---removed NSManagedObjectContextObjectsDidChangeNotification---"
    # puts "---removed NSManagedObjectContextDidSaveNotification---"

    if isNew?
      puts "1. isNew = true"
      puts Store.shared.stats
      @appunto.remove
      puts "2. remove"
      puts Store.shared.stats
    else
      puts "1. update"
      puts Store.shared.stats
      Store.shared.context.rollback
      puts "2. rollback"
      puts Store.shared.stats
    end

    if presentedAsModal?
      puts "3. closemodal"
      puts Store.shared.stats
      self.dismissViewControllerAnimated(true, completion:nil)
    end

    if presentedInPopover?
      puts "3. pop navigation"
      puts Store.shared.stats
      "allow_dismiss_popover".post_notification
      self.navigationController.popViewControllerAnimated(true)
    end

    if presentedInDetailView?
      puts "3. reset detail view"
      puts Store.shared.stats
      # Cliente.reset
      # Appunto.reset
      # self.navigationItem.title = "ce l'ho"
      self.navigationItem.leftBarButtonItem = UIBarButtonItem.imaged("38-house".uiimage) {
        "pushClienteController".post_notification(self, cliente: @appunto.cliente)
      }
      self.navigationItem.rightBarButtonItem = UIBarButtonItem.action {
        url = NSURL.URLWithString("http://youpropa.com/appunti/#{@appunto.remote_id}.pdf")
        UIApplication.sharedApplication.openURL(url)
      }
    end

    didChange = NSManagedObjectContextObjectsDidChangeNotification
    center = NSNotificationCenter.defaultCenter
    center.removeObserver(self, 
                     name:didChange, 
                   object:Store.shared.context)

    # didSave = NSManagedObjectContextDidSaveNotification
    # center.removeObserver(self, 
    #               name:didSave,
    #             object:Store.shared.context)

  end 







  #pragma mark -
  #pragma mark Document Interaction Controller Delegate Methods
  def documentInteractionControllerViewControllerForPreview(controller)
    self
  end





  # UITableViewDelegate

  def numberOfSectionsInTableView(tableView)
    4
  end

  def tableView(tableView, numberOfRowsInSection:section)
    if (section == 1)
       @appunto.righe.count + 1
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
      else
        cellID = "rigaCell"
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= RigaTableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellID)
        cell.riga = @appunto.righe.objectAtIndex(indexPath.row - 1)
      end
    
    elsif indexPath.section == 2

      cellID = "addReminderCell"
      cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleCustom, reuseIdentifier:cellID)
    
    elsif indexPath.section == 3

      cellID = "deleteCell"
      cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
      cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleCustom, reuseIdentifier:cellID)
    
    end   
    cell
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    if indexPath.section == 0 && indexPath.row == 2
      97
    else
      44
    end
  end

  def tableView(tableView, canEditRowAtIndexPath:indexPath)
    if indexPath.section == 1 && indexPath.row > 0
      true
    else
      false
    end
  end

  def tableView(tableView, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    if indexPath.section == 1 && indexPath.row > 0
      riga = @appunto.righe.objectAtIndex(indexPath.row - 1)
      # devo per forza eliminare no _deleted
      riga.remove
      tableView.updates do
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
      end
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    
    if indexPath.section == 3
      cell = tableView.cellForRowAtIndexPath(indexPath)
      @actionSheet = UIActionSheet.alloc.initWithTitle("Sei sicuro?",
                                              delegate:self,
                                          cancelButtonTitle:"Annulla",
                                          destructiveButtonTitle:"Elimina",
                                          otherButtonTitles:nil)

      @actionSheet.showFromRect(cell.frame, inView:self.view, animated:true)
      #appunto.remove
    end

  end


  def actionSheet(actionSheet, didDismissWithButtonIndex:buttonIndex)
    if buttonIndex != @actionSheet.cancelButtonIndex

      cliente = @appunto.cliente
      
      #@appunto.delete_from_backend
      
      @appunto.remove

      if presentedAsModal?
        self.dismissViewControllerAnimated(true, completion:nil)
      end

      if presentedInPopover?
        "allow_dismiss_popover".post_notification
        self.navigationController.popViewControllerAnimated(true)
      end

      if presentedInDetailView?
        "pushClienteController".post_notification(self, cliente: cliente)
      end

      #self.delegate playerDetailsViewController:self didDeletePlayer:self.playerToEdit
    end
    @actionSheet = nil
  end


  # segues
  
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
  
  # editStatoController delegate
  def editStatoController(controller, didSelectStato:stato)
    @appunto.status = stato
    self.navigationController.popViewControllerAnimated(true)
  end

  def prepareForAddRigaSegue(segue, sender:sender)
    segue.destinationViewController.appunto = @appunto
  end

  def prepareForEditRigaSegue(segue, sender:sender)
    indexPath = self.tableView.indexPathForCell(sender)
    @riga = self.tableView.cellForRowAtIndexPath(indexPath).riga
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

    def presentedInPopover?
      presentedInPopover == true
    end
    
    def presentedInDetailView?
      presentedInDetailView == true
    end

end