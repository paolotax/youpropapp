class UserAuthenticator

  APP_ID = "36e1b9ed802dc7ee45e375bf318924dc3ae0f0f842c690611fde8336687960eb"
  SECRET = "11ab577f8fabf2ac33bdd75e951fc6507ef7bc21ef993c2a77a1383bed438224"


  def loginWithUsername(username, password:password, success:success, failure:failure)

    params = {
      grant_type: 'password',
      client_id: APP_ID,
      client_secret: SECRET,
      username: username,
      password: password
    }
    
    Store.shared.client.postPath("oauth/token?expires_in=10",
                           parameters:params,
                              success:lambda do |operation, responseObject|

                                token = responseObject.objectForKey "access_token"
                                puts "token=#{token}"
                                CredentialStore.default.token = token
                                CredentialStore.default.username = username
                                CredentialStore.default.password = password

                                Store.shared.set_token_header
                                success.call
                              end,
                              failure:lambda do |operation, error|
                                puts "failure login"
                                failure.call
                                # if (operation.response.statusCode == 500)
                                #    failure.call("Something went wrong!")
                                # else
                                #   failure.call(self.errorMessageForResponse(operation))
                                # end
                              end
    )
  end    


  def refreshTokenAndRetryOperation(operation, withNotification:notification, 
                                                        success:success, 
                                                        failure:failure)

    username = CredentialStore.default.username
    password = CredentialStore.default.password
    
    puts "#{username} - #{password}"
    self.loginWithUsername(username,
                   password:password,
                    success:lambda do 
                      NSLog("RETRYING REQUEST #{operation}")
                      
                      retryOperation = self.retryOperationForOperation(operation.HTTPRequestOperation)
                      #retryOperation.setCompletionBlockWithSuccess(lambda do success.call end, failure:lambda do failure.call end)
                      # retryOperation.start
                      # success.call
                      
                      "#{notification}".post_notification

                    end,
                    failure:lambda do
                      failure.call
                    end)
  end


  def retryOperationForOperation(operation)
    request = operation.request.mutableCopy
    request.addValue(nil, forHTTPHeaderField:"Authorization")
    request.addValue("Bearer #{CredentialStore.default.token}", forHTTPHeaderField:"Authorization")   
    retryOperation = AFHTTPRequestOperation.alloc.initWithRequest(request)
    retryOperation
  end


  def errorMessageForResponse(operation)
    jsonData = operation.responseString.dataUsingEncoding(NSUTF8StringEncoding)
    json = NSJSONSerialization.JSONObjectWithData(jsonData, options:0, error:nil)
    errorMessage = json.objectForKey "error"
    errorMessage
  end


end
