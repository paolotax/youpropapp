class LibriController < UIViewController
  
  extend IB

  outlet :tableView

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

  def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
    Libro.reset  
    @searchString = searchString
    true
  end

  def fetchControllerForTableView(tableView)
    if tableView == self.tableView 
      Libro.controller 
    else 
      Libro.searchController(@searchString, withScope:nil) 
    end
  end

  # def fetchControllerForTableView(tableView)
  #   @controller ||= begin
  #     Libro.reset
  #     @controller = Libro.controller
  #     @controller
  #   end
  # end

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