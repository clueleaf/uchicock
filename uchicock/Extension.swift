//
//  File.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/27.
//  Copyright © 2016年 Kou. All rights reserved.
//

extension String {
    func katakana() -> String {
        var str = ""
        for c in unicodeScalars {
            if c.value >= 0x3041 && c.value <= 0x3096 {
                if let u = UnicodeScalar(c.value+96){
                    str += "\(u)"
                }
            } else {
                str += "\(c)"
            }
        }
        return str
    }
    
    func hiragana() -> String {
        var str = ""
        for c in unicodeScalars {
            if c.value >= 0x30A1 && c.value <= 0x30F6 {
                if let u = UnicodeScalar(c.value-96){
                    str += "\(u)"
                }
            } else {
                str += "\(c)"
            }
        }
        return str
    }
    
    func japaneseDictionaryOrder() -> String{
        var katakana = ""
        for c in unicodeScalars {
            if c.value >= 0x3041 && c.value <= 0x3096 {
                if let u = UnicodeScalar(c.value+96){
                    katakana += "\(u)"
                }
            } else {
                katakana += "\(c)"
            }
        }
        
        var result = ""
        var addstr = ""
        for i in 0..<katakana.characters.count{
            let index = katakana.index(katakana.startIndex, offsetBy: i)
            switch katakana[index]{
            case "ー":
                if i > 0 {
                    let beforeIndex = katakana.index(katakana.startIndex, offsetBy: i-1)
                    switch katakana[beforeIndex]{
                    case "ァ", "ア", "カ", "ガ", "サ", "ザ", "タ", "ダ", "ナ", "ハ", "バ", "パ", "マ", "ヤ", "ャ", "ラ", "ワ", "ヮ":
                        result.append("ア")
                        if let a = UnicodeScalar(0x2FFC){
                            addstr += "\(a)"
                        }
                    case "ィ", "イ", "キ", "ギ", "シ", "ジ", "チ", "ヂ", "ニ", "ヒ", "ビ", "ピ", "ミ", "リ", "ヰ":
                        result.append("イ")
                        if let a = UnicodeScalar(0x2FFC){
                            addstr += "\(a)"
                        }
                    case "ゥ", "ウ", "ヴ", "ク", "グ", "ス", "ズ", "ツ", "ヅ", "ヌ", "フ", "ブ", "プ", "ム", "ユ", "ュ", "ル":
                        result.append("ウ")
                        if let a = UnicodeScalar(0x2FFC){
                            addstr += "\(a)"
                        }
                    case "ェ", "エ", "ケ", "ゲ", "セ", "ゼ", "テ", "デ", "ネ", "ヘ", "ベ", "ペ", "メ", "レ", "ヱ":
                        result.append("エ")
                        if let a = UnicodeScalar(0x2FFC){
                            addstr += "\(a)"
                        }
                    case "ォ", "オ", "コ", "ゴ", "ソ", "ゾ", "ト", "ド", "ノ", "ホ", "ボ", "ポ", "モ", "ヨ", "ョ", "ロ", "ヲ":
                        result.append("オ")
                        if let a = UnicodeScalar(0x2FFC){
                            addstr += "\(a)"
                        }
                    case "ン":
                        result.append("ン")
                        if let a = UnicodeScalar(0x2FFC){
                            addstr += "\(a)"
                        }
                    default:
                        result.append(katakana[index])
                        if let a = UnicodeScalar(0x2FFC){
                            addstr += "\(a)"
                        }
                    }
                }else{
                    result.append(katakana[index])
                    if let a = UnicodeScalar(0x2FFC){
                        addstr += "\(a)"
                    }
                }
            case "ァ":
                result.append("ア")
                if let a = UnicodeScalar(0x2FFC){
                    addstr += "\(a)"
                }
            case "ィ":
                result.append("イ")
                if let a = UnicodeScalar(0x2FFC){
                    addstr += "\(a)"
                }
            case "ゥ":
                result.append("ウ")
                if let a = UnicodeScalar(0x2FFC){
                    addstr += "\(a)"
                }
            case "ェ":
                result.append("エ")
                if let a = UnicodeScalar(0x2FFC){
                    addstr += "\(a)"
                }
            case "ォ":
                result.append("オ")
                if let a = UnicodeScalar(0x2FFC){
                    addstr += "\(a)"
                }
            case "ガ":
                result.append("カ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "ギ":
                result.append("キ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "グ":
                result.append("ク")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "ゲ":
                result.append("ケ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "ゴ":
                result.append("コ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "ザ":
                result.append("サ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "ジ":
                result.append("シ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "ズ":
                result.append("ス")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "ゼ":
                result.append("セ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "ゾ":
                result.append("ソ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "ダ":
                result.append("タ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "ヂ":
                result.append("チ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "ヅ":
                result.append("ツ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "ッ":
                result.append("ツ")
                if let a = UnicodeScalar(0x2FFC){
                    addstr += "\(a)"
                }
            case "デ":
                result.append("テ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "ド":
                result.append("ト")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "バ":
                result.append("ハ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "パ":
                result.append("ハ")
                if let a = UnicodeScalar(0x2FFE){
                    addstr += "\(a)"
                }
            case "ビ":
                result.append("ヒ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "ピ":
                result.append("ヒ")
                if let a = UnicodeScalar(0x2FFE){
                    addstr += "\(a)"
                }
            case "ブ":
                result.append("フ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "プ":
                result.append("フ")
                if let a = UnicodeScalar(0x2FFE){
                    addstr += "\(a)"
                }
            case "ベ":
                result.append("ヘ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "ペ":
                result.append("ヘ")
                if let a = UnicodeScalar(0x2FFE){
                    addstr += "\(a)"
                }
            case "ボ":
                result.append("ホ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            case "ポ":
                result.append("ホ")
                if let a = UnicodeScalar(0x2FFE){
                    addstr += "\(a)"
                }
            case "ャ":
                result.append("ヤ")
                if let a = UnicodeScalar(0x2FFC){
                    addstr += "\(a)"
                }
            case "ュ":
                result.append("ユ")
                if let a = UnicodeScalar(0x2FFC){
                    addstr += "\(a)"
                }
            case "ョ":
                result.append("ヨ")
                if let a = UnicodeScalar(0x2FFC){
                    addstr += "\(a)"
                }
            case "ヮ":
                result.append("ワ")
                if let a = UnicodeScalar(0x2FFC){
                    addstr += "\(a)"
                }
            case "ヴ":
                result.append("ウ")
                if let a = UnicodeScalar(0x2FFD){
                    addstr += "\(a)"
                }
            default:
                result.append(katakana[index])
                if let a = UnicodeScalar(0x2FFC){
                    addstr += "\(a)"
                }
            }
        }
        
        var finalChar = result
        finalChar.append(addstr)
        return finalChar
    }
}
