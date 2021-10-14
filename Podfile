# Uncomment the next line to define a global platform for your project
#platform :ios, '9.0'

target 'Friendzr' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for Friendzr
  pod 'Alamofire', '~> 5.4'
  pod 'SDWebImage'
  pod 'ObjectMapper'
  pod 'FBSDKLoginKit'
  pod 'Firebase'
  pod 'Firebase/Auth'
  pod 'Firebase/Crashlytics'
  pod 'GoogleSignIn'
  pod 'Firebase/Messaging'
  pod 'Firebase/Database'
  pod 'Firebase/Analytics'
  pod 'Firebase/Storage'
  pod 'IQKeyboardManager'
  pod 'Firebase/Firestore'

  pod 'GoogleMaps'
  pod 'GooglePlaces'
  
  pod 'MultiSlider'
  
  pod 'MessageKit'
#  pod 'Kingfisher', '~> 6.0'
  #  pod 'DropDown'
  #  pod 'SkyFloatingLabelTextField', '~> 3.0'
  #  pod 'JGProgressHUD'
  
  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
  
end
