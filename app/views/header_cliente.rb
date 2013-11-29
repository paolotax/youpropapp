class HeaderCliente < UITableViewHeaderFooterView

  attr_accessor :cliente, :nel_baule, :delegate, :section, :circle_button

  def initWithReuseIdentifier(reuseIdentifier)
    super.tap do |header|

      @circle_button =  CircleButton.new
      @circle_button.frame = CGRectMake(8, 5, 44, 44)
      @circle_button.addTarget(self, action:"toggleBaule:", forControlEvents:UIControlEventTouchUpInside)
    
      header.contentView.addSubview @circle_button
    end
  end

  def titolo=(titolo)
    @titolo_label.text = titolo
  end

  def quantita=(quantita)
    @quantita_label.text = quantita
  end

  def toggleBaule(sender)  
    toggleBauleWithUserAction(true)
  end

  def toggleBauleWithUserAction(userAction)
    
    #@circle_button.nel_baule = !@circle_button.nel_baule
    if (self.delegate.respondsToSelector('headerCliente:didTapBaule:'))
      self.delegate.headerCliente(self, didTapBaule:self.section)
    end
  end




end