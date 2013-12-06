class DynamicNewController < UIViewController

  extend IB

  outlet :fakeTableView

  FILTRI = ["nel baule", "da fare", "in sospeso", "tutti"]
  
  COLORS = [
    "#ff7f00".uicolor,
    "#5ad535".uicolor,
    "#f80e57".uicolor,
    "#259cf3".uicolor
  ]

  def viewDidLoad

    super

    self.fakeTableView.hidden = true

    self.searchDisplayController.searchResultsTableView.separatorColor = UIColor.lightGrayColor
    
    self.searchDisplayController.searchResultsTableView.backgroundColor = UIColor.whiteColor

    self.searchDisplayController.searchResultsTableView.tintColor = "#FF2D55".uicolor
    
    # 1. add the lower background layer
    backgroundImageView = UIImageView.alloc.initWithImage(UIImage.imageNamed("Background-LowerLayer.png"))
    backgroundImageView.frame = CGRectInset(self.view.frame, -50.0, -50.0)
    self.view.addSubview(backgroundImageView)
    self.addMotionEffectToView(backgroundImageView, magnitude:50.0)
    
    # 2. add the background mid layer
    backgroundImageView2 = UIImageView.alloc.initWithImage(UIImage.imageNamed("Background-MidLayer.png"))
    self.view.addSubview(backgroundImageView2)

    # 3. add the foreground image
    @header = UIImageView.alloc.initWithImage(UIImage.imageNamed("youpropapp.png"))
    @header.center = CGPointMake(200, 190)
    self.view.addSubview(@header)
    self.addMotionEffectToView(@header, magnitude:-20.0)
        
    
    @searchBar = UISearchBar.alloc.initWithFrame([[0, 20], [320, 44]])
    @searchBar.placeholder = "Cerca clienti"
    @searchBar.delegate = self
    self.searchDisplayController.searchBar = @searchBar    
    @searchBar.setBackgroundImage UIImage.new
    @searchBar.setTranslucent true
    self.view.addSubview @searchBar
    

    @animator = UIDynamicAnimator.alloc.initWithReferenceView(self.view)
    @gravity = UIGravityBehavior.alloc.init
    @animator.addBehavior(@gravity)
    @gravity.magnitude = 4.0
    

    @views = NSMutableArray.new
    offset = 340.0
    for filtro in FILTRI
      @views.addObject(self.addClientiAtOffset(offset, forFilter:filtro))
      offset -= 77.0
    end

  end

  def addMotionEffectToView(view,  magnitude:magnitude)
    xMotion = UIInterpolatingMotionEffect.alloc.initWithKeyPath("center.x", type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis)
    xMotion.minimumRelativeValue = -magnitude
    xMotion.maximumRelativeValue = magnitude
    
    yMotion = UIInterpolatingMotionEffect.alloc.initWithKeyPath("center.y", type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis)
    yMotion.minimumRelativeValue = -magnitude
    yMotion.maximumRelativeValue = magnitude
    
    group = UIMotionEffectGroup.alloc.init
    group.motionEffects = [xMotion, yMotion]
    
    view.addMotionEffect(group)
  end

  def addClientiAtOffset(offset, forFilter:filtro)

    frameForView = CGRectOffset(self.view.bounds, 0.0, self.view.bounds.size.height - offset)
    mystoryboard = UIStoryboard.storyboardWithName("MainPhone", bundle:nil)
    viewController = mystoryboard.instantiateViewControllerWithIdentifier("DetailVC")
    view = viewController.view
    view.frame = frameForView    
    viewController.titolo = filtro
    viewController.color = COLORS[FILTRI.index(filtro)]
    self.addChildViewController(viewController)
    self.view.addSubview(viewController.view)
    viewController.didMoveToParentViewController(self)
    

    pan = UIPanGestureRecognizer.alloc.initWithTarget(self, action:"handlePan:")
    viewController.view.addGestureRecognizer(pan)

    collision = UICollisionBehavior.alloc.initWithItems([view])
    @animator.addBehavior(collision)
    # 3. lower boundary, where the tab rests
    boundary = view.frame.origin.y + view.frame.size.height + 1
    boundaryStart = CGPointMake(0.0, boundary)
    boundaryEnd = CGPointMake(self.view.bounds.size.width, boundary)
    collision.addBoundaryWithIdentifier(1,
                         fromPoint:boundaryStart,
                           toPoint:boundaryEnd)    
    # 4. upper boundary
    boundaryStart = CGPointMake(0.0, 0.0)
    boundaryEnd = CGPointMake(self.view.bounds.size.width, 0.0)
    collision.addBoundaryWithIdentifier(2,
                               fromPoint:boundaryStart,
                                 toPoint:boundaryEnd)
    collision.collisionDelegate = self

    # apply some gravity
    @gravity.addItem(view)
    
    # add an item behaviour for this view
    itemBehavior = UIDynamicItemBehavior.alloc.initWithItems([view])
    @animator.addBehavior(itemBehavior)


    tap = UITapGestureRecognizer.alloc.initWithTarget(self, action:"handleTap:")
    viewController.labelTitolo.userInteractionEnabled = true
    viewController.labelTitolo.addGestureRecognizer(tap)


    viewController
  end

  def collisionBehavior(behavior, beganContactForItem:item, withBoundaryIdentifier:identifier, atPoint:p)
    if 2.isEqual(identifier)
      view = item;
      self.tryDockView(view)
    end
    if 1.isEqual(identifier)
      puts "collided"
      view = item;
      @viewDocked = false
      @viewDocked = nil
      #self.setAlphaWhenViewDocked(view, alpha:1.0)
    end
  end

  def handleTap(gesture)

    controller = gesture.view.superview.viewController
    #self.setAlphaWhenViewDocked(controller.view, alpha:0.0)
    controller.scrollToTop
    self.moveDownViews(controller.view)
  end


  def handlePan(gesture)

    touchPoint  = gesture.locationInView(self.view)
    draggedView = gesture.view

    if (gesture.state == UIGestureRecognizerStateBegan)

      # 1. was the pan initiated from the upper part of the recipe?
      #draggedView = gesture.view
      dragStartLocation = gesture.locationInView(draggedView)
      puts dragStartLocation.y
      if (dragStartLocation.y < 140.0) 
        @draggingView = true
        @previousTouchPoint = touchPoint
      end

    elsif (gesture.state == UIGestureRecognizerStateChanged && @draggingView) 

      # 2. handle dragging
      yOffset = @previousTouchPoint.y - touchPoint.y
      gesture.view.center = CGPointMake(draggedView.center.x,
                                        draggedView.center.y - yOffset)
      @previousTouchPoint = touchPoint

    elsif (gesture.state == UIGestureRecognizerStateEnded && @draggingView)

      # aggiungo
      if @snap
        # @animator.removeBehavior(@snap)
        self.setAlphaWhenViewDocked(view, alpha:1.0)
        @viewDocked = false
        @viewDocked = nil
        @snap = nil
      else
        puts "# 3. the gesture has ended"
        self.tryDockView(draggedView)
      end
      
      self.addVelocityToView(draggedView, fromGesture:gesture)
      @animator.updateItemUsingCurrentState(draggedView)
      
      @draggingView = false
      @draggingView = nil
    end
  end

  def itemBehaviourForView(view)
    for behaviour in @animator.behaviors
      if (behaviour.class == UIDynamicItemBehavior && behaviour.items.firstObject == view)
        return behaviour
      end
    end
    return nil
  end

  def addVelocityToView(view, fromGesture:gesture)
    # convert pan velocity into item velocity
    vel = gesture.velocityInView(self.view)
    vel.x = 0
    behaviour = self.itemBehaviourForView(view)
    behaviour.addLinearVelocity(vel, forItem:view)
  end

  def tryDockView(view)
    
    viewHasReachedDockLocation = view.frame.origin.y < 200.0

    if viewHasReachedDockLocation
      unless @viewDocked
        puts "@viewDocked hasReached"
        view.frame = CGRectMake(0,0,320,568)
        # @snap = UISnapBehavior.alloc.initWithItem(view, snapToPoint:self.view.center)
        # @animator.addBehavior(@snap)
        
        self.moveDownViews(view)
        puts "@viewDocked"
        #self.setAlphaWhenViewDocked(view, alpha:0.0)
        @viewDocked = true
        @snap = true
      end
    elsif (@viewDocked)
      #@animator.removeBehavior(@snap)
      self.setAlphaWhenViewDocked(view, alpha:1.0)
      @viewDocked = false
      @viewDocked = nil
      @snap = nil
    end
  end

  def setAlphaWhenViewDocked(view, alpha:alpha)
    for aView in @views
      if (aView.view != view)
        aView.view.alpha = alpha
      end
    end
  end

  def moveDownViews(view)

    puts "moveDown"

    top = self.view.frame.size.height - 25 - 20
    for aView in @views
      top += 5
      if (aView.view != view)
        puts top
        aView.view.frame = CGRectMake(0, top, 320, 568)
        aView.view.alpha = 1.0
      end
    end
  end




  # fetch data for searchDisplayController

  def fetchControllerForTableView(tableView)
    Cliente.searchController(@searchString, withScope:nil) 
  end

  # searchDisplayDelegates

  def searchBarShouldBeginEditing(searchBar)
    searchBar.showsCancelButton = true
    true
  end

  def searchBarShouldEndEditing(searchBar)
    searchBar.showsCancelButton = false
    true
  end

  
  def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
    Cliente.reset
    Cliente.setSectionKey nil 
    @searchString = searchString
    true
  end

  def searchDisplayControllerWillBeginSearch controller
    @header.hidden = true
    @views.each {|v| v.view.hidden = true}
  end

  def searchDisplayControllerDidEndSearch controller
    @header.hidden = false
    @views.each {|v| v.view.hidden = false}
  end

  # tableView Delegates

  def numberOfSectionsInTableView(tableView)
    if tableView == self.fakeTableView
      0
    else
      self.fetchControllerForTableView(tableView).sections.size
    end
  end

  # def tableView(tableView, titleForHeaderInSection:section)
  #   self.fetchControllerForTableView(tableView).sections[section].name
  # end
  
  def tableView(tableView, numberOfRowsInSection:section)
    if tableView == self.fakeTableView
      0
    else
      self.fetchControllerForTableView(tableView).sections[section].numberOfObjects
    end    
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    54   
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)

    cellIdentifier = "cellCliente"

    if tableView == self.searchDisplayController.searchResultsTableView 
      cell = self.fakeTableView.dequeueReusableCellWithIdentifier cellIdentifier
    else
      cell = self.fakeTableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath:indexPath)
    end

    cliente = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)
    
    cell.clienteLabel.text = cliente.nome
    cell.cittaLabel.text = cliente.citta
    cell.cittaLabel.color = tableView.tintColor
    cell.colorButton.setColor tableView.tintColor
    cell.colorButton.nel_baule = cliente.nel_baule
    cell.colorButton.addTarget(self, action:"buttonTappedAction:", forControlEvents:UIControlEventTouchUpInside)

    cell
  end

  def buttonTappedAction(sender)
    buttonPosition = sender.convertPoint(CGPointZero, toView:self.searchDisplayController.searchResultsTableView)
    
    indexPath = self.searchDisplayController.searchResultsTableView.indexPathForRowAtPoint buttonPosition

    if indexPath
      cliente = self.fetchControllerForTableView(self.searchDisplayController.searchResultsTableView).objectAtIndexPath(indexPath)
      if cliente.nel_baule == 0
        cliente.nel_baule = 1
      else
        cliente.nel_baule = 0
      end
      sender.nel_baule = cliente.nel_baule
    end

    "bauleDidChange".post_notification
    "clientiDidChange".post_notification
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)

    if tableView == self.searchDisplayController.searchResultsTableView 

      cell = tableView.cellForRowAtIndexPath indexPath
      cliente = self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath)
      

      if Device.ipad?
        nav = mainVC.detailVC.clientiVC.navigationController
        dvc = self.storyboard.instantiateViewControllerWithIdentifier("ClienteDetail")
        dvc.cliente = cliente
        nav.pushViewController(dvc, animated:true)
        self.searchDisplayController.setActive false
      else
        whichView = @views[cliente.whichGroup]
        whichView.view.frame = self.view.frame
        self.setAlphaWhenViewDocked(whichView.view, alpha:0.0)
        @viewDocked = true

        nav = whichView.clientiVC.navigationController
        dvc = self.storyboard.instantiateViewControllerWithIdentifier("ClienteDetail")
        dvc.cliente = cliente
        dvc.titolo  = whichView.titolo

        whichView.clientiVC.scrollToClienteAndPush(cliente)

        #nav.pushViewController(dvc, animated:true)

        self.searchDisplayController.setActive false
      end
    end

  end
  
  def tableView(tableView, willDisplayCell:cell, forRowAtIndexPath:indexPath)
    cell.backgroundColor = UIColor.clearColor
    bgColorView = UIView.alloc.init
    bgColorView.backgroundColor = UIColor.colorWithRed(65.0/255.0, green:117.0/255.0, blue:209.0/255.0, alpha:1.0)
    bgColorView.layer.masksToBounds = true
    cell.selectedBackgroundView = bgColorView
  end



end