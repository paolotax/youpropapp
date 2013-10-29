class AppuntoModalController < UIViewController

  def close(sender)

    self.dismissViewControllerAnimated(true, completion:nil)
  end

end