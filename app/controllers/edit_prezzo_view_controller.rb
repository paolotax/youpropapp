class EditPrezzoViewController < UITableViewController

  extend IB

  outlet :editPrezzo
  outlet :editSconto

  attr_accessor :prezzoChangedBlock, :riga

  def viewWillAppear(animated)
    super
    puts @riga.titolo
    puts @riga.prezzo_copertina
    load_data
  end

  def prezzi
    @prezzi ||= begin
      @prezzi = [
        '€ %.2f' % @riga.prezzo_consigliato,
        '€ %.2f' % (@riga.prezzo_copertina.to_f * 0.85),
        '€ %.2f' % (@riga.prezzo_copertina.to_f * 0.80),
        '€ %.2f' % (@riga.prezzo_copertina.to_f * 0.75),
        '€ %.2f' % (@riga.prezzo_copertina.to_f * 0.70),
        '€ %.2f' % @riga.prezzo_copertina,
      ]
    end    
  end

  def sconti
    @sconti ||= [ '€ %.2f' % @riga.prezzo_consigliato, '15.0', '20.0', '25.0', '30.0' ]
  end  

  def load_data
    table = self.tableView

    (0..4).each do |index|
      cell = table.cellForRowAtIndexPath([0, index].nsindexpath)
      cell.detailTextLabel.text = prezzi[index]
    end

  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)

    # if @appunto.status
    #   previousIndexPath = NSIndexPath.indexPathForRow(STATUSES.index(@appunto.status.split("_").join(" ")), inSection:0)
    #   cell = tableView.cellForRowAtIndexPath(previousIndexPath)
    #   cell.accessoryType = UITableViewCellAccessoryNone
    # end
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    if indexPath.row < 6
      tableView.cellForRowAtIndexPath(indexPath).accessoryType = UITableViewCellAccessoryCheckmark

      case indexPath.row
      when 0
        prezzo = @riga.prezzo_consigliato
        sconto = 0
      when 1..4
        prezzo = @riga.prezzo_copertina
        sconto = sconti[indexPath.row].to_f
      when 5
        prezzo = 0.0
        sconto = 0.0
      end

      error = Pointer.new(:object)
      success = @prezzoChangedBlock.call(prezzo, sconto, error)
      if (success) 
        self.navigationController.popViewControllerAnimated(true)
        return true
      else
        alertView = UIAlertView.alloc.initWithTitle("Error", message:error.localizedDescription, delegate:nil, cancelButtonTitle:"Chiudi", otherButtonTitles:nil);
        alertView.show
        return false
      end
    end

    if [6, 7].include?(indexPath.row)
      showDoneButton(self)
    end

  end

  def handleButtonDone
    
    error = Pointer.new(:object)

    editSconto.text.blank? ? sconto = '0' : sconto = editSconto.text
    editPrezzo.text.blank? ? prezzo = @riga.prezzo_copertina : prezzo = editPrezzo.text
          
    success = @prezzoChangedBlock.call(prezzo, sconto, error)
    if (success) 
      self.navigationController.popViewControllerAnimated(true)
      return true
    else
      alertView = UIAlertView.alloc.initWithTitle("Error", message:error.localizedDescription, delegate:nil, cancelButtonTitle:"Chiudi", otherButtonTitles:nil);
      alertView.show
      return false
    end

  end

  def showDoneButton(sender)
    self.navigationItem.setRightBarButtonItem(UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemDone, target:self, action:'done:'))
  end

  def done(sender)
    handleButtonDone
  end

  def close(sender)
    self.navigationController.popViewControllerAnimated(true)
  end
end