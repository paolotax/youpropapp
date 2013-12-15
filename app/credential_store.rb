class CredentialStore

  attr_accessor :username, :password, :token

  def is_logged_in?
    return token != nil
  end


  def clear_saved_credential_store
    @token = nil
  end


  def token
    token = NSUserDefaults.standardUserDefaults.objectForKey "token"
    token
  end


  def token=(token)
    @token = token
    userDefaults = NSUserDefaults.standardUserDefaults.setObject @token, forKey:"token"
    userDefaults.synchronize  
  end


  def self.default
    @default ||= CredentialStore.new
  end


  def username
    username = NSUserDefaults.standardUserDefaults.objectForKey "username"
    username
  end


  def username=(username)
    @username = username
    userDefaults = NSUserDefaults.standardUserDefaults.setObject @username, forKey:"username"
    userDefaults.synchronize  
  end


  def password
    password = NSUserDefaults.standardUserDefaults.objectForKey "password"
    password
  end


  def password=(password)
    @password = password
    userDefaults = NSUserDefaults.standardUserDefaults.setObject @password, forKey:"password"
    userDefaults.synchronize  
  end



end