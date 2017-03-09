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
                        addstr += "\(UnicodeScalar(0x2FFC)!)"
                    case "ィ", "イ", "キ", "ギ", "シ", "ジ", "チ", "ヂ", "ニ", "ヒ", "ビ", "ピ", "ミ", "リ", "ヰ":
                        result.append("イ")
                        addstr += "\(UnicodeScalar(0x2FFC)!)"
                    case "ゥ", "ウ", "ヴ", "ク", "グ", "ス", "ズ", "ツ", "ヅ", "ヌ", "フ", "ブ", "プ", "ム", "ユ", "ュ", "ル":
                        result.append("ウ")
                        addstr += "\(UnicodeScalar(0x2FFC)!)"
                    case "ェ", "エ", "ケ", "ゲ", "セ", "ゼ", "テ", "デ", "ネ", "ヘ", "ベ", "ペ", "メ", "レ", "ヱ":
                        result.append("エ")
                        addstr += "\(UnicodeScalar(0x2FFC)!)"
                    case "ォ", "オ", "コ", "ゴ", "ソ", "ゾ", "ト", "ド", "ノ", "ホ", "ボ", "ポ", "モ", "ヨ", "ョ", "ロ", "ヲ":
                        result.append("オ")
                        addstr += "\(UnicodeScalar(0x2FFC)!)"
                    case "ン":
                        result.append("ン")
                        addstr += "\(UnicodeScalar(0x2FFC)!)"
                    default:
                        result.append(katakana[index])
                        addstr += "\(UnicodeScalar(0x2FFC)!)"
                    }
                }else{
                    result.append(katakana[index])
                    addstr += "\(UnicodeScalar(0x2FFC)!)"
                }
            case "ァ":
                result.append("ア")
                addstr += "\(UnicodeScalar(0x2FFC)!)"
            case "ィ":
                result.append("イ")
                addstr += "\(UnicodeScalar(0x2FFC)!)"
            case "ゥ":
                result.append("ウ")
                addstr += "\(UnicodeScalar(0x2FFC)!)"
            case "ェ":
                result.append("エ")
                addstr += "\(UnicodeScalar(0x2FFC)!)"
            case "ォ":
                result.append("オ")
                addstr += "\(UnicodeScalar(0x2FFC)!)"
            case "ガ":
                result.append("カ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "ギ":
                result.append("キ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "グ":
                result.append("ク")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "ゲ":
                result.append("ケ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "ゴ":
                result.append("コ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "ザ":
                result.append("サ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "ジ":
                result.append("シ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "ズ":
                result.append("ス")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "ゼ":
                result.append("セ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "ゾ":
                result.append("ソ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "ダ":
                result.append("タ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "ヂ":
                result.append("チ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "ヅ":
                result.append("ツ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "ッ":
                result.append("ツ")
                addstr += "\(UnicodeScalar(0x2FFC)!)"
            case "デ":
                result.append("テ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "ド":
                result.append("ト")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "バ":
                result.append("ハ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "パ":
                result.append("ハ")
                addstr += "\(UnicodeScalar(0x2FFE)!)"
            case "ビ":
                result.append("ヒ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "ピ":
                result.append("ヒ")
                addstr += "\(UnicodeScalar(0x2FFE)!)"
            case "ブ":
                result.append("フ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "プ":
                result.append("フ")
                addstr += "\(UnicodeScalar(0x2FFE)!)"
            case "ベ":
                result.append("ヘ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "ペ":
                result.append("ヘ")
                addstr += "\(UnicodeScalar(0x2FFE)!)"
            case "ボ":
                result.append("ホ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            case "ポ":
                result.append("ホ")
                addstr += "\(UnicodeScalar(0x2FFE)!)"
            case "ャ":
                result.append("ヤ")
                addstr += "\(UnicodeScalar(0x2FFC)!)"
            case "ュ":
                result.append("ユ")
                addstr += "\(UnicodeScalar(0x2FFC)!)"
            case "ョ":
                result.append("ヨ")
                addstr += "\(UnicodeScalar(0x2FFC)!)"
            case "ヮ":
                result.append("ワ")
                addstr += "\(UnicodeScalar(0x2FFC)!)"
            case "ヴ":
                result.append("ウ")
                addstr += "\(UnicodeScalar(0x2FFD)!)"
            default:
                result.append(katakana[index])
                addstr += "\(UnicodeScalar(0x2FFC)!)"
            }
        }
        
        var finalChar = result
        finalChar.append(addstr)
        return finalChar
    }
}
