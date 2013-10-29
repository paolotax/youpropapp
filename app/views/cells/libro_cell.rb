class LibroCell < UITableViewCell
  
  extend IB

  outlet :imageCopertina
  outlet :labelTitolo
  outlet :labelPrezzoCopertina
  outlet :buttonAdd

  attr_accessor :imageDownloadTask

  def setSelected(selected, animated:animated)
    super

    self.buttonAdd.hidden = !selected;
  end


  def pushAddButton(sender)
    App.alert("and boom")
  end
end