class LibroCell < UITableViewCell
  
  extend IB

  outlet :imageCopertina
  outlet :labelTitolo
  outlet :labelPrezzoCopertina

  attr_accessor :imageDownloadTask

end