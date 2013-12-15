include SugarCube::Adjust 

class AppDelegate

  attr_accessor :url_session
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    
    self.initAppearance
    Store.shared.setupReachability

    sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration
    @url_session = NSURLSession.sessionWithConfiguration(sessionConfig)

    AFNetworkActivityIndicatorManager.sharedManager.enabled = true
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

   
    if Device.ipad?
      storyboard = UIStoryboard.storyboardWithName("Main", bundle:nil)
      @window.rootViewController = storyboard.instantiateInitialViewController
    else
      storyboard = UIStoryboard.storyboardWithName("MainPhone", bundle:nil)
      @window.rootViewController = storyboard.instantiateInitialViewController
    end
    @window.makeKeyAndVisible

    @login = LoginController.alloc.init
    @login_navigation = UINavigationController.alloc.initWithRootViewController(@login)

    @window.rootViewController.presentModalViewController(@login_navigation, animated:false)
    
    true
  end

  def window
    @window
  end


  def initAppearance

    # byteClubBlue = UIColor.colorWithRed(65.0/255.0, green:117.0/255.0, blue:209.0/255.0, alpha:1.0)
    

    # UITabBar.appearance.setBarTintColor byteClubBlue

    # UINavigationBar.appearance.setBarStyle UIBarStyleBlackOpaque
    
    # #
    # UINavigationBar.appearance.setBarTintColor byteClubBlue
    
    # UIToolbar.appearance.setBarStyle UIBarStyleBlackOpaque
    # UIToolbar.appearance.setBarTintColor byteClubBlue


  end



    
end
