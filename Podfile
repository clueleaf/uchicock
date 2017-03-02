platform :ios, '9.0'
use_frameworks!

target 'uchicock' do
    pod 'RealmSwift'
    pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
    pod 'DZNEmptyDataSet'
    pod 'IDMPhotoBrowser'
    pod 'SVProgressHUD', '2.0.3'
    pod 'M13Checkbox'
    pod 'iVersion'
    pod 'MJRefresh'
    pod 'MYBlurIntroductionView'
end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-uchicock/Pods-uchicock-acknowledgements.plist', 'uchicock/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
