platform :ios, '12.4'
use_frameworks!

target 'uchicock' do
    pod 'RealmSwift'
end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-uchicock/Pods-uchicock-acknowledgements.plist', 'uchicock/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
