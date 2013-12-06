class RigaFormController < UITableViewController
  
  extend IB

  outlet :editQuantita
  outlet :editPrezzo


  attr_accessor :riga, :appunto
 
  def viewDidLoad
    true
  end

  def viewWillAppear(animated)
    super
    load_riga
  end

  def load_riga
    table = self.tableView
    
    (0..1).each do |index|
      cell = table.cellForRowAtIndexPath([0, index].nsindexpath)
      case index
        when 0
          cell.textLabel.text = @riga.titolo
        when 1
          cell.detailTextLabel.text = "€ %.2f" % @riga.prezzo_copertina
      end
    end  

    (0..2).each do |index|
      cell = table.cellForRowAtIndexPath([1, index].nsindexpath)
      case index
        when 0
          cell.detailTextLabel.text = @riga.quantita.to_s
        when 1
          cell.detailTextLabel.text = "€ %.2f" % @riga.prezzo_unitario
        when 2
          cell.detailTextLabel.text = @riga.sconto.to_s
      end  
    end

    cell = table.cellForRowAtIndexPath([2, 0].nsindexpath)
    cell.detailTextLabel.text = @riga.importo.to_s

  end
  
  def prepareForEditQuantitaSegue(segue, sender:sender)
    editController = segue.destinationViewController
    editController.testo = @riga.quantita.to_s
    editController.setTextChangedBlock( lambda do |text, error|
        cell = self.tableView.cellForRowAtIndexPath([1, 0].nsindexpath)
        cell.detailTextLabel.setText(text)
        @riga.quantita = text.to_i
        return true
      end
    )
  end

  def prepareForSelectPrezzoSegue(segue, sender:sender)
    editController = segue.destinationViewController
    editController.riga  = @riga
    editController.setPrezzoChangedBlock( lambda do |prezzo, sconto, error|
        @riga.prezzo_unitario = prezzo.gsub(/,/, '.').to_f.round(2)
        @riga.sconto = sconto.gsub(/,/, '.').to_f.round(2)
        return true
      end
    )
  end

  def prepareForSegue(segue, sender:sender)
    if segue.identifier.isEqualToString("editQuantita") 
      self.prepareForEditQuantitaSegue(segue, sender:sender)
    elsif segue.identifier.isEqualToString("selectPrezzo") 
      self.prepareForSelectPrezzoSegue(segue, sender:sender)
    end
  end
  

  def save(sender)
    @appunto.updated_at = Time.now
    self.navigationController.popViewControllerAnimated(true)
  end


  def cancel(sender)
    @riga.remove
    self.navigationController.popViewControllerAnimated(true)
  end

      
  
end