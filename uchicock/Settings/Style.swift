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
    static var primaryColor = FlatYellow()
    static var secondaryColor = FlatSkyBlueDark()
    static var basicBackgroundColor = FlatWhite()
    static var tableViewHeaderBackgroundColor = FlatWhiteDark()
    static var labelTextColor = FlatBlack()
    static var labelTextColorLight = FlatGrayDark()
    static var labelTextColorOnBadge = FlatWhite()
    static var labelTextColorOnDisableBadge = FlatBlack()
    static var textFieldBackgroundColor = UIColor.white
    static var filterContainerBackgroundColor = FlatSand()
    static var deleteColor = FlatRed()
    static var tabBarTintColor = FlatOrange()
    static var tabBarBarTintColor = FlatWhite()
    static var tableViewCellSelectedBackgroundColor = FlatWhiteDark()
    static var tableViewCellEditBackgroundColor = FlatGray()
    static var tableViewCellReminderBackgroundColor = FlatSkyBlueDark()
    static var badgeDisableBackgroundColor = FlatWhiteDark()
    static var memoBorderColor = FlatWhiteDark()
    static var checkboxSecondaryTintColor = FlatGray()
    
    static func tequilaSunriseLight(){
        no = "0"
        isDark = false
        primaryColor = FlatYellow()
        secondaryColor = FlatSkyBlueDark()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatWhite()
        tableViewHeaderBackgroundColor = FlatWhiteDark()
        labelTextColor = FlatBlack()
        labelTextColorLight = FlatGrayDark()
        labelTextColorOnBadge = FlatWhite()
        labelTextColorOnDisableBadge = FlatBlack()
        textFieldBackgroundColor = UIColor.white
        filterContainerBackgroundColor = FlatSand()
        deleteColor = FlatRed()
        tabBarTintColor = FlatOrange()
        tabBarBarTintColor = FlatWhite()
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatGray()
        tableViewCellReminderBackgroundColor = FlatSkyBlueDark()
        badgeDisableBackgroundColor = FlatWhiteDark()
        memoBorderColor = FlatWhiteDark()
        checkboxSecondaryTintColor = FlatGray()
    }
    
    static func tequilaSunriseDark(){
        no = "1"
        isDark = true
        primaryColor = FlatYellow()
        secondaryColor = FlatYellowDark()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatBlack()
        tableViewHeaderBackgroundColor = FlatGrayDark()
        labelTextColor = FlatWhite()
        labelTextColorLight = FlatGray()
        labelTextColorOnBadge = FlatBlack()
        labelTextColorOnDisableBadge = FlatBlack()
        textFieldBackgroundColor = FlatGrayDark()
        filterContainerBackgroundColor = FlatBlack()
        deleteColor = FlatRedDark()
        tabBarTintColor = FlatOrange()
        tabBarBarTintColor = FlatBlackDark()
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.5, blue:0.0, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatGrayDark()
        tableViewCellReminderBackgroundColor = FlatYellowDark()
        badgeDisableBackgroundColor = FlatGrayDark()
        memoBorderColor = FlatGrayDark()
        checkboxSecondaryTintColor = FlatGrayDark()
    }
    
    static func seaBreezeLight(){
        no = "2"
        isDark = false
        primaryColor = FlatPink()
        secondaryColor = FlatPink()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = UIColor(red:1.0, green:0.95, blue:1.0, alpha:1.0)
        tableViewHeaderBackgroundColor = FlatWhite()
        labelTextColor = FlatBlack()
        labelTextColorLight = FlatGrayDark()
        labelTextColorOnBadge = FlatWhite()
        labelTextColorOnDisableBadge = FlatBlack()
        textFieldBackgroundColor = UIColor.white
        filterContainerBackgroundColor = UIColor(red:1.0, green:0.95, blue:1.0, alpha:1.0)
        deleteColor = FlatWatermelon()
        tabBarTintColor = FlatPink()
        tabBarBarTintColor = FlatWhite()
        tableViewCellSelectedBackgroundColor = UIColor(red:0.97, green:0.8, blue:0.93, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatGray()
        tableViewCellReminderBackgroundColor = FlatPink()
        badgeDisableBackgroundColor = FlatWhiteDark()
        memoBorderColor = FlatWhiteDark()
        checkboxSecondaryTintColor = FlatGray()
    }
    
    static func seaBreezeDark(){
        no = "3"
        isDark = true
        primaryColor = FlatPinkDark()
        secondaryColor = FlatPinkDark()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatBlackDark()
        tableViewHeaderBackgroundColor = FlatGrayDark()
        labelTextColor = FlatWhite()
        labelTextColorLight = FlatGray()
        labelTextColorOnBadge = FlatWhite()
        labelTextColorOnDisableBadge = FlatBlackDark()
        textFieldBackgroundColor = FlatGrayDark()
        filterContainerBackgroundColor = FlatBlackDark()
        deleteColor = FlatRed()
        tabBarTintColor = FlatPinkDark()
        tabBarBarTintColor = FlatBlack()
        tableViewCellSelectedBackgroundColor = UIColor(red:0.3, green:0.3, blue:0.3, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatGrayDark()
        tableViewCellReminderBackgroundColor = FlatPinkDark()
        badgeDisableBackgroundColor = FlatGrayDark()
        memoBorderColor = FlatGrayDark()
        checkboxSecondaryTintColor = FlatGrayDark()
    }

    static func chinaBlueLight(){
        no = "4"
        isDark = false
        primaryColor = FlatSkyBlue()
        secondaryColor = FlatSkyBlue()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatWhite()
        tableViewHeaderBackgroundColor = FlatWhiteDark()
        labelTextColor = FlatBlack()
        labelTextColorLight = FlatGrayDark()
        labelTextColorOnBadge = FlatWhite()
        labelTextColorOnDisableBadge = FlatBlack()
        textFieldBackgroundColor = UIColor.white
        filterContainerBackgroundColor = FlatWhite()
        deleteColor = FlatRed()
        tabBarTintColor = FlatSkyBlue()
        tabBarBarTintColor = FlatWhite()
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatGray()
        tableViewCellReminderBackgroundColor = FlatSkyBlueDark()
        badgeDisableBackgroundColor = FlatWhiteDark()
        memoBorderColor = FlatWhiteDark()
        checkboxSecondaryTintColor = FlatGray()
    }

    static func chinaBlueDark(){
        no = "5"
        isDark = true
        primaryColor = FlatSkyBlueDark()
        secondaryColor = FlatSkyBlueDark()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatBlack()
        tableViewHeaderBackgroundColor = FlatGrayDark()
        labelTextColor = FlatWhite()
        labelTextColorLight = FlatGray()
        labelTextColorOnBadge = FlatWhite()
        labelTextColorOnDisableBadge = FlatBlack()
        textFieldBackgroundColor = FlatGrayDark()
        filterContainerBackgroundColor = FlatBlack()
        deleteColor = FlatRed()
        tabBarTintColor = FlatSkyBlueDark()
        tabBarBarTintColor = FlatBlackDark()
        tableViewCellSelectedBackgroundColor = UIColor(red:0.3, green:0.3, blue:0.3, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatGrayDark()
        tableViewCellReminderBackgroundColor = FlatSkyBlueDark()
        badgeDisableBackgroundColor = FlatGrayDark()
        memoBorderColor = FlatGrayDark()
        checkboxSecondaryTintColor = FlatGrayDark()
    }

    static func grasshopperLight(){
        no = "6"
        isDark = false
        primaryColor = FlatMint()
        secondaryColor = FlatMintDark()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatWhite()
        tableViewHeaderBackgroundColor = FlatWhiteDark()
        labelTextColor = FlatBlack()
        labelTextColorLight = FlatGrayDark()
        labelTextColorOnBadge = FlatWhite()
        labelTextColorOnDisableBadge = FlatBlack()
        textFieldBackgroundColor = UIColor.white
        filterContainerBackgroundColor = FlatMint()
        deleteColor = FlatWatermelon()
        tabBarTintColor = FlatMintDark()
        tabBarBarTintColor = FlatWhite()
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatGray()
        tableViewCellReminderBackgroundColor = FlatMintDark()
        badgeDisableBackgroundColor = FlatWhiteDark()
        memoBorderColor = FlatWhiteDark()
        checkboxSecondaryTintColor = FlatGray()
    }

    static func irishCoffeeDark(){
        no = "7"
        isDark = true
        primaryColor = FlatCoffeeDark()
        secondaryColor = FlatCoffee()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatBlack()
        tableViewHeaderBackgroundColor = FlatGrayDark()
        labelTextColor = FlatWhite()
        labelTextColorLight = FlatGray()
        labelTextColorOnBadge = FlatWhite()
        labelTextColorOnDisableBadge = FlatBlack()
        textFieldBackgroundColor = FlatGrayDark()
        filterContainerBackgroundColor = FlatBlack()
        deleteColor = FlatWatermelonDark()
        tabBarTintColor = FlatWhite()
        tabBarBarTintColor = FlatCoffeeDark()
        tableViewCellSelectedBackgroundColor = FlatCoffeeDark()
        tableViewCellEditBackgroundColor = FlatGrayDark()
        tableViewCellReminderBackgroundColor = FlatCoffeeDark()
        badgeDisableBackgroundColor = FlatGrayDark()
        memoBorderColor = FlatGrayDark()
        checkboxSecondaryTintColor = FlatGrayDark()
    }
    
    static func mojitoLight(){
        no = "8"
        isDark = false
        primaryColor = FlatWhite()
        secondaryColor = FlatMint()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatWhite()
        tableViewHeaderBackgroundColor = FlatWhiteDark()
        labelTextColor = FlatBlack()
        labelTextColorLight = FlatGrayDark()
        labelTextColorOnBadge = FlatWhite()
        labelTextColorOnDisableBadge = FlatBlack()
        textFieldBackgroundColor = UIColor.white
        filterContainerBackgroundColor = FlatWhite()
        deleteColor = FlatRed()
        tabBarTintColor = FlatMint()
        tabBarBarTintColor = FlatWhite()
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatGray()
        tableViewCellReminderBackgroundColor = FlatMint()
        badgeDisableBackgroundColor = FlatWhiteDark()
        memoBorderColor = FlatWhiteDark()
        checkboxSecondaryTintColor = FlatGray()
    }
    
    static func redEyeLight(){
        no = "9"
        isDark = false
        primaryColor = FlatRed()
        secondaryColor = FlatRed()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatWhite()
        tableViewHeaderBackgroundColor = FlatWhiteDark()
        labelTextColor = FlatBlack()
        labelTextColorLight = FlatGrayDark()
        labelTextColorOnBadge = FlatWhite()
        labelTextColorOnDisableBadge = FlatBlack()
        textFieldBackgroundColor = UIColor.white
        filterContainerBackgroundColor = FlatWhite()
        deleteColor = FlatRedDark()
        tabBarTintColor = FlatWatermelon()
        tabBarBarTintColor = FlatWhite()
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatGray()
        tableViewCellReminderBackgroundColor = FlatWatermelon()
        badgeDisableBackgroundColor = FlatWhiteDark()
        memoBorderColor = FlatWhiteDark()
        checkboxSecondaryTintColor = FlatGray()
    }
    
    static func cubaLibreDark(){
        no = "10"
        isDark = true
        primaryColor = FlatLimeDark()
        secondaryColor = FlatLimeDark()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatBlack()
        tableViewHeaderBackgroundColor = FlatGrayDark()
        labelTextColor = FlatWhite()
        labelTextColorLight = FlatGray()
        labelTextColorOnBadge = FlatBlack()
        labelTextColorOnDisableBadge = FlatBlack()
        textFieldBackgroundColor = FlatGrayDark()
        filterContainerBackgroundColor = FlatBlack()
        deleteColor = FlatRedDark()
        tabBarTintColor = FlatLimeDark()
        tabBarBarTintColor = FlatBlackDark()
        tableViewCellSelectedBackgroundColor = UIColor(red:0.2, green:0.25, blue:0.03, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatGrayDark()
        tableViewCellReminderBackgroundColor = FlatLimeDark()
        badgeDisableBackgroundColor = FlatGrayDark()
        memoBorderColor = FlatGrayDark()
        checkboxSecondaryTintColor = FlatGrayDark()
    }
    
    static func ginAndTonicLight(){
        no = "11"
        isDark = false
        primaryColor = FlatWhite()
        secondaryColor = FlatLime()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatWhite()
        tableViewHeaderBackgroundColor = FlatWhiteDark()
        labelTextColor = FlatBlack()
        labelTextColorLight = FlatGrayDark()
        labelTextColorOnBadge = FlatWhite()
        labelTextColorOnDisableBadge = FlatBlack()
        textFieldBackgroundColor = UIColor.white
        filterContainerBackgroundColor = FlatWhite()
        deleteColor = FlatRed()
        tabBarTintColor = FlatBlack()
        tabBarBarTintColor = FlatWhite()
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatGray()
        tableViewCellReminderBackgroundColor = FlatLimeDark()
        badgeDisableBackgroundColor = FlatWhiteDark()
        memoBorderColor = FlatWhiteDark()
        checkboxSecondaryTintColor = FlatGray()
    }
    
    static func gulfStreamDark(){
        no = "12"
        isDark = true
        primaryColor = FlatSkyBlueDark()
        secondaryColor = FlatOrangeDark()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatBlack()
        tableViewHeaderBackgroundColor = FlatGrayDark()
        labelTextColor = FlatWhite()
        labelTextColorLight = FlatGray()
        labelTextColorOnBadge = FlatBlack()
        labelTextColorOnDisableBadge = FlatBlack()
        textFieldBackgroundColor = FlatGrayDark()
        filterContainerBackgroundColor = FlatBlack()
        deleteColor = FlatRedDark()
        tabBarTintColor = FlatSkyBlueDark()
        tabBarBarTintColor = FlatBlackDark()
        tableViewCellSelectedBackgroundColor = FlatGrayDark()
        tableViewCellEditBackgroundColor = FlatGrayDark()
        tableViewCellReminderBackgroundColor = FlatOrangeDark()
        badgeDisableBackgroundColor = FlatGrayDark()
        memoBorderColor = FlatGrayDark()
        checkboxSecondaryTintColor = FlatGrayDark()
    }
    
    static func cosmopolitanDark(){
        no = "13"
        isDark = true
        primaryColor = FlatWatermelonDark()
        secondaryColor = FlatLimeDark()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatBlack()
        tableViewHeaderBackgroundColor = FlatGrayDark()
        labelTextColor = FlatWhite()
        labelTextColorLight = FlatGray()
        labelTextColorOnBadge = FlatBlack()
        labelTextColorOnDisableBadge = FlatBlack()
        textFieldBackgroundColor = FlatGrayDark()
        filterContainerBackgroundColor = FlatBlack()
        deleteColor = FlatRedDark()
        tabBarTintColor = FlatWatermelonDark()
        tabBarBarTintColor = FlatBlackDark()
        tableViewCellSelectedBackgroundColor = FlatGrayDark()
        tableViewCellEditBackgroundColor = FlatGrayDark()
        tableViewCellReminderBackgroundColor = FlatWatermelonDark()
        badgeDisableBackgroundColor = FlatGrayDark()
        memoBorderColor = FlatGrayDark()
        checkboxSecondaryTintColor = FlatGrayDark()
    }
    
    static func silverWingLight(){
        no = "14"
        isDark = false
        primaryColor = FlatGrayDark()
        secondaryColor = FlatGrayDark()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatWhite()
        tableViewHeaderBackgroundColor = FlatGray()
        labelTextColor = FlatBlack()
        labelTextColorLight = FlatGrayDark()
        labelTextColorOnBadge = FlatWhite()
        labelTextColorOnDisableBadge = FlatBlack()
        textFieldBackgroundColor = UIColor.white
        filterContainerBackgroundColor = FlatWhite()
        deleteColor = FlatRed()
        tabBarTintColor = FlatBlack()
        tabBarBarTintColor = FlatWhiteDark()
        tableViewCellSelectedBackgroundColor = UIColor(red:0.8, green:0.82, blue:0.82, alpha:1.0)
        tableViewCellEditBackgroundColor = FlatGray()
        tableViewCellReminderBackgroundColor = FlatGrayDark()
        badgeDisableBackgroundColor = FlatWhiteDark()
        memoBorderColor = FlatWhiteDark()
        checkboxSecondaryTintColor = FlatGray()
    }
    
    static func americanLemonadeDark(){
        no = "15"
        isDark = true
        primaryColor = FlatMaroon()
        secondaryColor = FlatRedDark()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatBlack()
        tableViewHeaderBackgroundColor = FlatGrayDark()
        labelTextColor = FlatWhite()
        labelTextColorLight = FlatGray()
        labelTextColorOnBadge = FlatBlack()
        labelTextColorOnDisableBadge = FlatBlack()
        textFieldBackgroundColor = FlatGrayDark()
        filterContainerBackgroundColor = FlatBlack()
        deleteColor = FlatRedDark()
        tabBarTintColor = FlatRed()
        tabBarBarTintColor = FlatWhite()
        tableViewCellSelectedBackgroundColor = FlatGrayDark()
        tableViewCellEditBackgroundColor = FlatGrayDark()
        tableViewCellReminderBackgroundColor = FlatMaroon()
        badgeDisableBackgroundColor = FlatGrayDark()
        memoBorderColor = FlatGrayDark()
        checkboxSecondaryTintColor = FlatGrayDark()
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
            case "11": ginAndTonicLight()
            case "12": gulfStreamDark()
            case "13": cosmopolitanDark()
            case "14": silverWingLight()
            case "15": americanLemonadeDark()
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
