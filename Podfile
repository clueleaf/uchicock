platform :ios, '8.0'
use_frameworks!

pod 'RealmSwift'
pod 'ChameleonFramework/Swift'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-acknowledgements.plist', 'uchicock/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end