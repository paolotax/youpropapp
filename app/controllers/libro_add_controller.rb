class LibroAddController < UIViewController

  attr_accessor :book, :tlb


  def viewDidLoad
    super
    view.backgroundColor = UIColor.clearColor
    view.clipsToBounds = true
    
    @tlb = UIToolbar.alloc.initWithFrame self.view.frame
    @tlb.barStyle = UIBarStyleDefault
    # @tlb.tintColor = UIColor.yellowColor
    
    self.view.layer.insertSublayer @tlb.layer, atIndex:0

    Motion::Layout.new do |layout|
      layout.view view
      layout.subviews "labelTitle" => labelTitle, 
                      "labelISBN"  => labelISBN, 
                      "labelAuthors" => labelAuthors, 
                      "labelPublisher" => labelPublisher,
                      "imageCover" => imageCover,
                      "buttonCreate" => buttonCreate,
                      "buttonEdit" => buttonEdit,                      
                      "buttonDismiss" => buttonDismiss


      layout.horizontal "|-20-[labelAuthors]-20-|"
      layout.horizontal "|-20-[labelTitle]-20-|"
      layout.horizontal "|-20-[labelISBN]-20-|"
      layout.horizontal "|-20-[labelPublisher]-20-|"
      layout.horizontal "|-20-[buttonCreate]-20-|"
      layout.horizontal "|-20-[buttonEdit]-20-|"
      layout.horizontal "|-20-[buttonDismiss]-20-|"

      layout.vertical "|-40-[labelTitle]-8-[labelAuthors]-8-[labelPublisher]-8-[labelISBN]-20-[imageCover(==120)]-(>=50)-|"

      layout.vertical "|-(>=20)-[buttonCreate(==40)][buttonEdit(==40)][buttonDismiss(==40)]-20-|"

      layout.horizontal "|-50-[imageCover(==80)]-(>=50)-|"
      
    end
  end

  def viewWillAppear(animated)
    super
    loadData if book
  end

  def loadData

    @labelAuthors.text = book.authors.join(", ") if book.authors
    @labelTitle.text = book.title
    @labelPublisher.text = book.publisher
    @labelISBN.text = book.isbn

    # sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration
    # session = NSURLSession.sessionWithConfiguration(sessionConfig)

    imageURL = NSURL.URLWithString book.image
    if (imageURL) 
      task = App.delegate.url_session.dataTaskWithURL(imageURL,
        completionHandler: 
          lambda do |data, response, error|
            if error
              NSLog("ERROR: %@", error)
            else             
              httpResponse = response;
              if (httpResponse.statusCode == 200)
                image = UIImage.imageWithData(data)                
                Dispatch::Queue.main.async do
                  @imageCover.image = image;
                end
              else
                NSLog("Couldn't load image at URL: %@", imageURL)
                NSLog("HTTP %d", httpResponse.statusCode)
              end
            end
          end
        )
      task.resume
    end
  end


  def labelAuthors
    @labelAuthors ||= begin
      @labelAuthors = UILabel.new
      @labelTitle.numberOfLines = 0
      @labelAuthors.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
      
      @labelAuthors
    end
  end

  def labelTitle
    @labelTitle ||= begin
      @labelTitle = UILabel.new
      @labelTitle.numberOfLines = 0
      @labelTitle.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
      @labelTitle
    end
  end

  def labelPublisher
    @labelPublisher ||= begin
      @labelPublisher = UILabel.new
      @labelPublisher.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
      @labelPublisher
    end
  end

  def labelISBN
    @labelISBN ||= begin
      @labelISBN = UILabel.new
      @labelISBN.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)      
      @labelISBN
    end
  end


  def imageCover
    @imageCover ||= begin
      @imageCover = UIImageView.new
      #@imageCover.frame = CGRectMake(100, 200, 80, 150)
      @imageCover
    end
  end

  def buttonCreate
    @buttonCreate ||= begin
      @buttonCreate = UIButton.custom
      @buttonCreate.setTitle "Crea libro", forState:UIControlStateNormal
      @buttonCreate.setTitleColor UIColor.blueColor, forState:UIControlStateNormal
      @buttonCreate.addTarget self, action:"bookCreate:", forControlEvents:UIControlEventTouchUpInside
      @buttonCreate
    end
  end


  def buttonEdit
    @buttonEdit ||= begin
      @buttonEdit = UIButton.custom
      @buttonEdit.setTitle "Aggiungi ean a libro", forState:UIControlStateNormal
      @buttonEdit.setTitleColor UIColor.blueColor, forState:UIControlStateNormal
      @buttonEdit.addTarget self, action:"bookEdit:", forControlEvents:UIControlEventTouchUpInside
      @buttonEdit
    end
  end

  def buttonDismiss
    @buttonDismiss ||= begin
      @buttonDismiss = UIButton.custom
      @buttonDismiss.setTitle "Chiudi", forState:UIControlStateNormal
      @buttonDismiss.setTitleColor UIColor.blueColor, forState:UIControlStateNormal
      @buttonDismiss.addTarget self, action:"dismiss", forControlEvents:UIControlEventTouchUpInside
      @buttonDismiss
    end
  end

  def bookCreate(sender)

    lvc = LibroFormController.alloc.initWithStyle(UITableViewStyleGrouped)
    lvc.load_data Libro.create_from_google_book(book)
    lvc.isNew = true
    nav = UINavigationController.alloc.initWithRootViewController lvc
    self.presentModalViewController nav, animated:true

  end


  def bookEdit(sender)

  end


  def dismiss
    self.dismissViewControllerAnimated(true, completion:nil)
  end



end
