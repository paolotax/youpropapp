class DetailController < UIViewController

  extend IB

  outlet :labelTitolo
  outlet :labelSottotitolo
  outlet :headerView

  attr_accessor :color, :titolo, :clientiVC

  def viewDidLoad
    super
    if Device.ipad?
      self.view.backgroundColor = UIColor.whiteColor
      self.view.layer.cornerRadius = 10
    else
      self.headerView.backgroundColor = UIColor.whiteColor
      self.headerView.layer.cornerRadius = 10
    end
  end

  def viewWillAppear(animated)
    super
    "#{titolo}changeTitolo".add_observer(self, "changeTitolo:", nil)
    loadData
  end

  def viewWillDisappear(animated)
    super
    "#{titolo}changeTitolo".remove_observer(self, "changeTitolo:")
  end

  def changeTitolo(notification)
    titolo = notification.userInfo[:titolo]
    sottotitolo = notification.userInfo[:sottotitolo]

    self.labelTitolo.text = titolo
    if sottotitolo
      self.labelSottotitolo.text = sottotitolo
    else
      self.labelSottotitolo.text = ""
    end

  end

  def loadData
    
    self.labelTitolo.text = titolo
    self.labelTitolo.color = color
    self.labelTitolo.shadowColor   = UIColor.darkGrayColor
    self.labelTitolo.shadowOffset  = CGSizeMake(0.0, -0.5)

    
    clientiVC.filtro = titolo
    clientiVC.tableView.setTintColor color
    clientiVC.navigationController.navigationBar.setTintColor color
    clientiVC.navigationController.toolbar.setTintColor color
        
    clientiVC.reload
  
    self.labelSottotitolo.color = color
  end

  def prepareForSegue(segue, sender:sender)
    if (segue.identifier.isEqualToString("clientiSegue"))  
      self.clientiVC = segue.destinationViewController.topViewController
    end
  end
    

end