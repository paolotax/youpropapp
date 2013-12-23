class AppuntoCellAuto < UITableViewCell


  attr_accessor :labelDestinatario
  attr_accessor :labelNote
  attr_accessor :labelTotali
  attr_accessor :imageStatus

  # attr_accessor :labelCreatedAt
  # attr_accessor :labelUpdatedAt
  # attr_accessor :imageStatus

  def initWithStyle(style, reuseIdentifier:reuseIdentifier)

    super.tap do |cell| 

      cell.accessoryType = UITableViewCellAccessoryDetailButton     

      @labelDestinatario = UILabel.alloc.initWithFrame(CGRectZero).tap do |label|
        label.setTranslatesAutoresizingMaskIntoConstraints false
        label.setLineBreakMode NSLineBreakByTruncatingTail
        label.setNumberOfLines 1
        label.setTextAlignment NSTextAlignmentLeft
        label.setTextColor UIColor.blackColor
        label.setBackgroundColor UIColor.clearColor
        cell.contentView.addSubview(label)
      end
        
      @labelNote = UILabel.alloc.initWithFrame(CGRectZero).tap do |label|
        label.setTranslatesAutoresizingMaskIntoConstraints false
        label.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis:UILayoutConstraintAxisVertical)
        label.setLineBreakMode NSLineBreakByTruncatingTail
        label.setNumberOfLines 0
        label.setTextAlignment NSTextAlignmentLeft
        label.setTextColor UIColor.darkGrayColor
        label.setBackgroundColor UIColor.clearColor
        cell.contentView.addSubview(label)
      end

      @labelTotali = UILabel.alloc.initWithFrame(CGRectZero).tap do |label|
        label.setTranslatesAutoresizingMaskIntoConstraints false
        label.setLineBreakMode NSLineBreakByTruncatingTail
        label.setNumberOfLines 1
        label.setTextAlignment NSTextAlignmentLeft
        label.setTextColor UIColor.blackColor
        label.setBackgroundColor UIColor.clearColor
        cell.contentView.addSubview(label)
      end

      @imageStatus = UIImageView.alloc.initWithFrame(CGRectZero).tap do |img|
        img.setTranslatesAutoresizingMaskIntoConstraints false
        cell.contentView.addSubview(img)
      end


      @imageCloud = UIImageView.alloc.initWithFrame(CGRectZero).tap do |img|
        img.setTranslatesAutoresizingMaskIntoConstraints false
        cell.contentView.addSubview(img)
      end
        
      cell.updateFonts
      #cell.updateConstraints
    end
  end
    

  def fill_data(appunto, withCliente:showLabel)

    self.updateFonts
    
    if showLabel
      self.labelDestinatario.text = "#{appunto.cliente.nome} #{appunto.destinatario}"
    else
      self.labelDestinatario.text =  appunto.destinatario || "##{appunto.remote_id}"
    end

    if appunto.remote_id == 0
      @imageCloud.image = "732-cloud-upload".uiimage
    else
      @imageCloud.image = nil
    end

    self.labelNote.text = appunto.note_e_righe
    
    if appunto.totale_copie != 0
      self.labelTotali.text = "#{appunto.totale_copie} copie - € #{appunto.totale_importo.round(2)}"
    else
      self.labelTotali.text = nil
    end

    if appunto.status == "completato"
      self.imageStatus.image = "completato".uiimage
      self.imageStatus.highlightedImage = "completato".uiimage
    elsif appunto.status == "in_sospeso"
      self.imageStatus.image = "826-money-1".uiimage
      self.imageStatus.highlightedImage = "826-money-1-selected".uiimage
    else
      self.imageStatus.image = nil
      self.imageStatus.highlightedImage = nil
    end

    self.setNeedsUpdateConstraints
  end
  
  def get_height(appunto)
    
    self.updateFonts
    
    self.labelDestinatario.text =  appunto.destinatario || "##{appunto.remote_id}"
    self.labelNote.text = appunto.note_e_righe + "\r\n"
    
    self.labelNote.preferredMaxLayoutWidth = 195
    
    if appunto.totale_copie != 0
      self.labelTotali.text = "#{appunto.totale_copie} copie - € #{appunto.totale_importo.round(2)}"
    else
      self.labelTotali.text = nil
    end

    self.setNeedsUpdateConstraints
    self.updateConstraintsIfNeeded
    self.contentView.setNeedsLayout
    self.contentView.layoutIfNeeded
    
    height = self.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height    
    
    height = [height, 48].max
    height
  end


  def updateFonts
    @labelDestinatario.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    @labelNote.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
    @labelTotali.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
  end

  
  def updateConstraints
    
    super
    return if @didSetupConstraints

    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem( 
                                          @labelDestinatario,
                                     attribute:NSLayoutAttributeLeading,
                                     relatedBy:NSLayoutRelationEqual,
                                     toItem:self.contentView,
                                     attribute:NSLayoutAttributeLeading,
                                     multiplier:1.0,
                                     constant:58.0))
    
    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem( 
                                          @labelDestinatario,
                                     attribute:NSLayoutAttributeTop,
                                     relatedBy:NSLayoutRelationEqual,
                                     toItem:self.contentView,
                                     attribute:NSLayoutAttributeTop,
                                     multiplier:1.0,
                                     constant:(20.0 / 2)));
    
    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem( 
                                                  @labelDestinatario,
                                     attribute:NSLayoutAttributeTrailing,
                                     relatedBy:NSLayoutRelationEqual,
                                     toItem:self.contentView,
                                     attribute:NSLayoutAttributeTrailing,
                                     multiplier:1.0,
                                     constant:-20.0))
    
    #### @labelNote
    
    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem(
                                          @labelNote,
                                      attribute:NSLayoutAttributeLeading,
                                      relatedBy:NSLayoutRelationEqual,
                                      toItem:self.contentView,
                                      attribute:NSLayoutAttributeLeading,
                                      multiplier:1.0,
                                      constant:58.0))
    
    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem(
                                          @labelNote,
                                      attribute:NSLayoutAttributeTop,
                                      relatedBy:NSLayoutRelationEqual,
                                      toItem:@labelDestinatario,
                                      attribute:NSLayoutAttributeBottom,
                                      multiplier:1.0,
                                      constant:(20.0 / 4)))
    
    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem(
                                            @labelNote,
                                      attribute:NSLayoutAttributeTrailing,
                                      relatedBy:NSLayoutRelationEqual,
                                      toItem:self.contentView,
                                      attribute:NSLayoutAttributeTrailing,
                                      multiplier:1.0,
                                      constant:-20.0))
    
    # self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem(
    #                                        @labelNote,
    #                                   attribute:NSLayoutAttributeBottom,
    #                                   relatedBy:NSLayoutRelationEqual,
    #                                   toItem:self.contentView,
    #                                   attribute:NSLayoutAttributeBottom,
    #                                   multiplier:1.0,
    #                                   constant:-15))
    
    #### @labelTotali

    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem(
                                          @labelTotali,
                                      attribute:NSLayoutAttributeLeading,
                                      relatedBy:NSLayoutRelationEqual,
                                      toItem:self.contentView,
                                      attribute:NSLayoutAttributeLeading,
                                      multiplier:1.0,
                                      constant:58.0))
    
    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem(
                                          @labelTotali,
                                      attribute:NSLayoutAttributeTop,
                                      relatedBy:NSLayoutRelationEqual,
                                      toItem:@labelNote,
                                      attribute:NSLayoutAttributeBottom,
                                      multiplier:1.0,
                                      constant:5))
    
    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem(
                                            @labelTotali,
                                      attribute:NSLayoutAttributeTrailing,
                                      relatedBy:NSLayoutRelationEqual,
                                      toItem:self.contentView,
                                      attribute:NSLayoutAttributeTrailing,
                                      multiplier:1.0,
                                      constant:-20.0))
    
    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem(
                                           @labelTotali,
                                      attribute:NSLayoutAttributeBottom,
                                      relatedBy:NSLayoutRelationEqual,
                                      toItem:self.contentView,
                                      attribute:NSLayoutAttributeBottom,
                                      multiplier:1.0,
                                      constant:-15))

    #### @imageStatus

    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem(
                                          @imageStatus,
                                      attribute:NSLayoutAttributeLeading,
                                      relatedBy:NSLayoutRelationEqual,
                                      toItem:self.contentView,
                                      attribute:NSLayoutAttributeLeading,
                                      multiplier:1.0,
                                      constant:15.0))
    
    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem(
                                          @imageStatus,
                                      attribute:NSLayoutAttributeCenterY,
                                      relatedBy:NSLayoutRelationEqual,
                                      toItem:self.contentView,
                                      attribute:NSLayoutAttributeCenterY,
                                      multiplier:1.0,
                                      constant:0))
   
    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem(
                                            @imageStatus,
                                      attribute:NSLayoutAttributeWidth,
                                      relatedBy:NSLayoutRelationEqual,
                                      toItem:@imageStatus,
                                      attribute:NSLayoutAttributeWidth,
                                      multiplier:1.0,
                                      constant:0))
    
    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem(
                                           @imageStatus,
                                      attribute:NSLayoutAttributeHeight,
                                      relatedBy:NSLayoutRelationEqual,
                                      toItem:@imageStatus,
                                      attribute:NSLayoutAttributeHeight,
                                      multiplier:1.0,
                                      constant:0))

    ### @imageCloud

    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem(
                                          @imageCloud,
                                      attribute:NSLayoutAttributeLeading,
                                      relatedBy:NSLayoutRelationEqual,
                                      toItem:self.contentView,
                                      attribute:NSLayoutAttributeLeading,
                                      multiplier:1.0,
                                      constant:15.0))
    
    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem(
                                          @imageCloud,
                                      attribute:NSLayoutAttributeTop,
                                      relatedBy:NSLayoutRelationEqual,
                                      toItem:self.contentView,
                                      attribute:NSLayoutAttributeTop,
                                      multiplier:1.0,
                                      constant:10))
   
    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem(
                                            @imageCloud,
                                      attribute:NSLayoutAttributeWidth,
                                      relatedBy:NSLayoutRelationEqual,
                                      toItem:@imageCloud,
                                      attribute:NSLayoutAttributeWidth,
                                      multiplier:1.0,
                                      constant:0))
    
    self.contentView.addConstraint( NSLayoutConstraint.constraintWithItem(
                                           @imageCloud,
                                      attribute:NSLayoutAttributeHeight,
                                      relatedBy:NSLayoutRelationEqual,
                                      toItem:@imageCloud,
                                      attribute:NSLayoutAttributeHeight,
                                      multiplier:1.0,
                                      constant:0))

    @didSetupConstraints = true

  end




end