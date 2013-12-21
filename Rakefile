# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'youpropa'

  app.testflight.sdk = 'vendor/TestFlight'
  app.testflight.notify = true
  app.testflight.api_token = '4e21427afeec172a9cedd0a7497f07e6_MTM5Nzc5NjIwMTMtMTAtMjQgMTU6NDU6MDYuMDg3NjQ3'
  app.testflight.team_token = '4d2966676a3fe25f3d318c7ee1ed0685_MjkwNzQ0MjAxMy0xMi0wNSAwMjoyOTo1OC45MzQyNTQ'

  app.provisioning_profile = '/Users/paolotax/Library/MobileDevice/Provisioning Profiles/58A8231D-46DF-4CA2-AA65-1693F1770193.mobileprovision'   
  app.codesign_certificate = 'iPhone Developer: Paolo Tassinari (9L6JUZD52Q)' 

  app.device_family = [:iphone, :ipad]

  app.interface_orientations = [:portrait]

  app.frameworks << 'QuartzCore'
  app.frameworks << 'MapKit'
  app.frameworks << 'CoreLocation'
  app.frameworks << 'AVFoundation'
  app.frameworks << 'AudioToolbox'

  app.info_plist['UIViewControllerBasedStatusBarAppearance'] = true
  app.info_plist['UIStatusBarHidden'] = true
  
  app.pods do
    pod 'RNFrostedSidebar'
    pod 'RestKit'
    pod 'CustomBadge'
    pod 'HTAutocompleteTextField'
    pod 'SVProgressHUD'
    pod 'Reachability'
  end


end
