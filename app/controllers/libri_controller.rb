class LibriController < UIViewController
  
  extend IB

  outlet :tableView

  attr_accessor :appunto

  def viewDidLoad
    super
    @refreshControl = UIRefreshControl.alloc.init
    @refreshControl.addTarget(self, action:"loadFromBackend", forControlEvents:UIControlEventValueChanged)
    self.tableView.addSubview(@refreshControl)

    #self.tableView.registerClass(LibroCell, forCellReuseIdentifier:"cellLibro")
  end


  def reload
    Libro.reset
    @controller = nil
    self.tableView.reloadData
  end


  def close(sender)
    self.dismissViewControllerAnimated(true, completion:nil)
  end


  # Storyboard methods
  def prepareForSegue(segue, sender:sender)

    if (self.searchDisplayController.isActive)
      indexPath = self.searchDisplayController.searchResultsTableView.indexPathForCell(sender)
    else
      indexPath = self.tableView.indexPathForCell(sender)
    end  

    libro = @controller.objectAtIndexPath(indexPath)

    riga = Riga.addToAppunto(appunto, withLibro:libro)
    
    segue.destinationViewController.riga  = riga  
    segue.destinationViewController.appunto = appunto
  
  end


  def fetchControllerForTableView(tableView)
    @controller ||= begin
      if tableView == self.tableView 
        @controller = Libro.controller 
      else 
        @controller = Libro.searchController(@searchString, withScope:nil) 
      end
      @controller
    end
  end


  def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
    @controller = nil
    Libro.reset  
    @searchString = searchString
    true
  end


# pragma mark - UITableView Delegate


  def numberOfSectionsInTableView(tableView)
    self.fetchControllerForTableView(tableView).sections.size
  end

  
  def tableView(tableView, numberOfRowsInSection:section)
    self.fetchControllerForTableView(tableView).sections[section].numberOfObjects
  end


  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    
    cell = self.tableView.dequeueReusableCellWithIdentifier("cellLibro")
    cell ||= LibroCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:"cellLibro")
    
    libro = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)
    
    cell.labelTitolo.text = libro.titolo
    if cell.imageDownloadTask
      cell.imageDownloadTask.cancel
    end

    cell.imageCopertina.image = nil
    imageURL = NSURL.URLWithString libro.image_url
    if (imageURL) 
      cell.imageDownloadTask = App.delegate.url_session.dataTaskWithURL(imageURL,
        completionHandler: 
          lambda do |data, response, error|
            if error
              NSLog("ERROR: %@", error)
            else
             
              httpResponse = response;
              if (httpResponse.statusCode == 200)
                image = UIImage.imageWithData(data)                
                Dispatch::Queue.main.async do
                  cell.imageCopertina.image = image;
                end
              else
                NSLog("Couldn't load image at URL: %@", imageURL)
                NSLog("HTTP %d", httpResponse.statusCode)
              end
            end
          end
        )
      cell.imageDownloadTask.resume
    end

    cell
  end


  def tableView(tableView, accessoryButtonTappedForRowWithIndexPath:indexPath) 
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    libro = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)

    lvc = LibroFormController.alloc.initWithStyle(UITableViewStyleGrouped)
    lvc.load_data libro
    lvc.isNew = false
    self.navigationController.pushViewController lvc, animated:true
  end


  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    80
  end


  private


    def loadFromBackend      
      if Store.shared.isReachable? == false
        @refreshControl.endRefreshing unless @refreshControl.nil?
        App.alert "Dispositivo non connesso alla rete. Riprova più tardi"
        return
      end
      DataImporter.default.importa_libri(nil) do |result|
        @refreshControl.endRefreshing unless @refreshControl.nil?
        if result.success?
          reload
        end          
      end
    end


end