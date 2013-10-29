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
  app.name = 'prova'

  app.provisioning_profile = '/Users/paolotax/Library/MobileDevice/Provisioning Profiles/B4A21FC2-6865-42E5-A2D3-FDA9D939F1A9.mobileprovision' 
  
  app.codesign_certificate = 'iPhone Developer: Paolo Tassinari (9L6JUZD52Q)' 

  app.device_family = [:iphone, :ipad]

  app.frameworks << 'QuartzCore'

  app.info_plist['UIViewControllerBasedStatusBarAppearance'] = true
  
  app.pods do
    pod 'NVSlideMenuController'
    pod 'RestKit'
    pod 'CustomBadge'
  end


end
