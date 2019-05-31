//
//  Style.swift
//  uchicock
//
//  Created by Kou Kinyo on 2017/02/27.
//  Copyright © 2017年 Kou. All rights reserved.
//

import Foundation
import ChameleonFramework

struct Style{
    static var no = "0"
    static var isDark = false
    static var isBackgroundDark = false
    static var isStatusBarLight = false
    static var primaryColor = FlatColor.yellow
    static var secondaryColor = FlatColor.skyBlueDark
    static var basicBackgroundColor = FlatColor.white
    static var tableViewHeaderBackgroundColor = FlatColor.whiteDark
    static var labelTextColor = FlatColor.black
    static var labelTextColorLight = FlatColor.grayDark
    static var labelTextColorOnBadge = FlatColor.white
    static var labelTextColorOnDisableBadge = FlatColor.black
    static var textFieldBackgroundColor = FlatColor.white
    static var filterContainerBackgroundColor = FlatColor.sand
    static var deleteColor = FlatColor.red
    static var tabBarTintColor = FlatColor.orange
    static var tabBarBarTintColor = FlatColor.white
    static var tabBarUnselectedItemTintColor = FlatColor.gray
    static var tableViewCellSelectedBackgroundColor = FlatColor.whiteDark
    static var tableViewCellEditBackgroundColor = FlatColor.gray
    static var tableViewCellReminderBackgroundColor = FlatColor.skyBlueDark
    static var badgeDisableBackgroundColor = FlatColor.whiteDark
    static var memoBorderColor = FlatColor.whiteDark
    static var checkboxSecondaryTintColor = FlatColor.gray
    static var albumRecipeNameBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    
    static func tequilaSunriseLight(){
        no = "0"
        isDark = false
        isBackgroundDark = false
        isStatusBarLight = false
        primaryColor = FlatColor.yellow
        secondaryColor = FlatColor.skyBlueDark
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.white
        filterContainerBackgroundColor = FlatColor.sand
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.orange
        tabBarBarTintColor = FlatColor.white
        tabBarUnselectedItemTintColor = FlatColor.gray
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        tableViewCellReminderBackgroundColor = FlatColor.skyBlueDark
        badgeDisableBackgroundColor = FlatColor.whiteDark
        memoBorderColor = FlatColor.whiteDark
        checkboxSecondaryTintColor = FlatColor.gray
        albumRecipeNameBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    }
    
    static func tequilaSunriseDark(){
        no = "1"
        isDark = true
        isBackgroundDark = true
        isStatusBarLight = false
        primaryColor = FlatColor.yellow
        secondaryColor = FlatColor.yellowDark
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.black
        tableViewHeaderBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = FlatColor.black
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.black
        filterContainerBackgroundColor = FlatColor.black
        deleteColor = FlatColor.watermelonDark
        tabBarTintColor = FlatColor.white
        tabBarBarTintColor = FlatColor.yellowDark
        tabBarUnselectedItemTintColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.5, blue:0.0, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        tableViewCellReminderBackgroundColor = FlatColor.yellowDark
        badgeDisableBackgroundColor = FlatColor.grayDark
        memoBorderColor = FlatColor.grayDark
        checkboxSecondaryTintColor = FlatColor.grayDark
        albumRecipeNameBackgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }
    
    static func seaBreezeLight(){
        no = "2"
        isDark = false
        isBackgroundDark = false
        isStatusBarLight = false
        primaryColor = FlatColor.pink
        secondaryColor = FlatColor.pink
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = UIColor(red:1.0, green:0.95, blue:1.0, alpha:1.0)
        tableViewHeaderBackgroundColor = FlatColor.white
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = UIColor(red:1.0, green:0.95, blue:1.0, alpha:1.0)
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = UIColor(red:1.0, green:0.98, blue:1.0, alpha:1.0)
        filterContainerBackgroundColor = UIColor(red:1.0, green:0.95, blue:1.0, alpha:1.0)
        deleteColor = FlatColor.red
        tabBarTintColor = UIColor.white
        tabBarBarTintColor = FlatColor.pink
        tabBarUnselectedItemTintColor = UIColor(red:0.35, green:0.2, blue:0.3, alpha:1.0)
        tableViewCellSelectedBackgroundColor = UIColor(red:0.97, green:0.8, blue:0.93, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        tableViewCellReminderBackgroundColor = FlatColor.pink
        badgeDisableBackgroundColor = FlatColor.whiteDark
        memoBorderColor = FlatColor.whiteDark
        checkboxSecondaryTintColor = FlatColor.gray
        albumRecipeNameBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    }
    
    static func seaBreezeDark(){
        no = "3"
        isDark = true
        isBackgroundDark = true
        isStatusBarLight = true
        primaryColor = FlatColor.pinkDark
        secondaryColor = FlatColor.pinkDark
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.blackDark
        tableViewHeaderBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = FlatColor.white
        labelTextColorOnDisableBadge = FlatColor.blackDark
        textFieldBackgroundColor = FlatColor.black
        filterContainerBackgroundColor = FlatColor.blackDark
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.white
        tabBarBarTintColor = FlatColor.pinkDark
        tabBarUnselectedItemTintColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.3, green:0.3, blue:0.3, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        tableViewCellReminderBackgroundColor = FlatColor.pinkDark
        badgeDisableBackgroundColor = FlatColor.grayDark
        memoBorderColor = FlatColor.grayDark
        checkboxSecondaryTintColor = FlatColor.grayDark
        albumRecipeNameBackgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }

    static func chinaBlueLight(){
        no = "4"
        isDark = false
        isBackgroundDark = false
        isStatusBarLight = true
        primaryColor = FlatColor.skyBlue
        secondaryColor = FlatColor.skyBlue
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.white
        filterContainerBackgroundColor = FlatColor.white
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.white
        tabBarBarTintColor = FlatColor.skyBlue
        tabBarUnselectedItemTintColor = UIColor(red:0.2, green:0.2, blue:0.3, alpha:1.0)
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        tableViewCellReminderBackgroundColor = FlatColor.skyBlueDark
        badgeDisableBackgroundColor = FlatColor.whiteDark
        memoBorderColor = FlatColor.whiteDark
        checkboxSecondaryTintColor = FlatColor.gray
        albumRecipeNameBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    }

    static func chinaBlueDark(){
        no = "5"
        isDark = true
        isBackgroundDark = true
        isStatusBarLight = true
        primaryColor = FlatColor.skyBlueDark
        secondaryColor = FlatColor.skyBlueDark
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.black
        tableViewHeaderBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = FlatColor.white
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.black
        filterContainerBackgroundColor = FlatColor.black
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.white
        tabBarBarTintColor = FlatColor.skyBlueDark
        tabBarUnselectedItemTintColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.3, green:0.3, blue:0.3, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        tableViewCellReminderBackgroundColor = FlatColor.skyBlueDark
        badgeDisableBackgroundColor = FlatColor.grayDark
        memoBorderColor = FlatColor.grayDark
        checkboxSecondaryTintColor = FlatColor.grayDark
        albumRecipeNameBackgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }

    static func grasshopperLight(){
        no = "6"
        isDark = false
        isBackgroundDark = false
        isStatusBarLight = true
        primaryColor = FlatColor.mint
        secondaryColor = FlatColor.mintDark
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.white
        filterContainerBackgroundColor = FlatColor.mint
        deleteColor = FlatColor.watermelon
        tabBarTintColor = UIColor.white
        tabBarBarTintColor = FlatColor.mint
        tabBarUnselectedItemTintColor = FlatColor.whiteDark
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        tableViewCellReminderBackgroundColor = FlatColor.mintDark
        badgeDisableBackgroundColor = FlatColor.whiteDark
        memoBorderColor = FlatColor.whiteDark
        checkboxSecondaryTintColor = FlatColor.gray
        albumRecipeNameBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    }

    static func irishCoffeeDark(){
        no = "7"
        isDark = true
        isBackgroundDark = true
        isStatusBarLight = true
        primaryColor = FlatColor.coffeeDark
        secondaryColor = FlatColor.coffee
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.black
        tableViewHeaderBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = FlatColor.white
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.black
        filterContainerBackgroundColor = FlatColor.black
        deleteColor = FlatColor.watermelonDark
        tabBarTintColor = FlatColor.white
        tabBarBarTintColor = FlatColor.coffeeDark
        tabBarUnselectedItemTintColor = FlatColor.gray
        tableViewCellSelectedBackgroundColor = FlatColor.coffeeDark
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        tableViewCellReminderBackgroundColor = FlatColor.coffeeDark
        badgeDisableBackgroundColor = FlatColor.grayDark
        memoBorderColor = FlatColor.grayDark
        checkboxSecondaryTintColor = FlatColor.grayDark
        albumRecipeNameBackgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }
    
    static func mojitoLight(){
        no = "8"
        isDark = false
        isBackgroundDark = false
        isStatusBarLight = false
        primaryColor = FlatColor.white
        secondaryColor = FlatColor.mint
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.white
        filterContainerBackgroundColor = FlatColor.white
        deleteColor = FlatColor.watermelonDark
        tabBarTintColor = FlatColor.mint
        tabBarBarTintColor = FlatColor.white
        tabBarUnselectedItemTintColor = FlatColor.gray
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        tableViewCellReminderBackgroundColor = FlatColor.mint
        badgeDisableBackgroundColor = FlatColor.whiteDark
        memoBorderColor = FlatColor.whiteDark
        checkboxSecondaryTintColor = FlatColor.gray
        albumRecipeNameBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    }
    
    static func redEyeLight(){
        no = "9"
        isDark = false
        isBackgroundDark = false
        isStatusBarLight = true
        primaryColor = FlatColor.watermelonDark
        secondaryColor = FlatColor.watermelon
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.white
        filterContainerBackgroundColor = FlatColor.white
        deleteColor = FlatColor.redDark
        tabBarTintColor = FlatColor.white
        tabBarBarTintColor = FlatColor.watermelonDark
        tabBarUnselectedItemTintColor = FlatColor.whiteDark
        tableViewCellSelectedBackgroundColor = UIColor(red:1.0, green:0.7, blue:0.75, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        tableViewCellReminderBackgroundColor = FlatColor.watermelon
        badgeDisableBackgroundColor = FlatColor.whiteDark
        memoBorderColor = FlatColor.whiteDark
        checkboxSecondaryTintColor = FlatColor.gray
        albumRecipeNameBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    }
    
    static func cubaLibreDark(){
        no = "10"
        isDark = true
        isBackgroundDark = true
        isStatusBarLight = false
        primaryColor = FlatColor.limeDark
        secondaryColor = FlatColor.limeDark
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.black
        tableViewHeaderBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = FlatColor.black
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.black
        filterContainerBackgroundColor = FlatColor.black
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.white
        tabBarBarTintColor = FlatColor.limeDark
        tabBarUnselectedItemTintColor = FlatColor.blackDark
        tableViewCellSelectedBackgroundColor = UIColor(red:0.3, green:0.35, blue:0.1, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        tableViewCellReminderBackgroundColor = FlatColor.limeDark
        badgeDisableBackgroundColor = FlatColor.grayDark
        memoBorderColor = FlatColor.grayDark
        checkboxSecondaryTintColor = FlatColor.grayDark
        albumRecipeNameBackgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }
    
    static func silverWingLight(){
        no = "11"
        isDark = false
        isBackgroundDark = false
        isStatusBarLight = true
        primaryColor = FlatColor.grayDark
        secondaryColor = FlatColor.grayDark
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.white
        filterContainerBackgroundColor = FlatColor.whiteDark
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.black
        tabBarBarTintColor = FlatColor.grayDark
        tabBarUnselectedItemTintColor = FlatColor.white
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        tableViewCellReminderBackgroundColor = FlatColor.grayDark
        badgeDisableBackgroundColor = FlatColor.whiteDark
        memoBorderColor = FlatColor.whiteDark
        checkboxSecondaryTintColor = FlatColor.gray
        albumRecipeNameBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    }
    
    static func americanLemonadeDark(){
        no = "12"
        isDark = false
        isBackgroundDark = true
        isStatusBarLight = true
        primaryColor = FlatColor.watermelonDark
        secondaryColor = FlatColor.watermelonDark
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.black
        tableViewHeaderBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = FlatColor.white
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.black
        filterContainerBackgroundColor = FlatColor.black
        deleteColor = FlatColor.watermelonDark
        tabBarTintColor = FlatColor.watermelonDark
        tabBarBarTintColor = FlatColor.white
        tabBarUnselectedItemTintColor = FlatColor.black
        tableViewCellSelectedBackgroundColor = UIColor(red:0.4, green:0.45, blue:0.45, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        tableViewCellReminderBackgroundColor = FlatColor.watermelonDark
        badgeDisableBackgroundColor = FlatColor.grayDark
        memoBorderColor = FlatColor.grayDark
        checkboxSecondaryTintColor = FlatColor.grayDark
        albumRecipeNameBackgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }
    
    static func blueLagoonLight(){
        no = "13"
        isDark = false
        isBackgroundDark = false
        isStatusBarLight = true
        primaryColor = UIColor.black
        secondaryColor = FlatColor.skyBlueDark
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.white
        filterContainerBackgroundColor = FlatColor.white
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.skyBlueDark
        tabBarBarTintColor = UIColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        tableViewCellReminderBackgroundColor = FlatColor.skyBlueDark
        badgeDisableBackgroundColor = FlatColor.whiteDark
        memoBorderColor = FlatColor.whiteDark
        checkboxSecondaryTintColor = FlatColor.gray
        albumRecipeNameBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    }
    
    static func blueLagoonDark(){
        no = "14"
        isDark = true
        isBackgroundDark = true
        isStatusBarLight = true
        primaryColor = UIColor.black
        secondaryColor = FlatColor.skyBlueDark
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.black
        tableViewHeaderBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = FlatColor.white
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.black
        filterContainerBackgroundColor = FlatColor.black
        deleteColor = FlatColor.watermelonDark
        tabBarTintColor = FlatColor.skyBlueDark
        tabBarBarTintColor = UIColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        tableViewCellSelectedBackgroundColor = UIColor(red:0.4, green:0.45, blue:0.45, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        tableViewCellReminderBackgroundColor = FlatColor.skyBlueDark
        badgeDisableBackgroundColor = FlatColor.grayDark
        memoBorderColor = FlatColor.grayDark
        checkboxSecondaryTintColor = FlatColor.grayDark
        albumRecipeNameBackgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }
    
    static func mimosaLight(){
        no = "15"
        isDark = false
        isBackgroundDark = false
        isStatusBarLight = true
        primaryColor = UIColor.black
        secondaryColor = FlatColor.orange
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.white
        filterContainerBackgroundColor = FlatColor.white
        deleteColor = FlatColor.redDark
        tabBarTintColor = FlatColor.orangeDark
        tabBarBarTintColor = UIColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        tableViewCellReminderBackgroundColor = FlatColor.orange
        badgeDisableBackgroundColor = FlatColor.whiteDark
        memoBorderColor = FlatColor.whiteDark
        checkboxSecondaryTintColor = FlatColor.gray
        albumRecipeNameBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    }
    
    static func mimosaDark(){
        no = "16"
        isDark = true
        isBackgroundDark = true
        isStatusBarLight = true
        primaryColor = UIColor.black
        secondaryColor = FlatColor.yellowDark
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.black
        tableViewHeaderBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = FlatColor.black
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.black
        filterContainerBackgroundColor = FlatColor.black
        deleteColor = FlatColor.redDark
        tabBarTintColor = FlatColor.orange
        tabBarBarTintColor = UIColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        tableViewCellSelectedBackgroundColor = UIColor(red:0.4, green:0.45, blue:0.45, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        tableViewCellReminderBackgroundColor = FlatColor.yellowDark
        badgeDisableBackgroundColor = FlatColor.grayDark
        memoBorderColor = FlatColor.grayDark
        checkboxSecondaryTintColor = FlatColor.grayDark
        albumRecipeNameBackgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }

    static func pinkLadyLight(){
        no = "17"
        isDark = false
        isBackgroundDark = false
        isStatusBarLight = true
        primaryColor = UIColor.black
        secondaryColor = FlatColor.pink
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = UIColor(red:1.0, green:0.95, blue:1.0, alpha:1.0)
        tableViewHeaderBackgroundColor = FlatColor.white
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = UIColor(red:1.0, green:0.95, blue:1.0, alpha:1.0)
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = UIColor(red:1.0, green:0.98, blue:1.0, alpha:1.0)
        filterContainerBackgroundColor = UIColor(red:1.0, green:0.95, blue:1.0, alpha:1.0)
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.pinkDark
        tabBarBarTintColor = UIColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        tableViewCellSelectedBackgroundColor = UIColor(red:0.97, green:0.8, blue:0.93, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        tableViewCellReminderBackgroundColor = FlatColor.pink
        badgeDisableBackgroundColor = FlatColor.whiteDark
        memoBorderColor = FlatColor.whiteDark
        checkboxSecondaryTintColor = FlatColor.gray
        albumRecipeNameBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    }
    
    static func pinkLadyDark(){
        no = "18"
        isDark = true
        isBackgroundDark = true
        isStatusBarLight = true
        primaryColor = UIColor.black
        secondaryColor = FlatColor.pinkDark
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.black
        tableViewHeaderBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = FlatColor.white
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.black
        filterContainerBackgroundColor = FlatColor.black
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.pinkDark
        tabBarBarTintColor = UIColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        tableViewCellSelectedBackgroundColor = UIColor(red:0.3, green:0.3, blue:0.3, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        tableViewCellReminderBackgroundColor = FlatColor.pinkDark
        badgeDisableBackgroundColor = FlatColor.grayDark
        memoBorderColor = FlatColor.grayDark
        checkboxSecondaryTintColor = FlatColor.grayDark
        albumRecipeNameBackgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }
    
    static func blackRussianDark(){
        no = "19"
        isDark = true
        isBackgroundDark = true
        isStatusBarLight = true
        primaryColor = UIColor.black
        secondaryColor = FlatColor.coffee
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.black
        tableViewHeaderBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = FlatColor.white
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.black
        filterContainerBackgroundColor = FlatColor.black
        deleteColor = FlatColor.watermelonDark
        tabBarTintColor = FlatColor.sandDark
        tabBarBarTintColor = UIColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        tableViewCellSelectedBackgroundColor = FlatColor.coffeeDark
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        tableViewCellReminderBackgroundColor = FlatColor.coffeeDark
        badgeDisableBackgroundColor = FlatColor.grayDark
        memoBorderColor = FlatColor.grayDark
        checkboxSecondaryTintColor = FlatColor.grayDark
        albumRecipeNameBackgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }
    
    static func shoyoJulingLight(){
        no = "20"
        isDark = false
        isBackgroundDark = false
        isStatusBarLight = true
        primaryColor = UIColor.black
        secondaryColor = FlatColor.greenDark
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.white
        tableViewHeaderBackgroundColor = FlatColor.whiteDark
        labelTextColor = FlatColor.black
        labelTextColorLight = FlatColor.grayDark
        labelTextColorOnBadge = FlatColor.white
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.white
        filterContainerBackgroundColor = FlatColor.white
        deleteColor = FlatColor.watermelon
        tabBarTintColor = FlatColor.greenDark
        tabBarBarTintColor = UIColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.9, blue:0.85, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.gray
        tableViewCellReminderBackgroundColor = FlatColor.greenDark
        badgeDisableBackgroundColor = FlatColor.whiteDark
        memoBorderColor = FlatColor.whiteDark
        checkboxSecondaryTintColor = FlatColor.gray
        albumRecipeNameBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    }
    
    static func shoyoJulingDark(){
        no = "21"
        isDark = true
        isBackgroundDark = true
        isStatusBarLight = true
        primaryColor = UIColor.black
        secondaryColor = FlatColor.greenDark
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatColor.black
        tableViewHeaderBackgroundColor = FlatColor.grayDark
        labelTextColor = FlatColor.white
        labelTextColorLight = FlatColor.gray
        labelTextColorOnBadge = FlatColor.black
        labelTextColorOnDisableBadge = FlatColor.black
        textFieldBackgroundColor = FlatColor.black
        filterContainerBackgroundColor = FlatColor.black
        deleteColor = FlatColor.red
        tabBarTintColor = FlatColor.greenDark
        tabBarBarTintColor = UIColor.black
        tabBarUnselectedItemTintColor = FlatColor.grayDark
        tableViewCellSelectedBackgroundColor = UIColor(red:0.3, green:0.45, blue:0.33, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatColor.grayDark
        tableViewCellReminderBackgroundColor = FlatColor.greenDark
        badgeDisableBackgroundColor = FlatColor.grayDark
        memoBorderColor = FlatColor.grayDark
        checkboxSecondaryTintColor = FlatColor.grayDark
        albumRecipeNameBackgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }

    static func loadTheme(){
        let defaults = UserDefaults.standard
        if let themeNo = defaults.string(forKey: "Theme"){
            setTheme(themeNo: themeNo)
        }else{
            defaults.set("0", forKey: "Theme")
            tequilaSunriseLight()
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
            default: break
            }
        }
    }
    
    static func saveTheme(themeNo: String?){
        if let no = themeNo{
            let defaults = UserDefaults.standard
            defaults.set(no, forKey: "Theme")
        }
    }
}
