Pod::Spec.new do |s|
  s.name             = 'DigitalIDZoomAuthenticationCordovaPlugin'
  s.version          = '0.1.1'
  s.summary          = 'DigitalID FaceTech SDK iOS cordova plugin'
  s.description      = <<-DESC
The cordova plugin for Zoom SDK framework integration
                       DESC
  s.license          = 'MIT'
  s.homepage         = 'https://digital-id.kz'
  s.author           = { 'DigitalID' => 'almas.adilbek@btsdigital.kz' }
  s.source           = { :git => 'https://github.com/btsdigital/DigitalIDZoomAuthenticationCordovaPlugin.git', :tag => "v#{s.version}" }
  s.source_files     = ['DigitalIDZoomAuthenticationCordovaPlugin/*.{h,m}']
  s.vendored_frameworks = 'FaceTecSDK.framework'
  s.dependency         'Cordova'
  s.resource         = 'DigitalIDZoomAuthenticationCordovaPlugin/FaceTec.strings'

  s.ios.deployment_target = '11.0'
end
