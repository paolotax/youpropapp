class AppuntoFormController < UIViewController
  
  extend IB

  outlet :container1 
  outlet :container2

  def viewDidLoad
    super

    c = NSLayoutConstraint.constraintWithItem(container1,
                                            attribute: NSLayoutAttributeWidth,
                                            relatedBy: NSLayoutRelationEqual,
                                            toItem: container2,
                                            attribute: NSLayoutAttributeWidth,
                                            multiplier:1.3,
                                            constant:0)

    self.view.addConstraint c
  end

end