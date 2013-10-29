class DetailController < UIViewController

  extend IB

  outlet :labelTitolo
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
  end

  def viewWillDisappear(animated)
    super
    "#{titolo}changeTitolo".remove_observer(self, "changeTitolo:")
  end

  def changeTitolo(notification)
    titolo = notification.userInfo[:titolo]
    self.labelTitolo.text = titolo
  end

  def loadData(which)
    self.labelTitolo.text = which
    self.labelTitolo.color = color
    
    clientiVC.filtro_clienti = which
    clientiVC.tableView.setTintColor color
    clientiVC.navigationController.navigationBar.setTintColor color
    clientiVC.reload
  end

  def prepareForSegue(segue, sender:sender)
    if (segue.identifier.isEqualToString("clientiSegue"))  
      self.clientiVC = segue.destinationViewController.topViewController
    end
  end
    

end