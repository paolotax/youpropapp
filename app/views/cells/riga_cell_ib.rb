class RigaCellIb < UITableViewCell

  extend IB

  outlet :labelTitolo
  outlet :labelPrezzo
  outlet :labelSconto
  outlet :labelQuantita
  outlet :imageCopertina
  

  def load_data(riga)
    
    self.labelTitolo.text = "#{riga.titolo}"
    self.labelPrezzo.text = "prezzo un. € #{riga.prezzo_unitario.round(2)}"
    self.labelQuantita.text = "copie #{riga.quantita}"
    
    @imageCopertina.image = nil
    imageURL = NSURL.URLWithString riga.libro.image_url
    if (imageURL) 
      @imageSownloadTask = App.delegate.url_session.dataTaskWithURL(imageURL,
        completionHandler: 
          lambda do |data, response, error|
            if error
              NSLog("ERROR: %@", error)
            else
             
              httpResponse = response;
              if (httpResponse.statusCode == 200)
                image = UIImage.imageWithData(data)                
                Dispatch::Queue.main.async do
                  self.imageCopertina.image = image;
                end
              else
                NSLog("Couldn't load image at URL: %@", imageURL)
                NSLog("HTTP %d", httpResponse.statusCode)
              end
            end
          end
        )
      @imageSownloadTask.resume
    end
  end
 
end