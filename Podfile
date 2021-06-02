# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'KnowPro' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for KnowPro
  pod 'BuddyBuildSDK'
  pod 'SwiftLint'
  pod 'RealmSwift'
  pod 'Contentful'
  pod 'ContentfulPersistenceSwift', git: 'https://github.com/ReticentJohn/contentful-persistence.swift.git', branch: 'master'
  pod 'Firebase/Core'
  pod 'Fabric', '~> 1.10.1'
  pod 'Crashlytics', '~> 3.13.1'
  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'
  pod 'Firebase/Firestore'
  pod 'Firebase/Auth'
  pod 'OneSignal', '>= 2.6.2', '< 3.0'
  pod 'SDWebImage'
  pod 'DateToolsSwift'
  pod 'SPLarkController'
  pod 'MXSegmentedControl'
  pod 'Lightbox'
  pod 'SRCountdownTimer', git: 'https://github.com/rsrbk/SRCountdownTimer.git', branch: 'master'
  pod 'DTOverlayController'
  pod 'AAPickerView'
  pod 'TPKeyboardAvoiding'
  pod 'PhoneNumberKit'
  pod 'Validator'
  pod 'Atributika'
  pod 'Flurry-iOS-SDK/FlurrySDK'
  pod 'OpenGraph'
  pod 'FavIcon', '~> 3.0.0'
  
  target 'KnowProTests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'OneSignalNotificationServiceExtension' do
      pod 'OneSignal', '>= 2.6.2', '< 3.0'
  end
  
  post_install do | installer |
    
      installer.pods_project.targets.each do |target|
        if target.name == 'SPLarkController' || target.name == 'Lightbox'
          target.build_configurations.each do |config|
            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
          end
        end
      end
      
      require 'fileutils'
      FileUtils.cp_r('Pods/Target Support Files/Pods-KnowPro/Pods-KnowPro-Acknowledgements.plist', 'KnowPro/Supporting Files/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
  end

end
