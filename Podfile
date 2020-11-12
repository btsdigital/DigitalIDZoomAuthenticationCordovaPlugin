platform :ios, '11.0'

target 'DigitalIDZoomAuthenticationCordovaPlugin' do
  use_frameworks!

  pod 'Cordova'

end

post_install do |installer|
 installer.pods_project.targets.each do |target|
   target.build_configurations.each do |config|
     config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
   end
 end
end
