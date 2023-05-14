# Uncomment the next line to define a global platform for your project
#platform :ios, '9.0'

target 'Friendzr' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for Friendzr
  
  pod 'Alamofire', '~> 5.4'
  pod 'ObjectMapper'
  
  pod 'FBSDKLoginKit', '~> 11.1.0'
  pod 'GoogleSignIn'
  
  pod 'Firebase'
  pod 'Firebase/Auth'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Messaging'
  pod 'Firebase/Database'
  pod 'Firebase/Analytics'
  pod 'Firebase/Storage'
  pod 'Firebase/Firestore'
  pod 'Firebase/DynamicLinks'
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
  pod 'AppsFlyerFramework'
  pod 'MSImagePickerSheetController'
  pod 'AMShimmer'
  pod 'ImageSlideshow', '~> 1.9.0'
  pod "TLPhotoPicker"
  pod "ImageSlideshow/SDWebImage"
  
#  post_install do |installer|
#    installer.pods_project.build_configurations.each do |config|
#      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
#    end
#  end
  
  #  post_install do |installer|
  #    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
  #      configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
  #    end
  #  end
  
  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
      end
    end
  end
  
end
