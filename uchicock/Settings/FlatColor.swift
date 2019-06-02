//
//  FlatColor.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/06/01.
//  Copyright © 2019 Kou. All rights reserved.
//

struct FlatColor{
    static let black = UIColor(hue: 0/360, saturation: 0/100, brightness: 17/100, alpha: 1)
    static let blackDark = UIColor(hue: 0/360, saturation: 0/100, brightness: 15/100, alpha: 1)
    static let maroon = UIColor(hue: 5/360, saturation: 65/100, brightness: 47/100, alpha: 1)
    static let maroonDark = UIColor(hue: 4/360, saturation: 68/100, brightness: 40/100, alpha: 1)
    static let red = UIColor(hue: 6/360, saturation: 74/100, brightness: 91/100, alpha: 1)
    static let redDark = UIColor(hue: 6/360, saturation: 78/100, brightness: 75/100, alpha: 1)
    static let brown = UIColor(hue: 24/360, saturation: 45/100, brightness: 37/100, alpha: 1)
    static let brownDark = UIColor(hue: 25/360, saturation: 45/100, brightness: 31/100, alpha: 1)
    static let coffee = UIColor(hue: 25/360, saturation: 31/100, brightness: 64/100, alpha: 1)
    static let coffeeDark = UIColor(hue: 25/360, saturation: 34/100, brightness: 56/100, alpha: 1)
    static let orange = UIColor(hue: 28/360, saturation: 85/100, brightness: 90/100, alpha: 1)
    static let orangeDark = UIColor(hue: 24/360, saturation: 100/100, brightness: 83/100, alpha: 1)
    static let sand = UIColor(hue: 42/360, saturation: 25/100, brightness: 94/100, alpha: 1)
    static let sandDark = UIColor(hue: 42/360, saturation: 30/100, brightness: 84/100, alpha: 1)
    static let yellow = UIColor(hue: 48/360, saturation: 99/100, brightness: 100/100, alpha: 1)
    static let yellowDark = UIColor(hue: 40/360, saturation: 100/100, brightness: 100/100, alpha: 1)
    static let lime = UIColor(hue: 74/360, saturation: 70/100, brightness: 78/100, alpha: 1)
    static let limeDark = UIColor(hue: 74/360, saturation: 81/100, brightness: 69/100, alpha: 1)
    static let forestGreen = UIColor(hue: 138/360, saturation: 45/100, brightness: 37/100, alpha: 1)
    static let forestGreenDark = UIColor(hue: 135/360, saturation: 44/100, brightness: 31/100, alpha: 1)
    static let green = UIColor(hue: 145/360, saturation: 77/100, brightness: 80/100, alpha: 1)
    static let greenDark = UIColor(hue: 145/360, saturation: 78/100, brightness: 68/100, alpha: 1)
    static let mint = UIColor(hue: 168/360, saturation: 86/100, brightness: 74/100, alpha: 1)
    static let mintDark = UIColor(hue: 168/360, saturation: 86/100, brightness: 63/100, alpha: 1)
    static let gray = UIColor(hue: 184/360, saturation: 10/100, brightness: 65/100, alpha: 1)
    static let grayDark = UIColor(hue: 184/360, saturation: 10/100, brightness: 55/100, alpha: 1)
    static let white = UIColor(hue: 192/360, saturation: 2/100, brightness: 95/100, alpha: 1)
    static let whiteDark = UIColor(hue: 204/360, saturation: 5/100, brightness: 78/100, alpha: 1)
    static let teal = UIColor(hue: 195/360, saturation: 55/100, brightness: 51/100, alpha: 1)
    static let tealDark = UIColor(hue: 196/360, saturation: 54/100, brightness: 45/100, alpha: 1)
    static let skyBlue = UIColor(hue: 204/360, saturation: 76/100, brightness: 86/100, alpha: 1)
    static let skyBlueDark = UIColor(hue: 204/360, saturation: 78/100, brightness: 73/100, alpha: 1)
    static let navyBlue = UIColor(hue: 210/360, saturation: 45/100, brightness: 37/100, alpha: 1)
    static let navyBlueDark = UIColor(hue: 210/360, saturation: 45/100, brightness: 31/100, alpha: 1)
    static let powderBlue = UIColor(hue: 222/360, saturation: 24/100, brightness: 95/100, alpha: 1)
    static let powderBlueDark = UIColor(hue: 222/360, saturation: 28/100, brightness: 84/100, alpha: 1)
    static let blue = UIColor(hue: 224/360, saturation: 50/100, brightness: 63/100, alpha: 1)
    static let blueDark = UIColor(hue: 224/360, saturation: 56/100, brightness: 51/100, alpha: 1)
    static let purple = UIColor(hue: 253/360, saturation: 52/100, brightness: 77/100, alpha: 1)
    static let purpleDark = UIColor(hue: 253/360, saturation: 56/100, brightness: 64/100, alpha: 1)
    static let magenta = UIColor(hue: 283/360, saturation: 51/100, brightness: 71/100, alpha: 1)
    static let magentaDark = UIColor(hue: 282/360, saturation: 61/100, brightness: 68/100, alpha: 1)
    static let plum = UIColor(hue: 300/360, saturation: 45/100, brightness: 37/100, alpha: 1)
    static let plumDark = UIColor(hue: 300/360, saturation: 46/100, brightness: 31/100, alpha: 1)
    static let pink = UIColor(hue: 324/360, saturation: 49/100, brightness: 96/100, alpha: 1)
    static let pinkDark = UIColor(hue: 327/360, saturation: 57/100, brightness: 83/100, alpha: 1)
    static let watermelon = UIColor(hue: 356/360, saturation: 53/100, brightness: 94/100, alpha: 1)
    static let watermelonDark = UIColor(hue: 358/360, saturation: 61/100, brightness: 85/100, alpha: 1)
    
    static func contrastColorOf(_ primeColor: UIColor, isFlat: Bool) -> UIColor{
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        primeColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)        
        red *= 0.2126
        green *= 0.7152
        blue *= 0.0722
        let luminance = red + green + blue
        if isFlat{
            return (luminance > 0.6) ? UIColor(hue: 0/360, saturation: 0/100, brightness: 15/100, alpha: 1) : UIColor(hue: 192/360, saturation: 2/100, brightness: 95/100, alpha: 1)
        }else{
            return (luminance > 0.6) ? UIColor(red: 0, green: 0, blue: 0, alpha: 1) : UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    static func setGlobalThemeUsing(_ primaryColor: UIColor, with secondaryColor: UIColor){
        customizeBarButtonItemWith(primaryColor)
        customizeButtonWith(primaryColor, and: secondaryColor)
        customizeNavigationBarWith(primaryColor)
    }
    
    static private func customizeBarButtonItemWith(_ primaryColor: UIColor){
        let contentColor = contrastColorOf(primaryColor, isFlat: false)
        UIBarButtonItem.appearance().tintColor = primaryColor
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = contentColor
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = contentColor
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).tintColor = contentColor
    }
    
    static private func customizeButtonWith(_ primaryColor: UIColor, and secondaryColor: UIColor){
        let contentColor = contrastColorOf(primaryColor, isFlat: false)
        let secondaryContentColor = contrastColorOf(secondaryColor, isFlat: false)
        UIButton.appearance().tintColor = secondaryContentColor
        UIButton.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = contentColor
        UIButton.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.clear
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = contentColor
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).backgroundColor = UIColor.clear
        UIButton.appearance(whenContainedInInstancesOf: [UIToolbar.self]).tintColor = contentColor
        UIButton.appearance(whenContainedInInstancesOf: [UIToolbar.self]).backgroundColor = UIColor.clear
        UIButton.appearance(whenContainedInInstancesOf: [UIStepper.self]).backgroundColor = UIColor.clear
        UIButton.appearance().setTitleShadowColor(UIColor.clear, for: UIControl.State.normal)
    }
    
    static private func customizeNavigationBarWith(_ primaryColor: UIColor){
        let contentColor = contrastColorOf(primaryColor, isFlat: false)
        UINavigationBar.appearance().barTintColor = primaryColor
        UINavigationBar.appearance().tintColor = contentColor
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: contentColor]
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
}
