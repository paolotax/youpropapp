class RigaCell < UITableViewCell

  attr_reader :riga
  
  def riga=(riga)
    @riga = riga
    textLabel.text = @riga.titolo
    detailTextLabel.text = @riga.quantita.to_s
  end

end