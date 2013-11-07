class EditTextViewController < UIViewController

  extend IB

  attr_accessor :testo

  outlet :textView
  outlet :textField

  attr_accessor :textChangedBlock

  def viewDidLoad
    super

    self.navigationItem.setLeftBarButtonItem(UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCancel, target:self, action:"cancel:"))
  
    # if (![[self navigationItem] rightBarButtonItem]) {
    #   [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)]];
  end
  


  def viewWillAppear(animated)
    super
    if self.textView
      self.textView.text = @testo
      self.textView.becomeFirstResponder
    else
      self.textField.text = @testo
      self.textField.becomeFirstResponder
    end
  end
  
  def handleTextCompletion

    if (self.textView)
      text = self.textView.text
    else 
      text = self.textField.text
    end
  
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


end