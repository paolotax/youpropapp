class LibriController < UIViewController
  
  extend IB

  outlet :tableView

  attr_accessor :appunto

  def viewDidLoad
    super
    @refreshControl = UIRefreshControl.alloc.init
    @refreshControl.addTarget(self, action:"loadFromBackend", forControlEvents:UIControlEventValueChanged)
    self.tableView.addSubview(@refreshControl)

    sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration
    @session = NSURLSession.sessionWithConfiguration(sessionConfig)
    #self.tableView.registerClass(LibroCell, forCellReuseIdentifier:"cellLibro")
  end

  def viewWillAppear(animated)
    super
    reload
  end

  def viewWillDisappear(animated)
    super
  end

  def viewDidAppear(animated)
    super
  end

  def reload
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

    riga = Riga.add do |r|
      r.riga_uuid = BubbleWrap.create_uuid.downcase
        
      r.appunto = appunto
      r.remote_appunto_id = appunto.remote_id 
      r.libro = libro  
      r.libro_id = libro.LibroId
      r.titolo   = libro.titolo
      r.prezzo_copertina    = libro.prezzo_copertina
      r.prezzo_consigliato  = libro.prezzo_consigliato

      if r.appunto.cliente.cliente_tipo == "Cartolibreria"
        r.prezzo_unitario  = libro.prezzo_copertina
        r.sconto   = 20
      else
        r.prezzo_unitario  = libro.prezzo_consigliato
        r.sconto   = 0
      end 

      r.quantita = 1
    end
    
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
      cell.imageDownloadTask = @session.dataTaskWithURL(imageURL,
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

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    80
  end

  private

    def loadFromBackend
      Store.shared.login do
        Store.shared.backend.getObjectsAtPath("api/v1/libri",
                                    parameters: nil,
                                    success: lambda do |operation, result|
                                                      @refreshControl.endRefreshing unless @refreshControl.nil?
                                                      self.tableView.reloadData
                                                    end,
                                    failure: lambda do |operation, error|
                                                      App.alert("#{error.localizedDescription}")
                                                    end)
      end
    end


end