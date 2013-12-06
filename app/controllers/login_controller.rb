class LoginController < Formotion::FormController
  
  PERSIST_AS = :account_settings
  USERNAME = 'paolotax'
  PASSWORD = 'sisboccia'


  def init
    form = Formotion::Form.new({
      title: "Login",
      persist_as: PERSIST_AS,
      sections: [{
        rows: [{
          title: "Nome utente",
          type: :string,
          placeholder: "nome",
          key: :username,
          value: USERNAME,
          auto_correction: :no,
          auto_capitalization: :none
        }, {
          title: "Password",
          type: :string,
          placeholder: "password",
          key: :password,
          secure: true,
          value: PASSWORD,
          auto_correction: :no,
          auto_capitalization: :none
        }]
      }, {
        rows: [{
          title: "Login",
          type: :submit,
        }]
      }]
    })
    form.on_submit do
      self.login
    end
    super.initWithForm(form)
  end

  def viewDidLoad
    super
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithTitle("Login", style: UIBarButtonItemStyleDone, target:self, action:'login')
  end

  def login
    [:username, :password].each { |prop|
      Store.shared.send(prop.to_s + "=", form.render[prop])
    }

    self.navigationController.dismissModalViewControllerAnimated(true)
  end
end