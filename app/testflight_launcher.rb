# This file is automatically generated. Do not edit.

if Object.const_defined?('TestFlight') and !UIDevice.currentDevice.model.include?('Simulator')
  NSNotificationCenter.defaultCenter.addObserverForName(UIApplicationDidBecomeActiveNotification, object:nil, queue:nil, usingBlock:lambda do |notification|
  
  TestFlight.takeOff('4d2966676a3fe25f3d318c7ee1ed0685_MjkwNzQ0MjAxMy0xMi0wNSAwMjoyOTo1OC45MzQyNTQ')
  end)
end
