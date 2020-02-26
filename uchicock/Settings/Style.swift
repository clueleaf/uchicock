//
//  Style.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/02/27.
//  Copyright © 2017年 Kou. All rights reserved.
//

import Foundation
import UIKit

struct UchicockStyle{
    static var no = "0"
    static var isDark = false
    static var isBackgroundDark = false
    static var messageHudStyle: MessageHUDStyle = .dark
    static var statusBarStyle: UIStatusBarStyle = .default
    static var navigationBarColor = FlatColor.yellow
    static var primaryColor = FlatColor.skyBlueDark
    static var basicBackgroundColor = FlatColor.white
    static var tableViewHeaderBackgroundColor = FlatColor.whiteDark
    static var tableViewHeaderTextColor = FlatColor.black
    static var tableViewCellSelectedBackgroundColor = FlatColor.whiteDark
    static var tableViewCellEditBackgroundColor = FlatColor.gray
    static var labelTextColor = FlatColor.black
    static var labelTextColorLight = FlatColor.grayDark
    static var labelTextColorOnBadge = FlatColor.white
    static var filterContainerBackgroundColor = FlatColor.sand
    static var deleteColor = FlatColor.red
    static var tabBarTintColor = FlatColor.orange
    static var tabBarBarTintColor = FlatColor.white
    static var tabBarUnselectedItemTintColor = FlatColor.gray
    static var textFieldBorderColor = FlatColor.whiteDark
    static var badgeBackgroundColor = FlatColor.red

    // MARK: - Define Theme
    static func tequilaSunriseLight(){
        no = "0"
        isDark = false
        isBackgroundDark = false
        messageHudStyle = .dark
        statusBarStyle = .default
        navigationBarColor = FlatColor.yellow
        primaryColor = FlatColor.skyBlueDark
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        filterContainerBackgroundColor = FlatColor.sand
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.orange
        tabBarBarTintColor = FlatColor.white
        tabBarUnselectedItemTintColor = FlatColor.gray
        textFieldBorderColor = FlatColor.whiteDark
        badgeBackgroundColor = FlatColor.red
    }
    
    static func tequilaSunriseDark(){
        no = "1"
        isDark = true
        isBackgroundDark = true
        messageHudStyle = .dark
        statusBarStyle = .default
        navigationBarColor = FlatColor.yellow
        primaryColor = FlatColor.yellowDark
        basicBackgroundColor = FlatColor.black
        tableViewHeaderBackgroundColor = FlatColor.grayDark
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.65, green:0.4, blue:0.0, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = FlatColor.black
        filterContainerBackgroundColor = FlatColor.black
        deleteColor = FlatColor.watermelonDark
        tabBarTintColor = FlatColor.white
        tabBarBarTintColor = FlatColor.yellowDark
        tabBarUnselectedItemTintColor = FlatColor.black
        textFieldBorderColor = FlatColor.grayDark
        badgeBackgroundColor = FlatColor.red
    }
    
    static func seaBreezeLight(){
        no = "2"
        isDark = false
        isBackgroundDark = false
        messageHudStyle = .dark
        statusBarStyle = .default
        navigationBarColor = FlatColor.pink
        primaryColor = FlatColor.pink
        basicBackgroundColor = UIColor(red:1.0, green:0.95, blue:1.0, alpha:1.0)
        tableViewHeaderBackgroundColor = FlatColor.white
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.97, green:0.8, blue:0.93, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = UIColor(red:1.0, green:0.95, blue:1.0, alpha:1.0)
        filterContainerBackgroundColor = UIColor(red:1.0, green:0.95, blue:1.0, alpha:1.0)
        deleteColor = FlatColor.red
        tabBarTintColor = UIColor(red:0.35, green:0.2, blue:0.3, alpha:1.0)
        tabBarBarTintColor = FlatColor.pink
        tabBarUnselectedItemTintColor = UIColor(red:1.0, green:0.95, blue:1.0, alpha:1.0)
        textFieldBorderColor = FlatColor.whiteDark
        badgeBackgroundColor = FlatColor.red
    }
    
    static func seaBreezeDark(){
        no = "3"
        isDark = true
        isBackgroundDark = true
        messageHudStyle = .light
        statusBarStyle = .lightContent
        navigationBarColor = FlatColor.pinkDark
        primaryColor = FlatColor.pinkDark
        basicBackgroundColor = FlatColor.blackDark
        tableViewHeaderBackgroundColor = FlatColor.grayDark
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.3, green:0.3, blue:0.3, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = FlatColor.white
        filterContainerBackgroundColor = FlatColor.blackDark
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.white
        tabBarBarTintColor = FlatColor.pinkDark
        tabBarUnselectedItemTintColor = FlatColor.black
        textFieldBorderColor = FlatColor.grayDark
        badgeBackgroundColor = FlatColor.red
    }

    static func chinaBlueLight(){
        no = "4"
        isDark = false
        isBackgroundDark = false
        messageHudStyle = .dark
        statusBarStyle = .lightContent
        navigationBarColor = FlatColor.skyBlue
        primaryColor = FlatColor.skyBlue
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        filterContainerBackgroundColor = FlatColor.white
        deleteColor = FlatColor.red
        tabBarTintColor = UIColor(red:0.2, green:0.2, blue:0.3, alpha:1.0)
        tabBarBarTintColor = FlatColor.skyBlue
        tabBarUnselectedItemTintColor = FlatColor.white
        textFieldBorderColor = FlatColor.whiteDark
        badgeBackgroundColor = FlatColor.red
    }

    static func chinaBlueDark(){
        no = "5"
        isDark = true
        isBackgroundDark = true
        messageHudStyle = .light
        statusBarStyle = .lightContent
        navigationBarColor = FlatColor.skyBlueDark
        primaryColor = FlatColor.skyBlueDark
        basicBackgroundColor = FlatColor.black
        tableViewHeaderBackgroundColor = FlatColor.grayDark
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.3, green:0.3, blue:0.3, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = FlatColor.white
        filterContainerBackgroundColor = FlatColor.black
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.white
        tabBarBarTintColor = FlatColor.skyBlueDark
        tabBarUnselectedItemTintColor = FlatColor.black
        textFieldBorderColor = FlatColor.grayDark
        badgeBackgroundColor = FlatColor.red
    }

    static func grasshopperLight(){
        no = "6"
        isDark = false
        isBackgroundDark = false
        messageHudStyle = .dark
        statusBarStyle = .lightContent
        navigationBarColor = FlatColor.mint
        primaryColor = FlatColor.mintDark
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        filterContainerBackgroundColor = FlatColor.mint
        deleteColor = FlatColor.watermelon
        tabBarTintColor = FlatColor.black
        tabBarBarTintColor = FlatColor.mint
        tabBarUnselectedItemTintColor = FlatColor.white
        textFieldBorderColor = FlatColor.whiteDark
        badgeBackgroundColor = FlatColor.red
    }

    static func irishCoffeeDark(){
        no = "7"
        isDark = true
        isBackgroundDark = true
        messageHudStyle = .light
        statusBarStyle = .lightContent
        navigationBarColor = FlatColor.coffeeDark
        primaryColor = FlatColor.coffee
        basicBackgroundColor = FlatColor.black
        tableViewHeaderBackgroundColor = FlatColor.grayDark
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = FlatColor.coffeeDark
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = FlatColor.white
        filterContainerBackgroundColor = FlatColor.black
        deleteColor = FlatColor.watermelonDark
        tabBarTintColor = FlatColor.white
        tabBarBarTintColor = FlatColor.coffeeDark
        tabBarUnselectedItemTintColor = FlatColor.black
        textFieldBorderColor = FlatColor.grayDark
        badgeBackgroundColor = FlatColor.red
    }
    
    static func mojitoLight(){
        no = "8"
        isDark = false
        isBackgroundDark = false
        messageHudStyle = .dark
        statusBarStyle = .default
        navigationBarColor = FlatColor.white
        primaryColor = FlatColor.mint
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        filterContainerBackgroundColor = FlatColor.white
        deleteColor = FlatColor.watermelonDark
        tabBarTintColor = FlatColor.mint
        tabBarBarTintColor = FlatColor.white
        tabBarUnselectedItemTintColor = FlatColor.gray
        textFieldBorderColor = FlatColor.whiteDark
        badgeBackgroundColor = FlatColor.red
    }
    
    static func redEyeLight(){
        no = "9"
        isDark = false
        isBackgroundDark = false
        messageHudStyle = .dark
        statusBarStyle = .lightContent
        navigationBarColor = FlatColor.watermelonDark
        primaryColor = FlatColor.watermelon
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:1.0, green:0.7, blue:0.75, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        filterContainerBackgroundColor = FlatColor.white
        deleteColor = FlatColor.redDark
        tabBarTintColor = FlatColor.black
        tabBarBarTintColor = FlatColor.watermelonDark
        tabBarUnselectedItemTintColor = FlatColor.white
        textFieldBorderColor = FlatColor.whiteDark
        badgeBackgroundColor = FlatColor.red
    }
    
    static func cubaLibreDark(){
        no = "10"
        isDark = true
        isBackgroundDark = true
        messageHudStyle = .light
        statusBarStyle = .default
        navigationBarColor = FlatColor.limeDark
        primaryColor = FlatColor.limeDark
        basicBackgroundColor = FlatColor.black
        tableViewHeaderBackgroundColor = FlatColor.grayDark
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.3, green:0.35, blue:0.1, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = FlatColor.black
        filterContainerBackgroundColor = FlatColor.black
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.white
        tabBarBarTintColor = FlatColor.limeDark
        tabBarUnselectedItemTintColor = FlatColor.blackDark
        textFieldBorderColor = FlatColor.grayDark
        badgeBackgroundColor = FlatColor.red
    }
    
    static func silverWingLight(){
        no = "11"
        isDark = false
        isBackgroundDark = false
        messageHudStyle = .dark
        statusBarStyle = .lightContent
        navigationBarColor = FlatColor.grayDark
        primaryColor = FlatColor.grayDark
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        filterContainerBackgroundColor = FlatColor.whiteDark
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.black
        tabBarBarTintColor = FlatColor.grayDark
        tabBarUnselectedItemTintColor = FlatColor.white
        textFieldBorderColor = FlatColor.whiteDark
        badgeBackgroundColor = FlatColor.red
    }
    
    static func americanLemonadeDark(){
        no = "12"
        isDark = false
        isBackgroundDark = true
        messageHudStyle = .light
        statusBarStyle = .lightContent
        navigationBarColor = FlatColor.watermelonDark
        primaryColor = FlatColor.watermelonDark
        basicBackgroundColor = FlatColor.black
        tableViewHeaderBackgroundColor = FlatColor.grayDark
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.3, green:0.33, blue:0.33, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = FlatColor.white
        filterContainerBackgroundColor = FlatColor.black
        deleteColor = FlatColor.watermelonDark
        tabBarTintColor = FlatColor.watermelonDark
        tabBarBarTintColor = FlatColor.white
        tabBarUnselectedItemTintColor = FlatColor.black
        textFieldBorderColor = FlatColor.grayDark
        badgeBackgroundColor = FlatColor.red
    }
    
    static func blueLagoonLight(){
        no = "13"
        isDark = false
        isBackgroundDark = false
        messageHudStyle = .light
        statusBarStyle = .lightContent
        navigationBarColor = UIColor.black
        primaryColor = FlatColor.skyBlueDark
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        filterContainerBackgroundColor = FlatColor.white
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.skyBlueDark
        tabBarBarTintColor = UIColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        textFieldBorderColor = FlatColor.whiteDark
        badgeBackgroundColor = FlatColor.red
    }
    
    static func blueLagoonDark(){
        no = "14"
        isDark = true
        isBackgroundDark = true
        messageHudStyle = .light
        statusBarStyle = .lightContent
        navigationBarColor = FlatColor.black
        primaryColor = FlatColor.skyBlueDark
        basicBackgroundColor = UIColor.black
        tableViewHeaderBackgroundColor = FlatColor.blackDark
        tableViewHeaderTextColor = FlatColor.white
        tableViewCellSelectedBackgroundColor = FlatColor.black
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = UIColor.black
        filterContainerBackgroundColor = UIColor.black
        deleteColor = FlatColor.redDark
        tabBarTintColor = FlatColor.skyBlueDark
        tabBarBarTintColor = FlatColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        textFieldBorderColor = FlatColor.grayDark
        badgeBackgroundColor = FlatColor.red
    }
    
    static func mimosaLight(){
        no = "15"
        isDark = false
        isBackgroundDark = false
        messageHudStyle = .light
        statusBarStyle = .lightContent
        navigationBarColor = UIColor.black
        primaryColor = FlatColor.orange
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        filterContainerBackgroundColor = FlatColor.white
        deleteColor = FlatColor.redDark
        tabBarTintColor = FlatColor.orange
        tabBarBarTintColor = UIColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        textFieldBorderColor = FlatColor.whiteDark
        badgeBackgroundColor = FlatColor.red
    }
    
    static func mimosaDark(){
        no = "16"
        isDark = true
        isBackgroundDark = true
        messageHudStyle = .light
        statusBarStyle = .lightContent
        navigationBarColor = FlatColor.black
        primaryColor = FlatColor.yellowDark
        basicBackgroundColor = UIColor.black
        tableViewHeaderBackgroundColor = FlatColor.blackDark
        tableViewHeaderTextColor = FlatColor.white
        tableViewCellSelectedBackgroundColor = FlatColor.black
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = UIColor.black
        filterContainerBackgroundColor = UIColor.black
        deleteColor = FlatColor.redDark
        tabBarTintColor = FlatColor.yellowDark
        tabBarBarTintColor = FlatColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        textFieldBorderColor = FlatColor.grayDark
        badgeBackgroundColor = FlatColor.red
    }

    static func pinkLadyLight(){
        no = "17"
        isDark = false
        isBackgroundDark = false
        messageHudStyle = .light
        statusBarStyle = .lightContent
        navigationBarColor = UIColor.black
        primaryColor = FlatColor.pink
        basicBackgroundColor = UIColor(red:1.0, green:0.95, blue:1.0, alpha:1.0)
        tableViewHeaderBackgroundColor = FlatColor.white
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.97, green:0.8, blue:0.93, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = UIColor(red:1.0, green:0.95, blue:1.0, alpha:1.0)
        filterContainerBackgroundColor = UIColor(red:1.0, green:0.95, blue:1.0, alpha:1.0)
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.pinkDark
        tabBarBarTintColor = UIColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        textFieldBorderColor = FlatColor.whiteDark
        badgeBackgroundColor = FlatColor.red
    }
    
    static func pinkLadyDark(){
        no = "18"
        isDark = true
        isBackgroundDark = true
        messageHudStyle = .light
        statusBarStyle = .lightContent
        navigationBarColor = FlatColor.black
        primaryColor = FlatColor.pinkDark
        basicBackgroundColor = UIColor.black
        tableViewHeaderBackgroundColor = FlatColor.blackDark
        tableViewHeaderTextColor = FlatColor.white
        tableViewCellSelectedBackgroundColor = FlatColor.black
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = UIColor.black
        filterContainerBackgroundColor = UIColor.black
        deleteColor = FlatColor.redDark
        tabBarTintColor = FlatColor.pinkDark
        tabBarBarTintColor = FlatColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        textFieldBorderColor = FlatColor.grayDark
        badgeBackgroundColor = FlatColor.red
    }
    
    static func blackRussianDark(){
        no = "19"
        isDark = true
        isBackgroundDark = true
        messageHudStyle = .light
        statusBarStyle = .lightContent
        navigationBarColor = FlatColor.black
        primaryColor = FlatColor.coffee
        basicBackgroundColor = UIColor.black
        tableViewHeaderBackgroundColor = FlatColor.blackDark
        tableViewHeaderTextColor = FlatColor.white
        tableViewCellSelectedBackgroundColor = UIColor(red:0.42, green:0.3, blue:0.1, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = UIColor.black
        filterContainerBackgroundColor = UIColor.black
        deleteColor = FlatColor.redDark
        tabBarTintColor = FlatColor.white
        tabBarBarTintColor = FlatColor.black
        tabBarUnselectedItemTintColor = FlatColor.coffee
        textFieldBorderColor = FlatColor.grayDark
        badgeBackgroundColor = FlatColor.red
    }
    
    static func shoyoJulingLight(){
        no = "20"
        isDark = false
        isBackgroundDark = false
        messageHudStyle = .light
        statusBarStyle = .lightContent
        navigationBarColor = UIColor.black
        primaryColor = FlatColor.greenDark
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.9, blue:0.85, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        filterContainerBackgroundColor = FlatColor.white
        deleteColor = FlatColor.watermelon
        tabBarTintColor = FlatColor.green
        tabBarBarTintColor = UIColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        textFieldBorderColor = FlatColor.whiteDark
        badgeBackgroundColor = FlatColor.red
    }
    
    static func shoyoJulingDark(){
        no = "21"
        isDark = true
        isBackgroundDark = true
        messageHudStyle = .light
        statusBarStyle = .lightContent
        navigationBarColor = FlatColor.black
        primaryColor = FlatColor.greenDark
        basicBackgroundColor = UIColor.black
        tableViewHeaderBackgroundColor = FlatColor.blackDark
        tableViewHeaderTextColor = FlatColor.white
        tableViewCellSelectedBackgroundColor = FlatColor.black
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = UIColor.black
        filterContainerBackgroundColor = UIColor.black
        deleteColor = FlatColor.redDark
        tabBarTintColor = FlatColor.green
        tabBarBarTintColor = FlatColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        textFieldBorderColor = FlatColor.grayDark
        badgeBackgroundColor = FlatColor.red
    }
    
    static func unionJackLight(){
        no = "22"
        isDark = false
        isBackgroundDark = false
        messageHudStyle = .dark
        statusBarStyle = .default
        navigationBarColor = FlatColor.white
        primaryColor = FlatColor.purple
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.87, green:0.81, blue:0.96, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        filterContainerBackgroundColor = FlatColor.white
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.purpleDark
        tabBarBarTintColor = FlatColor.white
        tabBarUnselectedItemTintColor = FlatColor.gray
        textFieldBorderColor = FlatColor.whiteDark
        badgeBackgroundColor = FlatColor.red
    }

    static func unionJackDark(){
        no = "23"
        isDark = true
        isBackgroundDark = true
        messageHudStyle = .light
        statusBarStyle = .lightContent
        navigationBarColor = FlatColor.black
        primaryColor = FlatColor.magenta
        basicBackgroundColor = UIColor.black
        tableViewHeaderBackgroundColor = FlatColor.blackDark
        tableViewHeaderTextColor = FlatColor.white
        tableViewCellSelectedBackgroundColor = FlatColor.black
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = UIColor.black
        filterContainerBackgroundColor = UIColor.black
        deleteColor = FlatColor.redDark
        tabBarTintColor = FlatColor.magenta
        tabBarBarTintColor = FlatColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        textFieldBorderColor = FlatColor.grayDark
        badgeBackgroundColor = FlatColor.red
    }

    static func blueMoonLight(){
        no = "24"
        isDark = false
        isBackgroundDark = false
        messageHudStyle = .dark
        statusBarStyle = .default
        navigationBarColor = FlatColor.powderBlue
        primaryColor = FlatColor.blue
        basicBackgroundColor = UIColor(red:0.88, green:0.92, blue:0.98, alpha:1.0)
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        tableViewHeaderTextColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.79, green:0.83, blue:0.92, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        filterContainerBackgroundColor = FlatColor.powderBlue
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.blueDark
        tabBarBarTintColor = UIColor(red:0.88, green:0.92, blue:0.98, alpha:1.0)
        tabBarUnselectedItemTintColor = FlatColor.gray
        textFieldBorderColor = FlatColor.gray
        badgeBackgroundColor = FlatColor.red
    }
    
    static func bloodyMaryDark(){
        no = "25"
        isDark = true
        isBackgroundDark = true
        messageHudStyle = .light
        statusBarStyle = .lightContent
        navigationBarColor = FlatColor.black
        primaryColor = FlatColor.red
        basicBackgroundColor = UIColor.black
        tableViewHeaderBackgroundColor = FlatColor.blackDark
        tableViewHeaderTextColor = FlatColor.white
        tableViewCellSelectedBackgroundColor = FlatColor.black
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = UIColor.black
        filterContainerBackgroundColor = UIColor.black
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.red
        tabBarBarTintColor = FlatColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        textFieldBorderColor = FlatColor.grayDark
        badgeBackgroundColor = FlatColor.red
    }

    // MARK: - Manage Theme
    static func saveTheme(themeNo: String?){
        if let no = themeNo{
            let defaults = UserDefaults.standard
            defaults.set(no, forKey: GlobalConstants.ColorThemeKey)
        }
    }
    
    static func loadTheme(){
        let defaults = UserDefaults.standard
        if let themeNo = defaults.string(forKey: GlobalConstants.ColorThemeKey){
            setTheme(themeNo: themeNo)
        }else{
            defaults.set("0", forKey: GlobalConstants.ColorThemeKey)
            tequilaSunriseLight()
            setGlobalTheme()
        }
    }
    
    static func setTheme(themeNo: String?){
        if let no = themeNo {
            switch no{
            case "0": tequilaSunriseLight()
            case "1": tequilaSunriseDark()
            case "2": seaBreezeLight()
            case "3": seaBreezeDark()
            case "4": chinaBlueLight()
            case "5": chinaBlueDark()
            case "6": grasshopperLight()
            case "7": irishCoffeeDark()
            case "8": mojitoLight()
            case "9": redEyeLight()
            case "10": cubaLibreDark()
            case "11": silverWingLight()
            case "12": americanLemonadeDark()
            case "13": blueLagoonLight()
            case "14": blueLagoonDark()
            case "15": mimosaLight()
            case "16": mimosaDark()
            case "17": pinkLadyLight()
            case "18": pinkLadyDark()
            case "19": blackRussianDark()
            case "20": shoyoJulingLight()
            case "21": shoyoJulingDark()
            case "22": unionJackLight()
            case "23": unionJackDark()
            case "24": blueMoonLight()
            case "25": bloodyMaryDark()
            default: break
            }
            setGlobalTheme()
        }
    }
    
    // MARK: - Set Global Theme
    static private func setGlobalTheme(){
        // 注意：UILabel, TableViewは外部のUIコンポーネントに影響するので、色の設定を共通化してはいけない
        customizeButton()
        customizeNavigationBar()
        customizeSearchBar()
        customizeSegmentedControl()
        customizeCircularCheckbox()
        customizeTextField()
        customizeTextView()
        customizeTabBar()
        customizeSlider()
        customizeActivityIndicatorView()
        customizeLabel()
        MessageHUD.set(defaultStyle: messageHudStyle)
    }
    
    static private func customizeButton(){
        // テーマカラー変更のチェックマークの色ために必要
        UIButton.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).tintColor = UchicockStyle.primaryColor

        UIButton.appearance(whenContainedInInstancesOf: [CustomNavigationBar.self]).backgroundColor = UIColor.clear
    }
    
    static private func customizeNavigationBar(){
        let contentColor = FlatColor.contrastColorOf(navigationBarColor, isFlat: false)
        CustomNavigationBar.appearance().barTintColor = navigationBarColor
        CustomNavigationBar.appearance().tintColor = contentColor
        CustomNavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: contentColor]
        CustomNavigationBar.appearance().shadowImage = UIImage()
    }
    
    static private func customizeSearchBar(){
        CustomSearchBar.appearance().backgroundColor = filterContainerBackgroundColor
        CustomSearchBar.appearance().tintColor = labelTextColor
        CustomSearchBar.appearance().barTintColor = filterContainerBackgroundColor        
    }
    
    static private func customizeSegmentedControl(){
        CustomSegmentedControl.appearance().backgroundColor = basicBackgroundColor
        if #available(iOS 13.0, *) {
            CustomSegmentedControl.appearance().selectedSegmentTintColor = primaryColor
            CustomSegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: labelTextColorOnBadge], for: .selected)
            CustomSegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: labelTextColor], for: .normal)
        }else{
            CustomSegmentedControl.appearance().tintColor = primaryColor
        }
    }
    
    static private func customizeCircularCheckbox(){
        CircularCheckbox.appearance().backgroundColor = UIColor.clear
        CircularCheckbox.appearance().tintColor = primaryColor
    }
    
    static private func customizeTextField(){
        CustomTextField.appearance().backgroundColor = basicBackgroundColor
        CustomTextField.appearance().tintColor = labelTextColor
        CustomTextField.appearance().textColor = labelTextColor
        UITextField.appearance(whenContainedInInstancesOf: [CustomSearchBar.self]).backgroundColor = basicBackgroundColor
        UITextField.appearance(whenContainedInInstancesOf: [CustomSearchBar.self]).tintColor = labelTextColor
        UITextField.appearance(whenContainedInInstancesOf: [CustomSearchBar.self]).textColor = labelTextColor
        if isDark{
            CustomTextField.appearance().keyboardAppearance = .dark
            UITextField.appearance(whenContainedInInstancesOf: [CustomSearchBar.self]).keyboardAppearance = .dark
        }else{
            CustomTextField.appearance().keyboardAppearance = .light
            UITextField.appearance(whenContainedInInstancesOf: [CustomSearchBar.self]).keyboardAppearance = .light
        }
    }
    
    static private func customizeTextView(){
        CustomTextView.appearance().backgroundColor = basicBackgroundColor
        CustomTextView.appearance().textColor = labelTextColor
        CustomTextView.appearance().tintColor = labelTextColor
    }
    
    static private func customizeTabBar(){
        CustomTabBar.appearance().tintColor = tabBarTintColor
        CustomTabBar.appearance().barTintColor = tabBarBarTintColor
        CustomTabBar.appearance().unselectedItemTintColor = tabBarUnselectedItemTintColor
    }
        
    static private func customizeSlider(){
        CustomSlider.appearance().minimumTrackTintColor = primaryColor
        CustomSlider.appearance().maximumTrackTintColor = labelTextColorLight
    }
    
    static private func customizeLabel(){
        CustomLabel.appearance().textColor = labelTextColor
    }
    
    static private func customizeActivityIndicatorView(){
        PullToRefreshActivityIndicatorView.appearance().color = labelTextColor
    }

}
