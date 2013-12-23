class LoginController < Formotion::FormController
  
  PERSIST_AS = :credentials
  USERNAME = ''
  PASSWORD = ''


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


  def login
    [:username, :password].each { |prop|
      CredentialStore.default.send(prop.to_s + "=", form.render[prop])
    }
    self.navigationController.dismissModalViewControllerAnimated(true)
  end
  
end