class LibroFormController < UITableViewController


  attr_accessor :libro, :isNew


  def viewDidLoad
    super
  end


  def viewWillAppear(animated)
    super
    self.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel do |button|
      cancel(button) 
    end
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.save do |button|
      save(button)
    end
  end


  def load_data(libro)
    @libro = libro
    self.tableView.reloadData
  end


#pragma mark -  Actions
  
  
  def save(sender)
    Store.shared.save
    Store.shared.persist
    @libro.save_to_backend do |result|
      if result.success?
        puts libro.remote_id
      else
        puts "error"
      end
    end

    if isNew?
      self.dismissViewControllerAnimated true, completion:nil
    else
      self.navigationController.popViewControllerAnimated true
    end
  end


  def cancel(sender)
    error = Pointer.new(:object)
    context = @libro.managedObjectContext
    if isNew?
      context.deleteObject @libro
      self.dismissViewControllerAnimated true, completion:nil
    else
      context.refreshObject @libro, mergeChanges:false
      self.navigationController.popViewControllerAnimated true
    end
  end


#pragma mark -   editListController delegate
  

  def editListController(controller, didSelectItem:item)
    cell = self.tableView.cellForRowAtIndexPath([0, 1].nsindexpath)
    cell.detailTextLabel.text = item
    @libro.settore = item
    self.navigationController.popViewControllerAnimated(true)
  end


#pragma mark -  UITableViewDelegate


  def numberOfSectionsInTableView(tableView)
    if @libro
      2
    else
      0
    end
  end


  def tableView(tableView, numberOfRowsInSection:section)
    if @libro   
      if section == 0
        4
      else
        2
      end
    else
      0
    end
  end


  def tableView(tableView, cellForRowAtIndexPath:indexPath)

    if indexPath.section == 0

      if indexPath.row == 0

        cellID = "titoloCell"
        cell = self.tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellID)
        cell.textLabel.adjustsFontSizeToFitWidth =true
        cell.textLabel.minimumScaleFactor = 0.5
        cell.textLabel.text = "#{@libro.titolo}"
      
      elsif indexPath.row == 1

        cellID = "settoreCell"
        cell = self.tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:cellID)
        cell.textLabel.text = "settore"
        cell.detailTextLabel.text = "#{@libro.settore}"
      
      elsif indexPath.row == 2

        cellID = "eanCell"
        cell = self.tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:cellID)
        cell.textLabel.text = "ean"
        cell.detailTextLabel.text = "#{@libro.ean}"

      elsif indexPath.row == 3

        cellID = "cmCell"
        cell = self.tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:cellID)
        cell.textLabel.text = "c.m"
        cell.detailTextLabel.text = "#{@libro.cm}"

      end

    elsif indexPath.section == 1

      if indexPath.row == 0

        cellID = "prezzoCopertinaCell"
        cell = self.tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:cellID)
        cell.textLabel.text = "Prezzo copertina"
        cell.detailTextLabel.text = "#{@libro.prezzo_copertina}"
      
      elsif indexPath.row == 1

        cellID = "prezzoConsigliatoCell"
        cell = self.tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:cellID)
        cell.textLabel.text = "Prezzo consigliato"
        cell.detailTextLabel.text = "#{@libro.prezzo_consigliato}"

      end

    end

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator 
    cell
  end


  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    
    if indexPath.section == 0 

      if indexPath.row == 0
        # titolo
        editController = EditTextFieldController.alloc.initWithType(TextFieldTypeLongString)
        editController.load_data("#{@libro.titolo}", withLabel:"Inserisci il titolo")
        editController.setTextChangedBlock( lambda do |text, error|
            path = NSIndexPath.indexPathForRow(0, inSection:0)
            cell = self.tableView.cellForRowAtIndexPath(path)
            cell.textLabel.text = text
            @libro.titolo = text
            return true
          end
        )
        self.navigationController.pushViewController editController, animated:true
    
      elsif indexPath.row == 1
        
        listController = EditListController.alloc.initWithItems(SettoriList)
        listController.value = @libro.settore
        listController.delegate = self
        self.navigationController.pushViewController listController, animated:true

      elsif indexPath.row == 2
        # ean
        editController = EditTextFieldController.alloc.initWithType(TextFieldTypeLongString)
        
        editController.load_data("#{@libro.ean}", withLabel:"Inserisci il codice ean")

        editController.setTextChangedBlock( lambda do |text, error|
            path = NSIndexPath.indexPathForRow(2, inSection:0)
            cell = self.tableView.cellForRowAtIndexPath(path)
            cell.detailTextLabel.text = text
            @libro.ean = text
            return true
          end
        )
        self.navigationController.pushViewController editController, animated:true

      elsif indexPath.row == 3
        # cm
        editController = EditTextFieldController.alloc.initWithType(TextFieldTypeString)
        
        editController.load_data("#{@libro.cm}", withLabel:"Inserisci il codice cm")

        editController.setTextChangedBlock( lambda do |text, error|
            path = NSIndexPath.indexPathForRow(3, inSection:0)
            cell = self.tableView.cellForRowAtIndexPath(path)
            cell.detailTextLabel.text = text
            @libro.cm = text
            return true
          end
        )
        self.navigationController.pushViewController editController, animated:true

      end
    
    elsif indexPath.section == 1

      if indexPath.row == 0
        # prezzo_copertina
        editController = EditTextFieldController.alloc.initWithType(TextFieldTypeDecimal)
        editController.load_data("#{@libro.prezzo_copertina}", withLabel:"Inserisci il prezzo di copertina")
        editController.setTextChangedBlock( lambda do |text, error|
            path = NSIndexPath.indexPathForRow(0, inSection:1)
            cell = self.tableView.cellForRowAtIndexPath(path)
            cell.detailTextLabel.text = text
            @libro.prezzo_copertina = text.gsub(/,/, '.').to_f
            return true
          end
        )
        self.navigationController.pushViewController editController, animated:true
    
      elsif indexPath.row == 1
        # prezzo_consigliato
        editController = EditTextFieldController.alloc.initWithType(TextFieldTypeDecimal)
        editController.load_data("#{@libro.prezzo_consigliato}", withLabel:"Inserisci il prezzo consigliato")
        editController.setTextChangedBlock( lambda do |text, error|
            path = NSIndexPath.indexPathForRow(1, inSection:1)
            cell = self.tableView.cellForRowAtIndexPath(path)
            cell.detailTextLabel.text = text
            @libro.prezzo_consigliato = text.gsub(/,/, '.').to_f
            return true
          end
        )
        self.navigationController.pushViewController editController, animated:true

      end
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