# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Messenger' do
  use_frameworks!

# Firebase
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Storage'

# Facebook
pod 'FBSDKLoginKit'

# Google Sign IN
pod 'GoogleSignIn'


pod 'MessageKit'
pod 'JGProgressHUD'
pod 'RealmSwift'
pod 'RealmSwift'
pod 'RealmSwift'
pod 'SDWebImage'


end

post_install do |installer|
  # fix xcode 15 DT_TOOLCHAIN_DIR - remove after fix oficially - https://github.com/CocoaPods/CocoaPods/issues/12065
  installer.aggregate_targets.each do |target|
      target.xcconfigs.each do |variant, xcconfig|
      xcconfig_path = target.client_root + target.xcconfig_relative_path(variant)
      IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
      end
  end

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.base_configuration_reference.is_a? Xcodeproj::Project::Object::PBXFileReference
          xcconfig_path = config.base_configuration_reference.real_path
          IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
      end
    end
    
    installer.generated_projects.each do |project|
              project.targets.each do |target|
                  target.build_configurations.each do |config|
                      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
                   end
              end
       end
    
  end
end
