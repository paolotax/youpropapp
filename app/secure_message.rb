class SecureMessage


  def init
    super
    if self
      @credentialStore = CredentialStore.new
    end
    self
  end


  def errorMessageForResponse(operation)
    jsonData = operation.responseString.dataUsingEncoding(NSUTF8StringEncoding)
    json = NSJSONSerialization.JSONObjectWithData(jsonData, options:0, error:nil)
    errorMessage = json.objectForKey "error"
    errorMessage
  end


  def fetchSecureMessageWithSuccess(success, failure:failure)
    
    processSuccessBlock = lambda do |operation, responseObject|
      success.call(operation.responseString)
    end
    
    processFailureBlock = lambda do |operation, error|
      if (operation.response.statusCode == 500)
        failure.call("Something went wrong!")
      else
        errorMessage = self.errorMessageForResponse operation
        failure.call(errorMessage)
      end
    end
    
    Store.shared.client.getPath("/home/index.json",
                               parameters:nil,
                                  success:lambda do |operation, responseObject|
                                    processSuccessBlock.call(operation, responseObject)
                                  end,
                                  failure:lambda do |operation, error|
                                    processFailureBlock.call(operation, error)
                                    if (operation.response.statusCode == 401)
                                      @credentialStore.token = nil
                                      auth = UserAuthenticator.new
                                      auth.refreshTokenAndRetryOperation(operation,
                                                    success:processSuccessBlock.call,
                                                    failure:processFailureBlock.call)
                                    end
                                  end)
  end

end