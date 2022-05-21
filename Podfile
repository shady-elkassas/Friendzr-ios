# Uncomment the next line to define a global platform for your project
#platform :ios, '9.0'

target 'Friendzr' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for Friendzr
  
  pod 'Alamofire', '~> 5.4'
  pod 'ObjectMapper'

  pod 'FBSDKLoginKit'
  pod 'GoogleSignIn'
  #  pod 'SnapSDK', :subspecs => ['SCSDKLoginKit', 'SCSDKCreativeKit', 'SCSDKBitmojiKit']
  #  pod 'TikTokOpenSDK', '~> 5.0.0'

  pod 'Firebase'
  pod 'Firebase/Auth'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Messaging'
  pod 'Firebase/Database'
  pod 'Firebase/Analytics'
  pod 'Firebase/Storage'
  pod 'Firebase/Firestore'

  pod 'MessageKit', '~> 3.5.1'
  pod 'IQKeyboardManager'
  pod 'SDWebImage'
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'MultiSlider'
  pod 'ListPlaceholder'
  pod 'RevealingSplashView'

  pod 'QCropper'

  pod 'AWSRekognition'

  pod 'Google-Mobile-Ads-SDK'
  pod 'GoogleMobileAdsMediationAppLovin'
  pod 'GoogleMobileAdsMediationFyber'
  pod 'GoogleMobileAdsMediationInMobi'
  pod 'GoogleMobileAdsMediationFacebook'
  
  pod "AppsFlyerFramework"

#  pod 'GoogleMobileAdsMediationTestSuite'
  
  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
  
end
