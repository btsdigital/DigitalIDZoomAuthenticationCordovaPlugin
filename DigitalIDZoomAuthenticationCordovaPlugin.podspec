Pod::Spec.new do |s|
  s.name                  = 'DigitalIDZoomAuthenticationCordovaPlugin'
  s.version               = '0.4.1'
  s.summary               = 'DigitalID FaceTech SDK iOS cordova plugin'
  s.description           = <<-DESC
The cordova plugin for Zoom SDK framework integration
                       DESC
  s.license               = 'MIT'
  s.homepage              = 'https://digital-id.kz'
  s.author                = { 'DigitalID' => 'almas.adilbek@btsdigital.kz' }
  s.source                = { :git => 'https://github.com/btsdigital/DigitalIDZoomAuthenticationCordovaPlugin.git', :tag => "v#{s.version}" }
  s.source_files          = ['DigitalIDZoomAuthenticationCordovaPlugin/*.{h,m}']
  s.ios.vendored_frameworks   = 'FaceTecSDK.framework'
  s.resources             = "DigitalIDZoomAuthenticationCordovaPlugin/*.xcassets"
  s.dependency          'Cordova'
  s.user_target_xcconfig  = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.pod_target_xcconfig   = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.ios.deployment_target = '11.0'
end
