class UIView
  def firstResponder
    return self if isFirstResponder
    subviews.each {|s| v = s.firstResponder; return v if v}
    nil
  end

  def viewController
    if (self.nextResponder.isKindOfClass(UIViewController))
      self.nextResponder
    else
      return nil
    end
  end
end