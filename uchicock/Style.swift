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
    }
    
    static func tequilaSunriseDark(){
        no = 1
        primaryColor = FlatYellow()
        secondaryColor = FlatSkyBlue()
        Chameleon.setGlobalThemeUsingPrimaryColor(Style.primaryColor, withSecondaryColor: Style.secondaryColor, andContentStyle: UIContentStyle.contrast)
        basicBackgroundColor = FlatBlack()
        tableViewHeaderBackgroundColor = FlatGrayDark()
        labelTextColorOnDisableBadge = FlatBlack()
        labelTextColor = FlatWhite()
        labelTextColorLight = FlatGray()
        labelTextColorOnBadge = FlatBlack()
        textFieldBackgroundColor = FlatGrayDark()
        filterContainerBackgroundColor = FlatSandDark()
        deleteColor = FlatWatermelon()
        tabBarTintColor = FlatOrange()
        tabBarBarTintColor = FlatBlack()
        tableViewCellSelectedBackgroundColor = FlatGrayDark()
        tableViewCellEditBackgroundColor = FlatGrayDark()
        tableViewCellReminderBackgroundColor = FlatSkyBlue()
        badgeDisableBackgroundColor = FlatGrayDark()
        memoBorderColor = FlatGrayDark()
        checkboxSecondaryTintColor = FlatGray()
    }

    static let availableThemes = ["Tequila Sunrise Light", "Tequila Sunrise Dark"]
    
    static func loadTheme(){
        let defaults = UserDefaults.standard
        if let name = defaults.string(forKey: "Theme"){
            if name == "Tequila Sunrise Light"		{ tequilaSunriseLight()	}
            if name == "Tequila Sunrise Dark"		{ tequilaSunriseDark()	}
        }else{
            defaults.set("Tequila Sunrise Light", forKey: "Theme")
            tequilaSunriseLight()
        }
    }
}
