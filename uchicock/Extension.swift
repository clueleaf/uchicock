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
        var katakana = self.katakana()
        var result = ""
        var addstr = ""
        
        let addResult = { (addToResult: String, addToAddstr: UInt32) in
            result.append(addToResult)
            if let us = UnicodeScalar(addToAddstr){
                addstr += "\(us)"
            }
        }
        
        for i in 0..<katakana.characters.count{
            let index = katakana.index(katakana.startIndex, offsetBy: i)
            switch katakana[index]{
            case "ー":
                if i > 0 {
                    let beforeIndex = katakana.index(katakana.startIndex, offsetBy: i-1)
                    switch katakana[beforeIndex]{
                    case "ァ", "ア", "カ", "ガ", "サ", "ザ", "タ", "ダ", "ナ", "ハ", "バ", "パ", "マ", "ヤ", "ャ", "ラ", "ワ", "ヮ":
                        addResult("ア",0x2FFC)
                    case "ィ", "イ", "キ", "ギ", "シ", "ジ", "チ", "ヂ", "ニ", "ヒ", "ビ", "ピ", "ミ", "リ", "ヰ":
                        addResult("イ",0x2FFC)
                    case "ゥ", "ウ", "ヴ", "ク", "グ", "ス", "ズ", "ツ", "ヅ", "ヌ", "フ", "ブ", "プ", "ム", "ユ", "ュ", "ル":
                        addResult("ウ",0x2FFC)
                    case "ェ", "エ", "ケ", "ゲ", "セ", "ゼ", "テ", "デ", "ネ", "ヘ", "ベ", "ペ", "メ", "レ", "ヱ":
                        addResult("エ",0x2FFC)
                    case "ォ", "オ", "コ", "ゴ", "ソ", "ゾ", "ト", "ド", "ノ", "ホ", "ボ", "ポ", "モ", "ヨ", "ョ", "ロ", "ヲ":
                        addResult("オ",0x2FFC)
                    case "ン":
                        addResult("ン",0x2FFC)
                    default:
                        addResult(String(katakana[index]),0x2FFC)
                    }
                }else{
                    addResult(String(katakana[index]),0x2FFC)
                }
            case "ァ": addResult("ア",0x2FFC)
            case "ィ": addResult("イ",0x2FFC)
            case "ゥ": addResult("ウ",0x2FFC)
            case "ェ": addResult("エ",0x2FFC)
            case "ォ": addResult("オ",0x2FFC)
            case "ガ": addResult("カ",0x2FFD)
            case "ギ": addResult("キ",0x2FFD)
            case "グ": addResult("ク",0x2FFD)
            case "ゲ": addResult("ケ",0x2FFD)
            case "ゴ": addResult("コ",0x2FFD)
            case "ザ": addResult("サ",0x2FFD)
            case "ジ": addResult("シ",0x2FFD)
            case "ズ": addResult("ス",0x2FFD)
            case "ゼ": addResult("セ",0x2FFD)
            case "ゾ": addResult("ソ",0x2FFD)
            case "ダ": addResult("タ",0x2FFD)
            case "ヂ": addResult("チ",0x2FFD)
            case "ヅ": addResult("ツ",0x2FFD)
            case "ッ": addResult("ツ",0x2FFC)
            case "デ": addResult("テ",0x2FFD)
            case "ド": addResult("ト",0x2FFD)
            case "バ": addResult("ハ",0x2FFD)
            case "パ": addResult("ハ",0x2FFE)
            case "ビ": addResult("ヒ",0x2FFD)
            case "ピ": addResult("ヒ",0x2FFE)
            case "ブ": addResult("フ",0x2FFD)
            case "プ": addResult("フ",0x2FFE)
            case "ベ": addResult("ヘ",0x2FFD)
            case "ペ": addResult("ヘ",0x2FFE)
            case "ボ": addResult("ホ",0x2FFD)
            case "ポ": addResult("ホ",0x2FFE)
            case "ャ": addResult("ヤ",0x2FFC)
            case "ュ": addResult("ユ",0x2FFC)
            case "ョ": addResult("ヨ",0x2FFC)
            case "ヮ": addResult("ワ",0x2FFC)
            case "ヴ": addResult("ウ",0x2FFD)
            default: addResult(String(katakana[index]),0x2FFC)
            }
        }
        
        result.append(addstr)
        return result
    }
}
