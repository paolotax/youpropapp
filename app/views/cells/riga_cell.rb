class RigaCell < UITableViewCell

  attr_reader :labelTitolo, :labelPrezzo, :labelSconto, :labelQuantita, :imageCopertina
  

  def initWithStyle(style, reuseIdentifier: reuseIdentifier)
    super
    #self.contentView.backgroundColor = UIColor.yellowColor
    @imageCopertina = newImageCopertina
    @labelTitolo    = newLabelTitolo
    @labelPrezzo    = newLabelPrezzo
    #@labelSconto    = newLabelSconto
    @labelQuantita  = newLabelQuantita
    addLabelsToSubview

    self
  end


  def load_data(riga)
    @labelTitolo.text = "#{riga.titolo}"
    @labelPrezzo.text = "prezzo un. € #{riga.prezzo_unitario.round(2)}"
    @labelQuantita.text = "copie #{riga.quantita}"
    
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
                  @imageCopertina.image = image;
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
 

  def addLabelsToSubview
    Motion::Layout.new do |layout|
      layout.view self.contentView
      layout.subviews "labelTitolo" => labelTitolo, "labelPrezzo" => labelPrezzo, "labelQuantita" => labelQuantita, "imageCopertina" => imageCopertina
      
      layout.metrics "titleHeight" => 25, "margin" => 46, "tb_margin" => 5
      
      layout.vertical "|-tb_margin-[labelTitolo]-titleHeight-|"
      layout.vertical "|-titleHeight-[labelPrezzo]-tb_margin-|"
      layout.vertical "|-titleHeight-[labelQuantita]-tb_margin-|"
      layout.vertical "|[imageCopertina(==60)]"
      
      layout.horizontal "|-margin-[labelTitolo]|"
      layout.horizontal "|-margin-[labelPrezzo]-(>=10)-[labelQuantita]|"
      layout.horizontal "|[imageCopertina(==40)]"
    end
  end
 

  def newLabelTitolo
    label = UILabel.alloc.init
    #label.backgroundColor = UIColor.redColor
    label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
    label
  end


  def newLabelPrezzo
    label = UILabel.alloc.init
    #label.backgroundColor = UIColor.greenColor
    
    label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    label
  end


  def newLabelSconto
    label = UILabel.alloc.init
    label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
    label
  end
 
  
  def newLabelQuantita
    label = UILabel.alloc.init
    #label.backgroundColor = UIColor.whiteColor
    
    label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    label
  end


  def newImageCopertina
    image = UIImageView.alloc.init
    image
  end


end