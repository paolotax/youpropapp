class EditTextFieldController < UIViewController


  attr_accessor :textChangedBlock


  def initWithType(fieldType)
    self.init
    @fieldType = fieldType
    self
  end


  def viewDidLoad
    super
    
    self.view.backgroundColor = UIColor.darkGrayColor
    self.navigationItem.leftBarButtonItem = UIBarButtonItem.cancel do |button|
      cancel(button) 
    end
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.done do |button|
      done(button)
    end

    if @fieldType == TextFieldTypeDecimal
      @margin = 100
    elsif @fieldType == TextFieldTypeLongString
      @margin = 20
    else
      @margin = 100
    end

    Motion::Layout.new do |layout|
      layout.view view
      layout.subviews "text_label" => text_label, 
                      "text_field"  => text_field
      layout.metrics "margin" => @margin
      layout.horizontal "|-8-[text_label]-8-|"
      layout.horizontal "|-margin-[text_field]-margin-|"
      layout.vertical "|-80-[text_label]-8-[text_field]"
    end

    NSLog("constraints: %@", self.view.constraints)

  end
  

  def viewWillAppear(animated)
    super    
    text_field.becomeFirstResponder
  end

  
  def load_data(data, withLabel:label)
    text_field.text = data
    text_label.text = label 
  end


  # def updateConstraints
  #   puts "update"
  #   super
  #   return if @didSetupConstraints


  #   @didSetupConstraints = true

  # end

#pragma mark - Layout


  def text_label
    @text_label ||= begin
      @text_label = UILabel.new
      @text_label.textAlignment = UITextAlignmentCenter
      @text_label.color = UIColor.whiteColor
      @text_label
    end
  end


  def text_field
    @text_field ||= begin
      @text_field = UITextField.new
      @text_field.delegate = self
      @text_field.borderStyle = UITextBorderStyleRoundedRect
      # non funziona
      # @text_field.adjustsFontSizeToFitWidth = true
      # @text_field.minimumFontSize = 8.0
      # @text_field.textColor = UIColor.blackColor
      if @fieldType == TextFieldTypeDecimal
        @text_field.keyboardType = UIKeyboardTypeDecimalPad 
        @text_field.textAlignment = UITextAlignmentRight
      end
      @text_field
    end
  end


#pragma mark - Actions


  def handleTextCompletion

    text = @text_field.text
  
    error = Pointer.new(:object)
    success = @textChangedBlock.call(text, error)
    if (success) 
      self.navigationController.popViewControllerAnimated(true)
      return true
    else
      alertView = UIAlertView.alloc.initWithTitle("Error", message:error.localizedDescription, delegate:nil, cancelButtonTitle:"Chiudi", otherButtonTitles:nil);
      alertView.show
      return false
    end
  end 


  def done(sender)
    self.handleTextCompletion
  end
  

  def cancel(sender)
    self.navigationController.popViewControllerAnimated(true)
  end


#pragma mark - UITextFieldDelegate

 
  def textFieldShouldReturn(textField)
    return self.handleTextCompletion
  end


  def textFieldDidBeginEditing(textField)
    
    if @fieldType == TextFieldTypeDecimal
      textField.selectAll self
    end
    #textField.setSelectedTextRange(@text_field.textRangeFromPosition(@text_field.beginningOfDocument, toPosition:@text_field.endOfDocument))
  end



end