platform :ios, '9.0'
use_frameworks!

pod 'RealmSwift'
pod 'ChameleonFramework/Swift'
pod 'DZNEmptyDataSet'
pod 'IDMPhotoBrowser'
pod 'SVProgressHUD'
pod 'M13Checkbox'
pod 'iVersion'
pod 'MJRefresh'
pod 'MYBlurIntroductionView'

def testing_pods
    pod 'Quick'
    pod 'Nimble'
end

target 'uchicockTests' do
    testing_pods
end

target 'uchicockUITests' do
    testing_pods
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-acknowledgements.plist', 'uchicock/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end