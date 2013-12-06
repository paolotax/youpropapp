class ScanController < UIViewController


  attr_accessor :appunto


  def initWithAppunto(appunto)
    init
    @appunto = appunto
    self
  end

  def viewDidLoad
    super
    self.view.backgroundColor = UIColor.whiteColor

    #per i pulsanti della sidebar
    @optionIndices = NSMutableIndexSet.new
    @light_is_on = false

    #per i barcode letti
    @barcodes = NSMutableDictionary.new

    Motion::Layout.new do |layout|
      layout.view view
      layout.subviews "previewView" => previewView,
                      "rectOfInterestView" => rectOfInterestView,
                      "tableView" => tableView,
                      "buttonDismiss" => buttonDismiss

      layout.horizontal "|[previewView]|"
      layout.horizontal "|[tableView]|"
      layout.horizontal "|[buttonDismiss]|"      
      layout.horizontal "|-20-[rectOfInterestView]-20-|"
      
      layout.vertical "|[previewView(==220)][tableView][buttonDismiss(==44)]|"

      layout.vertical "|-20-[rectOfInterestView(==180)]-(>=20)-|"      
    end

    setupCaptureSession()

    @previewLayer.frame = previewView.bounds
    previewView.layer.addSublayer @previewLayer

    willEnterForeground = UIApplicationWillEnterForegroundNotification
    willEnterForeground.add_observer(self, "applicationWillEnterForeground:")

    didEnterBackground = UIApplicationDidEnterBackgroundNotification
    didEnterBackground.add_observer(self, "applicationDidEnterBackground:")

    "didFindBook".add_observer(self, "displayBook:", nil)
    
    true
  end


  def viewWillAppear(animated)
    super
    self.startRunning
    @output.rectOfInterest = @previewLayer.metadataOutputRectOfInterestForRect(rectOfInterestView.frame)
  end



  def viewWillDisappear(animated)
    super
    self.stopRunning
  end


#pragma mark - Notifications


  def applicationWillEnterForeground(notification)
    self.startRunning
  end


  def applicationDidEnterBackground(notification)
    self.stopRunning
  end

  
  def displayBook(notification)
    book = notification.userInfo[:book]
    # @labelTitolo.text = book.title
    # @labelAutori.text = book.authors.join(", ")
    # @labelEditore.text = book.publisher
    # @buttonReset.hidden = false

    bc = LibroAddController.alloc.init
    bc.book = book
    self.presentModalViewController(bc, animated:true)
    #bc.loadData(book)
  end


#pragma mark - Actions


  def torchButtonAction(sender)

    images = [UIImage.imageNamed("171-sun"),
              UIImage.imageNamed("126-moon")]

    colors = [[240,159,254].uicolor,
              [126,242,195].uicolor]

    @optionIndices.removeAllIndexes
    if @light_is_on == true
      @optionIndices.addIndex 0
    else
      @optionIndices.addIndex 1
    end

    sidebar = RNFrostedSidebar.alloc.initWithImages(images, selectedIndices:@optionIndices, borderColors:colors)
    sidebar.showFromRight = true
    sidebar.delegate = self
    sidebar.show
  end


#pragma mark - RNFrostedSidebarDelegate

  
  def sidebar(sidebar, didTapItemAtIndex:index)

    if index == 0
      @device.lockForConfiguration nil
      @device.setTorchMode AVCaptureTorchModeOn
      #@device.setFlashMode AVCaptureFlashModeOn
      @device.unlockForConfiguration
      @light_is_on = true
    else
      @device.lockForConfiguration nil
      @device.setTorchMode AVCaptureTorchModeOff
      #@device.setFlashMode AVCaptureFlashModeOn
      @device.unlockForConfiguration
      @light_is_on = false
    end

    sidebar.dismissAnimated true, completion:nil
  end

  
  def sidebar(sidebar, didEnable:itemEnabled, itemAtIndex:index)

    @optionIndices.removeAllIndexes
    if itemEnabled
      @optionIndices.addIndex index
    else
      @optionIndices.removeIndex index
    end
  end


#pragma mark - Video stuff


  def startRunning

    return if @running == true

    # @labelAutori.text = ""
    # @labelTitolo.text = ""
    # @labelEditore.text = ""

    if @light_is_on == true
      @device.lockForConfiguration nil
      @device.setTorchMode AVCaptureTorchModeOn
      @device.unlockForConfiguration
    end

    @session.startRunning
    @output.metadataObjectTypes = [ AVMetadataObjectTypeEAN13Code ]
    @running = true
  end


  def stopRunning
    return if @running == false
    @session.stopRunning
    @running = false
  end


  def setupCaptureSession

    return if @session
    
    @running = false

    @device = AVCaptureDevice.defaultDeviceWithMediaType AVMediaTypeVideo  
    if !@device
      NSLog "No video camera on this device!"
      return
    end

    @session = AVCaptureSession.alloc.init
    @session.sessionPreset = AVCaptureSessionPresetHigh

    @error = Pointer.new('@')
    @input = AVCaptureDeviceInput.deviceInputWithDevice @device, error: @error
    if (@session.canAddInput @input)
      @session.addInput @input
    end

    @previewLayer = AVCaptureVideoPreviewLayer.alloc.initWithSession(@session)
    @previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

    @queue = Dispatch::Queue.new('camQueue')    

    @output = AVCaptureMetadataOutput.alloc.init
    @output.setMetadataObjectsDelegate self, queue: @queue.dispatch_object 
    if (@session.canAddOutput @output)
      @session.addOutput @output
    end

  end


#pragma mark -


  def processMetadataObject(code)
    
    barcode = @barcodes[code.stringValue]
    
    if (!barcode)
      barcode = Barcode.new
      @barcodes[code.stringValue] = barcode
    end
    
    barcode.metadataObject = code
    barcode.boundingBoxPath = UIBezierPath.bezierPathWithRect(code.bounds)
    barcode
  end


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

 
  def captureOutput(captureOutput, didOutputMetadataObjects: metadataObjects, fromConnection: connection)
    
    originalBarcodes = NSSet.setWithArray @barcodes.allValues
    foundBarcodes = NSMutableSet.new
    metadataObjects.enumerateObjectsUsingBlock(
      lambda do |obj, idx, stop|        
        if (obj.isKindOfClass AVMetadataMachineReadableCodeObject)
          code = @previewLayer.transformedMetadataObjectForMetadataObject obj
          barcode = self.processMetadataObject code
          foundBarcodes.addObject barcode
        end 
      end)

    newBarcodes = foundBarcodes.mutableCopy
    newBarcodes.minusSet originalBarcodes
    
    goneBarcodes = originalBarcodes.mutableCopy
    goneBarcodes.minusSet foundBarcodes
    
    goneBarcodes.enumerateObjectsUsingBlock( 
      lambda do |barcode, stop|
        @barcodes.removeObjectForKey barcode.metadataObject.stringValue
      end)

    Dispatch::Queue.main.async do

      allSublayers = @previewView.layer.sublayers.copy     
      allSublayers.enumerateObjectsUsingBlock(
        lambda do |layer, idx, stop|
          if (layer != @previewLayer)
            layer.removeFromSuperlayer
          end
        end)
        
      foundBarcodes.enumerateObjectsUsingBlock(
        lambda do |barcode, stop|
          boundingBoxLayer = CAShapeLayer.new
          boundingBoxLayer.path = barcode.boundingBoxPath.CGPath
          boundingBoxLayer.lineWidth = 2.0
          boundingBoxLayer.strokeColor = UIColor.greenColor.CGColor
          boundingBoxLayer.fillColor = UIColor.colorWithRed(0, green:1.0, blue:0.0, alpha:0.5).CGColor          
          @previewView.layer.addSublayer boundingBoxLayer
        end )

      newBarcodes.enumerateObjectsUsingBlock(
        lambda do |barcode, stop|
          AudioServicesPlaySystemSound (KSystemSoundID_Vibrate)
          libro = Libro.find_by_barcode(barcode.metadataObject.stringValue)
          unless libro.empty?
            Riga.addToAppunto(@appunto, withLibro:libro[0])
            tableView.reloadData
          else
            GoogleBook.search(barcode.metadataObject.stringValue)
          end   
        end)
    end 
  end


#pragma mark - subViews


  def previewView
    @previewView ||= begin
      @previewView = UIView.new
      @previewView.frame = CGRectMake(0, 0, 320, 220)
      @previewView.backgroundColor = UIColor.redColor
      @previewView
    end
  end


  def rectOfInterestView
    @rectOfInterestView ||= begin
      @rectOfInterestView = UIView.new
      @rectOfInterestView.frame = CGRectMake(20, 20, 280, 180)
      @rectOfInterestView.backgroundColor = [0, 0, 0].uicolor(0.2)
      tap = UITapGestureRecognizer.alloc.initWithTarget(self, action:"torchButtonAction:")
      @rectOfInterestView.userInteractionEnabled = true
      @rectOfInterestView.addGestureRecognizer(tap)
      @rectOfInterestView
    end
  end


  def tableView
    @tableView ||= begin
      @tableView = UITableView.grouped
      @tableView.dataSource = self
      @tableView.delegate = self
      @tableView
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


  def dismiss
    self.dismissViewControllerAnimated(true, completion:nil)
  end


#pragma mark -  UITableViewDelegate
  

  def numberOfSectionsInTableView(tableView)
    1
  end 

  def tableView(tableView, numberOfRowsInSection:section)
    @appunto.righe.count
  end


  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cellID = "rigaCell"
    cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
    cell ||= RigaCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellID)
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    riga = @appunto.righe.objectAtIndex(indexPath.row)
    cell.load_data riga

    cell
  end


  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    50
  end


  def tableView(tableView, canEditRowAtIndexPath:indexPath)
    true
  end


  def tableView(tableView, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    riga = @appunto.righe.objectAtIndex(indexPath.row)
    riga.remove    
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
  end


  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
  end



end