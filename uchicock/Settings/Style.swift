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
    static var no = 0
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
        no = 0
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
        tableViewCellSelectedBackgroundColor = FlatWhiteDark()
        tableViewCellEditBackgroundColor = FlatGray()
        tableViewCellReminderBackgroundColor = FlatSkyBlueDark()
        badgeDisableBackgroundColor = FlatWhiteDark()
        memoBorderColor = FlatWhiteDark()
        checkboxSecondaryTintColor = FlatGray()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        UITableViewCell.appearance().selectedBackgroundView = backgroundView
    }
    
    static func tequilaSunriseDark(){
        no = 1
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
        tableViewCellSelectedBackgroundColor = FlatYellowDark()
        tableViewCellEditBackgroundColor = FlatGrayDark()
        tableViewCellReminderBackgroundColor = FlatYellowDark()
        badgeDisableBackgroundColor = FlatGrayDark()
        memoBorderColor = FlatGrayDark()
        checkboxSecondaryTintColor = FlatGrayDark()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        UITableViewCell.appearance().selectedBackgroundView = backgroundView
    }
    
    static func seaBreezeLight(){
        no = 2
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
        tableViewCellSelectedBackgroundColor = FlatWhiteDark()
        tableViewCellEditBackgroundColor = FlatGray()
        tableViewCellReminderBackgroundColor = FlatPink()
        badgeDisableBackgroundColor = FlatWhiteDark()
        memoBorderColor = FlatWhiteDark()
        checkboxSecondaryTintColor = FlatGray()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        UITableViewCell.appearance().selectedBackgroundView = backgroundView
    }
    
    static func seaBreezeDark(){
        no = 3
        isDark = true
        primaryColor = FlatPink()
        secondaryColor = FlatPink()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatBlackDark()
        tableViewHeaderBackgroundColor = FlatGrayDark()
        labelTextColor = FlatWhite()
        labelTextColorLight = FlatGray()
        labelTextColorOnBadge = FlatBlackDark()
        labelTextColorOnDisableBadge = FlatBlackDark()
        textFieldBackgroundColor = FlatGrayDark()
        filterContainerBackgroundColor = FlatBlackDark()
        deleteColor = FlatRed()
        tabBarTintColor = FlatPink()
        tabBarBarTintColor = FlatBlack()
        tableViewCellSelectedBackgroundColor = FlatGrayDark()
        tableViewCellEditBackgroundColor = FlatGrayDark()
        tableViewCellReminderBackgroundColor = FlatPinkDark()
        badgeDisableBackgroundColor = FlatGrayDark()
        memoBorderColor = FlatGrayDark()
        checkboxSecondaryTintColor = FlatGrayDark()

        let backgroundView = UIView()
        backgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        UITableViewCell.appearance().selectedBackgroundView = backgroundView
    }

    static func chinaBlueLight(){
        no = 4
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
        tableViewCellSelectedBackgroundColor = FlatWhiteDark()
        tableViewCellEditBackgroundColor = FlatGray()
        tableViewCellReminderBackgroundColor = FlatSkyBlueDark()
        badgeDisableBackgroundColor = FlatWhiteDark()
        memoBorderColor = FlatWhiteDark()
        checkboxSecondaryTintColor = FlatGray()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        UITableViewCell.appearance().selectedBackgroundView = backgroundView
    }

    static func chinaBlueDark(){
        no = 5
        isDark = true
        primaryColor = FlatSkyBlue()
        secondaryColor = FlatSkyBlue()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatBlack()
        tableViewHeaderBackgroundColor = FlatGrayDark()
        labelTextColor = FlatWhite()
        labelTextColorLight = FlatGray()
        labelTextColorOnBadge = FlatBlack()
        labelTextColorOnDisableBadge = FlatBlack()
        textFieldBackgroundColor = FlatGrayDark()
        filterContainerBackgroundColor = FlatBlack()
        deleteColor = FlatRed()
        tabBarTintColor = FlatSkyBlue()
        tabBarBarTintColor = FlatBlackDark()
        tableViewCellSelectedBackgroundColor = FlatGrayDark()
        tableViewCellEditBackgroundColor = FlatGrayDark()
        tableViewCellReminderBackgroundColor = FlatSkyBlueDark()
        badgeDisableBackgroundColor = FlatGrayDark()
        memoBorderColor = FlatGrayDark()
        checkboxSecondaryTintColor = FlatGrayDark()

        let backgroundView = UIView()
        backgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        UITableViewCell.appearance().selectedBackgroundView = backgroundView
    }

    static func grasshopperLight(){
        no = 6
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
        tableViewCellSelectedBackgroundColor = FlatWhiteDark()
        tableViewCellEditBackgroundColor = FlatGray()
        tableViewCellReminderBackgroundColor = FlatMintDark()
        badgeDisableBackgroundColor = FlatWhiteDark()
        memoBorderColor = FlatWhiteDark()
        checkboxSecondaryTintColor = FlatGray()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        UITableViewCell.appearance().selectedBackgroundView = backgroundView
    }

    static func irishCoffeeDark(){
        no = 7
        isDark = true
        primaryColor = FlatCoffeeDark()
        secondaryColor = FlatCoffee()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatBlack()
        tableViewHeaderBackgroundColor = FlatGrayDark()
        labelTextColor = FlatWhite()
        labelTextColorLight = FlatGray()
        labelTextColorOnBadge = FlatBlack()
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
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = Style.tableViewCellSelectedBackgroundColor
        UITableViewCell.appearance().selectedBackgroundView = backgroundView
    }

    static func loadTheme(){
        let defaults = UserDefaults.standard
        if let no = defaults.string(forKey: "Theme"){
            if no == "0"		{ tequilaSunriseLight()	}
            if no == "1"		{ tequilaSunriseDark()	}
            if no == "2"		{ seaBreezeLight()      }
            if no == "3"		{ seaBreezeDark()   	}
            if no == "4"		{ chinaBlueLight()      }
            if no == "5"		{ chinaBlueDark()       }
            if no == "6"		{ grasshopperLight()	}
            if no == "7"		{ irishCoffeeDark()     }
        }else{
            defaults.set("0", forKey: "Theme")
            tequilaSunriseLight()
        }
    }
    
    static func saveTheme(themeNo: String){
        let defaults = UserDefaults.standard
        defaults.set(themeNo, forKey: "Theme")
    }
}
