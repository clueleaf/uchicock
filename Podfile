platform :ios, '11.0'
use_frameworks!

target 'uchicock' do
    pod 'RealmSwift'
    pod 'SVProgressHUD'
    pod 'M13Checkbox'
end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-uchicock/Pods-uchicock-acknowledgements.plist', 'uchicock/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
