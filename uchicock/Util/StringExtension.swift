//
//  StringExtension.swift
//  uchicock
//
//  Created by Kou Kinyo on 2016/04/27.
//  Copyright © 2016年 Kou. All rights reserved.
//

import UIKit

extension String {
//    func katakana() -> String {
//        var str = ""
//        for c in unicodeScalars {
//            if c.value >= 0x3041 && c.value <= 0x3096 {
//                if let u = UnicodeScalar(c.value+96){
//                    str += "\(u)"
//                }
//            } else {
//                str += "\(c)"
//            }
//        }
//        return str
//    }
    
//    func hiragana() -> String {
//        var str = ""
//        for c in unicodeScalars {
//            if c.value >= 0x30A1 && c.value <= 0x30F6 {
//                if let u = UnicodeScalar(c.value-96){
//                    str += "\(u)"
//                }
//            } else {
//                str += "\(c)"
//            }
//        }
//        return str
//    }
    
    func withoutEndsSpace() -> String{
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func withoutMiddleSpaceAndMiddleDot() -> String{
        // 半角スペース、全角スペース、中黒は取り除く
        let passedUnicodeScalars = self.unicodeScalars.filter { [0x0020,0x3000,0x30FB].contains($0.value) == false }
        return String(String.UnicodeScalarView(passedUnicodeScalars)).withoutEndsSpace()
    }
    
    func katakanaLowercasedForSearch() -> String{
        var convertedString = ""

        let passedUnicodeScalars = self.withoutMiddleSpaceAndMiddleDot().unicodeScalars

        for unicodeScalar in passedUnicodeScalars {
            var convertedUnicodeScalar = unicodeScalar

            // ひらがなはカタカナに変換
            if unicodeScalar.value >= 0x3041 && unicodeScalar.value <= 0x3096 {
                if let katakana = UnicodeScalar(unicodeScalar.value+96){
                    convertedUnicodeScalar = katakana
                }
            }
            
            switch convertedUnicodeScalar.value {
            case 0x30A1, 0x30A3, 0x30A5, 0x30A7, 0x30A9, 0x30C3, 0x30E3, 0x30E5, 0x30E7, 0x30EE:
                // 「ァィゥェォッャュョヮ」を「アイウエオツヤユヨワ」に変換
                if let u = UnicodeScalar(convertedUnicodeScalar.value+1){
                    convertedUnicodeScalar = u
                }
            case 0x30F4:
                // 「ヴ」を「ウ」に変換
                convertedUnicodeScalar = UnicodeScalar("ウ")
            case 0x30F5, 0x30F6:
                // 「ヵヶ」を「カ」に変換
                convertedUnicodeScalar = UnicodeScalar("カ")
            case 0x30AC, 0x30AE, 0x30B0, 0x30B2, 0x30B4, 0x30B6, 0x30B8, 0x30BA, 0x30BC, 0x30BE,
                 0x30C0, 0x30C2, 0x30C5, 0x30C7, 0x30C9, 0x30D0, 0x30D3, 0x30D6, 0x30D9, 0x30DC:
                // 濁音（ガギグゲゴザジズゼゾダヂヅデドバビブベボ）を清音（カキクケコサシスセソタチツテトハヒフヘホ）に変換
                if let u = UnicodeScalar(convertedUnicodeScalar.value-1){
                    convertedUnicodeScalar = u
                }
            case 0x30D1, 0x30D4, 0x30D7, 0x30DA, 0x30DD:
                // 半濁音（パピプペポ）を清音（ハヒフヘホ）に変換
                if let u = UnicodeScalar(convertedUnicodeScalar.value-2){
                    convertedUnicodeScalar = u
                }
            default:
                break
            }

            convertedString += "\(convertedUnicodeScalar)"
        }
        
        return convertedString.lowercased()
    }
    
    private func withoutEndsSpaceAndMiddleDot() -> String{
        // 中黒は取り除く
        let passedUnicodeScalars = self.unicodeScalars.filter { [0x30FB].contains($0.value) == false }
        return String(String.UnicodeScalarView(passedUnicodeScalars)).withoutEndsSpace()
    }

    private func convertJapaneseToYomi() -> String{
        let input = self.withoutEndsSpaceAndMiddleDot()

        var output = ""
        let locale = CFLocaleCreate(kCFAllocatorDefault, CFLocaleCreateCanonicalLanguageIdentifierFromString(kCFAllocatorDefault, "ja" as CFString))
        let range = CFRangeMake(0, input.utf16.count)
        let tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, input as CFString, range, kCFStringTokenizerUnitWordBoundary, locale)

        var tokenType = CFStringTokenizerGoToTokenAtIndex(tokenizer, 0)
        while (tokenType.rawValue != 0) {
            if let text = (CFStringTokenizerCopyCurrentTokenAttribute(tokenizer, kCFStringTokenizerAttributeLatinTranscription) as? NSString).map({ $0.mutableCopy() }) {
                CFStringTransform((text as! CFMutableString), nil, kCFStringTransformLatinKatakana, false)
                output.append(text as! String)
            }
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }
        return output
    }
        
    func convertToYomi() -> String{
        var output = self.withoutEndsSpaceAndMiddleDot().lowercased()

        let sakePattern = "日本酒"
        let sakeRegex = try! NSRegularExpression(pattern: sakePattern, options: [])
        let sakeResults = sakeRegex.matches(in: output, options: [], range: NSMakeRange(0, output.utf16.count))

        for result in sakeResults.reversed() {
            let subStr = (output as NSString).substring(with: result.range)
            output = output.replacingOccurrences(of: subStr, with: "ニホンシュ")
        }

        let sugarPattern = "角砂糖"
        let sugarRegex = try! NSRegularExpression(pattern: sugarPattern, options: [])
        let sugarResults = sugarRegex.matches(in: output, options: [], range: NSMakeRange(0, output.utf16.count))

        for result in sugarResults.reversed() {
            let subStr = (output as NSString).substring(with: result.range)
            output = output.replacingOccurrences(of: subStr, with: "カクザトウ")
        }

        let englishPattern = "[^a-zA-Z 　]+"
        let englishRegex = try! NSRegularExpression(pattern: englishPattern, options: [])
        let englishResults = englishRegex.matches(in: output, options: [], range: NSMakeRange(0, output.utf16.count))
        
        for result in englishResults.reversed() {
            let subStr = (output as NSString).substring(with: result.range)
            output = output.replacingOccurrences(of: subStr, with: subStr.convertJapaneseToYomi())
        }

        return output
    }
    
    func categoryNumber() -> Int {
        switch self{
        case "ウォッカ": return 0
        case "テキーラ": return 0
        case "ジン": return 0
        case "ドライジン": return 0
        case "ブランデー": return 0
        case "チェリーブランデー": return 0
        case "ラム": return 0
        case "ホワイトラム": return 0
        case "ダークラム": return 0
        case "ゴールドラム": return 0
        case "ウィスキー": return 0
        case "ウイスキー": return 0
        case "バーボンウィスキー": return 0
        case "バーボンウイスキー": return 0
        case "アイリッシュウィスキー": return 0
        case "アイリッシュウイスキー": return 0
        case "スコッチウィスキー": return 0
        case "スコッチウイスキー": return 0
        case "カナディアンウィスキー": return 0
        case "カナディアンウイスキー": return 0
        case "アメリカンウィスキー": return 0
        case "アメリカンウイスキー": return 0
        case "テネシーウィスキー": return 0
        case "テネシーウイスキー": return 0
        case "ライウィスキー": return 0
        case "ライウイスキー": return 0
        case "ジャパニーズウィスキー": return 0
        case "ジャパニーズウイスキー": return 0
        case "アマレット": return 0
        case "オレンジキュラソー": return 0
        case "ブルーキュラソー": return 0
        case "ホワイトキュラソー": return 0
        case "コアントロー": return 0
        case "カルーア": return 0
        case "カンパリ": return 0
        case "クレームドカカオ": return 0
        case "クレームドカカオホワイト": return 0
        case "クレームドカシス": return 0
        case "クレームドフランボワーズ": return 0
        case "クレームドアプリコット": return 0
        case "ディタ": return 0
        case "ドライベルモット": return 0
        case "スイートベルモット": return 0
        case "ピーチツリー": return 0
        case "ベイリーズ": return 0
        case "マンゴヤン": return 0
        case "ミドリ": return 0
        case "ペパーミント": return 0
        case "ホワイトペパーミント": return 0
        case "マリブ": return 0
        case "ティフィン": return 0
        case "パッソア": return 0
        case "アンゴスチュラビターズ": return 0
        case "ビール": return 0
        case "赤ワイン": return 0
        case "白ワイン": return 0
        case "ワイン": return 0
        case "シャンパン": return 0
        case "スパークリングワイン": return 0
        case "紹興酒": return 0
        case "日本酒": return 0
            
        case "アップルジュース": return 1
        case "オレンジジュース": return 1
        case "グレープジュース": return 1
        case "グレープフルーツジュース": return 1
        case "トマトジュース": return 1
        case "パイナップルジュース": return 1
        case "ライムジュース": return 1
        case "クランベリージュース": return 1
        case "レモンジュース": return 1
        case "コーラ": return 1
        case "コカコーラ": return 1
        case "ジンジャエール": return 1
        case "ソーダ": return 1
        case "トニックウォーター": return 1
        case "ミネラルウォーター": return 1
        case "ウーロン茶": return 1
        case "烏龍茶": return 1
        case "牛乳": return 1
        case "ミルク": return 1
        case "レモネード": return 1
        case "アイスコーヒー": return 1
        case "ホットコーヒー": return 1
        case "ピーチネクター": return 1

        default: return 2
        }
    }
    
    func cocktailStyleNumber() -> Int {
        switch self{
        case "アイスブレーカー": return 0
        case "アクア": return 0
        case "アップタウン": return 0
        case "アフターミッドナイト": return 0
        case "アプリコットコラーダ": return 0
        case "アマレットジンジャー": return 0
        case "アメリカーノ": return 0
        case "アメリカンレモネード": return 0
        case "アンバサダー": return 0
        case "イタリアンサーファー": return 0
        case "イタリアンスクリュードライバー": return 0
        case "ウィスキーサワー": return 0
        case "ウィスキーフロート": return 0
        case "ウイニングラン": return 0
        case "ウォッカアップル": return 0
        case "ウォッカリッキー": return 0
        case "エッグビール": return 0
        case "エメラルドクーラー": return 0
        case "エメラルドミスト": return 0
        case "エルディアブロ": return 0
        case "エルドラド": return 0
        case "オールドファッションド": return 0
        case "オペレーター": return 0
        case "オレンジフィズ": return 0
        case "カーディナル": return 0
        case "カカオフィズ": return 0
        case "カサブランカ": return 0
        case "カシスオレンジ": return 0
        case "カミカゼ": return 0
        case "カリフォルニアレモネード": return 0
        case "カリモーチョ": return 0
        case "カルーアソーダ": return 0
        case "カルーアミルク": return 0
        case "ガルフストリーム": return 0
        case "カンパリオレンジ": return 0
        case "カンパリソーダ": return 0
        case "カンパリビア": return 0
        case "キールインペリアル": return 0
        case "キールロワイヤル": return 0
        case "キティ": return 0
        case "キューバリバー": return 0
        case "キューバンスクリュー": return 0
        case "クイーンズペッグ": return 0
        case "クラーラ": return 0
        case "クラウドバスター": return 0
        case "クリーミードライバー": return 0
        case "グリーンアイズ": return 0
        case "グリーンスパイダー": return 0
        case "クリス": return 0
        case "ケープコッダー": return 0
        case "ケーブルグラム": return 0
        case "コークハイ": return 0
        case "ゴールデンフレンド": return 0
        case "ゴッドファーザー": return 0
        case "ゴッドマザー": return 0
        case "サマーデライト": return 0
        case "サムライロック": return 0
        case "サラトガクーラー": return 0
        case "サンセットピーチ": return 0
        case "シーブリーズ": return 0
        case "シカゴ": return 0
        case "シャーリーテンプル": return 0
        case "ジャマイカンミュール": return 0
        case "シャンディガフ": return 0
        case "シャンパンカクテル": return 0
        case "シャンパンブルース": return 0
        case "ジョンコリンズ": return 0
        case "ジンアンドビターズ": return 0
        case "シンガポールスリング": return 0
        case "ジンデイジー": return 0
        case "ジントニック": return 0
        case "ジンバック": return 0
        case "ジンフィズ": return 0
        case "ジンリッキー": return 0
        case "スクリュードライバー": return 0
        case "スコーピオン": return 0
        case "ストーンフェンス": return 0
        case "ストローハット": return 0
        case "スプモーニ": return 0
        case "スプリッツァー": return 0
        case "セックスオンザビーチ": return 0
        case "ソルクバーノ": return 0
        case "ソルティドッグ": return 0
        case "ソルティブル": return 0
        case "ソルトリック": return 0
        case "ダージリンクーラー": return 0
        case "ダイヤモンドフィズ": return 0
        case "チチ": return 0
        case "チャイナカシス": return 0
        case "チャイナグリーン": return 0
        case "チャイナブルー": return 0
        case "チャロネロ": return 0
        case "ディーゼル": return 0
        case "ディタモーニ": return 0
        case "ティフィンカシスティー": return 0
        case "ティフィンタイガー": return 0
        case "ティフィンミルク": return 0
        case "ティフィンモヒート": return 0
        case "ティントデベラーノ": return 0
        case "テキーラサンストローク": return 0
        case "テキーラサンセット": return 0
        case "テキーラサンライズ": return 0
        case "テキサスフィズ": return 0
        case "デザートヒーラー": return 0
        case "ドッグズノーズ": return 0
        case "ドラゴンウォーター": return 0
        case "ドラゴンフライ": return 0
        case "ドランブイトニック": return 0
        case "ネグローニ": return 0
        case "パープルパッション": return 0
        case "ハイボール": return 0
        case "パッシモーニ": return 0
        case "パッションオレンジ": return 0
        case "パディ": return 0
        case "パナシェ": return 0
        case "ビアスプリッツァー": return 0
        case "ビアモーニ": return 0
        case "ビショップ": return 0
        case "ビターオレンジ": return 0
        case "ピニャコラーダ": return 0
        case "ファジーネーブル": return 0
        case "ブラックルシアン": return 0
        case "ブラックレイン": return 0
        case "ブラックローズ": return 0
        case "ブラッディメアリー": return 0
        case "ブランデーサワー": return 0
        case "ブルーコラーダ": return 0
        case "ブルーハワイ": return 0
        case "ブルーラグーン": return 0
        case "ブルドッグ": return 0
        case "フレンチ75": return 0
        case "フレンチエメラルド": return 0
        case "フレンチカクタス": return 0
        case "フレンチコネクション": return 0
        case "ベイブリーズ": return 0
        case "ベイリーズミルク": return 0
        case "ベリーニ": return 0
        case "ボイラーメーカー": return 0
        case "ホーセズネック": return 0
        case "ボストンクーラー": return 0
        case "ボッチボール": return 0
        case "ホワイトルシアン": return 0
        case "ポンセデレオン": return 0
        case "ポンピエ": return 0
        case "マイタイ": return 0
        case "マザグラン": return 0
        case "マタドール": return 0
        case "マドラス": return 0
        case "マミーテイラー": return 0
        case "マヤ": return 0
        case "マリブコーク": return 0
        case "マリブサーフ": return 0
        case "マリブパイン": return 0
        case "マリブビーチ": return 0
        case "マリブミルク": return 0
        case "マンゴヤンオレンジ": return 0
        case "マンゴヤンミルク": return 0
        case "マンドビル": return 0
        case "ミドリミルク": return 0
        case "ミモザ": return 0
        case "ミルクセーキ": return 0
        case "ミントジュレップ": return 0
        case "ミントビア": return 0
        case "メキシカンミュール": return 0
        case "メロンボール": return 0
        case "モスコミュール": return 0
        case "モヒート": return 0
        case "モンキーズポウ": return 0
        case "モンキーミックス": return 0
        case "ライトオンディタ": return 0
        case "ラスティネイル": return 0
        case "ラテンラバー": return 0
        case "ラムコリンズ": return 0
        case "ラムジュレップ": return 0
        case "ランチボックス": return 0
        case "ルシアンネイル": return 0
        case "レゲエパンチ": return 0
        case "レッドアイ": return 0
        case "レッドバード": return 0
        case "ロックローモンド": return 0
        case "ロングアイランドアイスティー": return 0
        case "ワインクーラー": return 0
        case "香港フィズ": return 0
        case "照葉樹林": return 0
        case "上海ハイボール": return 0
            
        case "アースクエイク": return 1
        case "アイデアル": return 1
        case "アイリッシュローズ": return 1
        case "アカプルコ": return 1
        case "アディオスアミーゴス": return 1
        case "アドニス": return 1
        case "アナウンサー": return 1
        case "アフィニティ": return 1
        case "アブサンエッグ": return 1
        case "アモーレ": return 1
        case "アラウンドザワールド": return 1
        case "アラワク": return 1
        case "アルフィー": return 1
        case "アレキサンダー": return 1
        case "アロハ": return 1
        case "アンシェリダン": return 1
        case "イーストインディア": return 1
        case "イエスアンドノー": return 1
        case "イエローフェロー": return 1
        case "インクストリート": return 1
        case "ウィリースミス": return 1
        case "エックスワイジー": return 1
        case "エム45": return 1
        case "エルプレジデンテ": return 1
        case "エンジェルキッス": return 1
        case "エンジェルズデライト": return 1
        case "オーガズム": return 1
        case "オーキッド": return 1
        case "オープンハートリーフ": return 1
        case "オールドクロック": return 1
        case "オールドパル": return 1
        case "オリエンタル": return 1
        case "オリンピック": return 1
        case "オレンジブルーム": return 1
        case "オレンジブロッサム": return 1
        case "カウボーイ": return 1
        case "カジノ": return 1
        case "カリブ": return 1
        case "キール": return 1
        case "キッスインザダーク": return 1
        case "キッスオブファイア": return 1
        case "ギムレット": return 1
        case "キャメロンズキック": return 1
        case "キングスバレー": return 1
        case "ギンザストリート": return 1
        case "クイーンエリザベス": return 1
        case "クールバナナ": return 1
        case "クラシック": return 1
        case "グラスホッパー": return 1
        case "グリーンシー": return 1
        case "グリーンフィールズ": return 1
        case "クローバークラブ": return 1
        case "ケリーブルー": return 1
        case "ケンタッキー": return 1
        case "ゴーリキーパーク": return 1
        case "コザック": return 1
        case "コスモポリタン": return 1
        case "コモドール": return 1
        case "コルクスクリュー": return 1
        case "コルコバード": return 1
        case "コンチータ": return 1
        case "サイドカー": return 1
        case "ザザ": return 1
        case "サンチャゴ": return 1
        case "シクラメン": return 1
        case "シルクストッキングス": return 1
        case "シルバーウィング": return 1
        case "ジンアンドイット": return 1
        case "シンデレラ": return 1
        case "ズーム": return 1
        case "スカイダイビング": return 1
        case "スティンガー": return 1
        case "スパイダーキッス": return 1
        case "スペシャルラフ": return 1
        case "スモーキーマティーニ": return 1
        case "スリーミラーズ": return 1
        case "スレッジハンマー": return 1
        case "セブンスヘブン": return 1
        case "ソウルキッス": return 1
        case "ダーティーマザー": return 1
        case "ダイキリ": return 1
        case "タンゴ": return 1
        case "チェリーブロッサム": return 1
        case "チャーチル": return 1
        case "テキーラマンハッタン": return 1
        case "デビル": return 1
        case "トロイカ": return 1
        case "ドローレス": return 1
        case "ナデシコ": return 1
        case "ニューヨーク": return 1
        case "ネバダ": return 1
        case "ハーバード": return 1
        case "バーバラ": return 1
        case "バーバリーコースト": return 1
        case "バーボネラ": return 1
        case "パールハーバー": return 1
        case "ハイライフ": return 1
        case "バカラ": return 1
        case "パナマ": return 1
        case "ハニーサックル": return 1
        case "ハバナピーチ": return 1 // v2.2以前のレシピ誤植対応
        case "ハバナビーチ": return 1
        case "パラダイス": return 1
        case "バラライカ": return 1
        case "ハリケーン": return 1
        case "パリジャン": return 1
        case "バレンシア": return 1
        case "ハワイアン": return 1
        case "ハンター": return 1
        case "ビーズキッス": return 1
        case "ビーズニーズ": return 1
        case "ピカドール": return 1
        case "ビトウィーンザシーツ": return 1
        case "ピンクジン": return 1
        case "ピンクレディ": return 1
        case "フィフスアベニュー": return 1
        case "プッシーフット": return 1
        case "プラチナブロンド": return 1
        case "ブラックホーク": return 1
        case "ブラッドアンドサンド": return 1
        case "ブラッドトランスフュージョン": return 1
        case "フラミンゴレディ": return 1
        case "プランターズカクテル": return 1
        case "ブリザード": return 1
        case "プリンセスメアリー": return 1
        case "ブルートリップ": return 1
        case "ブルーマルガリータ": return 1
        case "ブルーマンデー": return 1
        case "ブルームーン": return 1
        case "ブレインヘモレージ": return 1
        case "ブロードウェイサースト": return 1
        case "プロポーズ": return 1
        case "フロリダ": return 1
        case "ブロンクス": return 1
        case "ブロンクスゴールド": return 1
        case "ヘアオブザドッグ": return 1
        case "ホールインワン": return 1
        case "ホノルル": return 1
        case "ポロネーズ": return 1
        case "ホワイトウェイ": return 1
        case "ホワイトスパイダー": return 1
        case "ホワイトスワン": return 1
        case "ホワイトレディ": return 1
        case "ホワイトローズ": return 1
        case "マイアミ": return 1
        case "マイアミビーチ": return 1
        case "マイトウキョウ": return 1
        case "マグノリアブロッサム": return 1
        case "マジックトレース": return 1
        case "マティーニ": return 1
        case "マリリンモンロー": return 1
        case "マルガリータ": return 1
        case "マンハッタン": return 1
        case "ミッドナイトカウボーイ": return 1
        case "ミリオネア": return 1
        case "ミリオンダラー": return 1
        case "ムーランルージュ": return 1
        case "ムーングロー": return 1
        case "メアリーピックフォード": return 1
        case "メキシカン": return 1
        case "メリーウィドウ": return 1
        case "ユニオンジャック": return 1
        case "ラストキッス": return 1
        case "リトルデビル": return 1
        case "リトルプリンセス": return 1
        case "ルシアン": return 1
        case "ロージーディーコン": return 1
        case "ロードランナー": return 1
        case "ロサンゼルス": return 1
        case "ロブロイ": return 1
        case "ワードエイト": return 1
        case "ワンモアフォーザロード": return 1
        case "青い珊瑚礁": return 1
        case "雪国": return 1
            
        case "アイリッシュコーヒー": return 2
        case "グロッグ": return 2
        case "トムアンドジェリー": return 2
        case "ホットイタリアン": return 2
        case "ホットウィスキートディ": return 2
        case "ホットカンパリ": return 2
        case "ホットドラム": return 2

        default: return 3
        }
    }
    
    func cocktailStrengthNumber() -> Int {
        switch self{
        case "サマーデライト": return 0
        case "サラトガクーラー": return 0
        case "サンセットピーチ": return 0
        case "シャーリーテンプル": return 0
        case "シンデレラ": return 0
        case "プッシーフット": return 0
        case "フロリダ": return 0
        case "ミルクセーキ": return 0

        case "アプリコットコラーダ": return 1
        case "アマレットジンジャー": return 1
        case "アメリカーノ": return 1
        case "アメリカンレモネード": return 1
        case "イタリアンスクリュードライバー": return 1
        case "ウイニングラン": return 1
        case "エッグビール": return 1
        case "オペレーター": return 1
        case "カカオフィズ": return 1
        case "カシスオレンジ": return 1
        case "カリモーチョ": return 1
        case "カルーアソーダ": return 1
        case "カルーアミルク": return 1
        case "カンパリオレンジ": return 1
        case "カンパリソーダ": return 1
        case "キティ": return 1
        case "クラーラ": return 1
        case "クリーミードライバー": return 1
        case "シャンディガフ": return 1
        case "スプモーニ": return 1
        case "スプリッツァー": return 1
        case "セックスオンザビーチ": return 1
        case "ダージリンクーラー": return 1
        case "チチ": return 1
        case "チャイナグリーン": return 1
        case "チャイナブルー": return 1
        case "ディーゼル": return 1
        case "ディタモーニ": return 1
        case "ティフィンカシスティー": return 1
        case "ティフィンタイガー": return 1
        case "ティフィンミルク": return 1
        case "ティフィンモヒート": return 1
        case "ティントデベラーノ": return 1
        case "ドラゴンウォーター": return 1
        case "ナデシコ": return 1
        case "パッシモーニ": return 1
        case "パッションオレンジ": return 1
        case "パナシェ": return 1
        case "ビアスプリッツァー": return 1
        case "ビアモーニ": return 1
        case "ビターオレンジ": return 1
        case "ピニャコラーダ": return 1
        case "ファジーネーブル": return 1
        case "ブルーコラーダ": return 1
        case "ベイリーズミルク": return 1
        case "ベリーニ": return 1
        case "ボッチボール": return 1
        case "ホットイタリアン": return 1
        case "ホットカンパリ": return 1
        case "ホワイトスワン": return 1
        case "ポンピエ": return 1
        case "マリブコーク": return 1
        case "マリブサーフ": return 1
        case "マリブパイン": return 1
        case "マリブビーチ": return 1
        case "マリブミルク": return 1
        case "マンゴヤンオレンジ": return 1
        case "マンゴヤンミルク": return 1
        case "ミドリミルク": return 1
        case "ミモザ": return 1
        case "ミントビア": return 1
        case "メロンボール": return 1
        case "モンキーミックス": return 1
        case "ライトオンディタ": return 1
        case "ランチボックス": return 1
        case "レゲエパンチ": return 1
        case "レッドアイ": return 1
        case "ワインクーラー": return 1
        case "上海ハイボール": return 1
        case "照葉樹林": return 1
        case "香港フィズ": return 1

        case "アイスブレーカー": return 2
        case "アイデアル": return 2
        case "アイリッシュコーヒー": return 2
        case "アクア": return 2
        case "アップタウン": return 2
        case "アドニス": return 2
        case "アブサンエッグ": return 2
        case "アモーレ": return 2
        case "アレキサンダー": return 2
        case "アンシェリダン": return 2
        case "アンバサダー": return 2
        case "イエローフェロー": return 2
        case "イタリアンサーファー": return 2
        case "インクストリート": return 2
        case "ウィスキーフロート": return 2
        case "ウォッカアップル": return 2
        case "ウォッカリッキー": return 2
        case "エメラルドクーラー": return 2
        case "エルディアブロ": return 2
        case "エルドラド": return 2
        case "エンジェルキッス": return 2
        case "エンジェルズデライト": return 2
        case "オーガズム": return 2
        case "オーキッド": return 2
        case "オープンハートリーフ": return 2
        case "オリンピック": return 2
        case "オレンジフィズ": return 2
        case "カーディナル": return 2
        case "カウボーイ": return 2
        case "カサブランカ": return 2
        case "カリブ": return 2
        case "カリフォルニアレモネード": return 2
        case "ガルフストリーム": return 2
        case "カンパリビア": return 2
        case "キール": return 2
        case "キールインペリアル": return 2
        case "キールロワイヤル": return 2
        case "キューバリバー": return 2
        case "キューバンスクリュー": return 2
        case "ギンザストリート": return 2
        case "クールバナナ": return 2
        case "クイーンズペッグ": return 2
        case "クラウドバスター": return 2
        case "グラスホッパー": return 2
        case "グリーンアイズ": return 2
        case "グリーンフィールズ": return 2
        case "クリス": return 2
        case "クローバークラブ": return 2
        case "グロッグ": return 2
        case "ケープコッダー": return 2
        case "ケーブルグラム": return 2
        case "コークハイ": return 2
        case "ゴールデンフレンド": return 2
        case "コンチータ": return 2
        case "サムライロック": return 2
        case "シーブリーズ": return 2
        case "シカゴ": return 2
        case "ジャマイカンミュール": return 2
        case "シャンパンカクテル": return 2
        case "シャンパンブルース": return 2
        case "ジョンコリンズ": return 2
        case "シンガポールスリング": return 2
        case "ジントニック": return 2
        case "ジンバック": return 2
        case "ジンフィズ": return 2
        case "ジンリッキー": return 2
        case "ズーム": return 2
        case "スクリュードライバー": return 2
        case "スコーピオン": return 2
        case "ストーンフェンス": return 2
        case "ストローハット": return 2
        case "スパイダーキッス": return 2
        case "スペシャルラフ": return 2
        case "ソウルキッス": return 2
        case "ソルクバーノ": return 2
        case "ソルティドッグ": return 2
        case "ソルティブル": return 2
        case "ソルトリック": return 2
        case "ダイヤモンドフィズ": return 2
        case "タンゴ": return 2
        case "チャイナカシス": return 2
        case "チャロネロ": return 2
        case "テキーラサンストローク": return 2
        case "テキーラサンセット": return 2
        case "テキーラサンライズ": return 2
        case "テキサスフィズ": return 2
        case "デザートヒーラー": return 2
        case "ドッグズノーズ": return 2
        case "トムアンドジェリー": return 2
        case "ドラゴンフライ": return 2
        case "ドランブイトニック": return 2
        case "パープルパッション": return 2
        case "パールハーバー": return 2
        case "ハイボール": return 2
        case "ハイライフ": return 2
        case "ハバナピーチ": return 2 // v2.2以前のレシピ誤植対応
        case "ハバナビーチ": return 2
        case "パラダイス": return 2
        case "バレンシア": return 2
        case "ビーズキッス": return 2
        case "ビショップ": return 2
        case "ピンクレディ": return 2
        case "フィフスアベニュー": return 2
        case "ブラックレイン": return 2
        case "ブラックローズ": return 2
        case "ブラッディメアリー": return 2
        case "ブラッドアンドサンド": return 2
        case "ブラッドトランスフュージョン": return 2
        case "フラミンゴレディ": return 2
        case "プランターズカクテル": return 2
        case "ブリザード": return 2
        case "プリンセスメアリー": return 2
        case "ブルーハワイ": return 2
        case "ブルーラグーン": return 2
        case "ブルドッグ": return 2
        case "ブレインヘモレージ": return 2
        case "フレンチ75": return 2
        case "フレンチエメラルド": return 2
        case "ブロードウェイサースト": return 2
        case "プロポーズ": return 2
        case "ブロンクスゴールド": return 2
        case "ヘアオブザドッグ": return 2
        case "ベイブリーズ": return 2
        case "ホーセズネック": return 2
        case "ボイラーメーカー": return 2
        case "ボストンクーラー": return 2
        case "ホットウィスキートディ": return 2
        case "ホットドラム": return 2
        case "ホワイトローズ": return 2
        case "ポンセデレオン": return 2
        case "マグノリアブロッサム": return 2
        case "マザグラン": return 2
        case "マタドール": return 2
        case "マドラス": return 2
        case "マミーテイラー": return 2
        case "マヤ": return 2
        case "マンドビル": return 2
        case "ミリオネア": return 2
        case "ミリオンダラー": return 2
        case "ムーングロー": return 2
        case "メアリーピックフォード": return 2
        case "メキシカン": return 2
        case "メキシカンミュール": return 2
        case "モスコミュール": return 2
        case "モヒート": return 2
        case "モンキーズポウ": return 2
        case "ラムコリンズ": return 2
        case "レッドバード": return 2
        case "ロージーディーコン": return 2
        case "ロサンゼルス": return 2
        case "ロングアイランドアイスティー": return 2
        case "ワードエイト": return 2
        case "ワンモアフォーザロード": return 2
            
        case "アースクエイク": return 3
        case "アイリッシュローズ": return 3
        case "アカプルコ": return 3
        case "アディオスアミーゴス": return 3
        case "アナウンサー": return 3
        case "アフィニティ": return 3
        case "アフターミッドナイト": return 3
        case "アラウンドザワールド": return 3
        case "アラワク": return 3
        case "アルフィー": return 3
        case "アロハ": return 3
        case "イーストインディア": return 3
        case "イエスアンドノー": return 3
        case "ウィスキーサワー": return 3
        case "ウィリースミス": return 3
        case "エックスワイジー": return 3
        case "エム45": return 3
        case "エメラルドミスト": return 3
        case "エルプレジデンテ": return 3
        case "オールドクロック": return 3
        case "オールドパル": return 3
        case "オールドファッションド": return 3
        case "オリエンタル": return 3
        case "オレンジブルーム": return 3
        case "オレンジブロッサム": return 3
        case "カジノ": return 3
        case "カミカゼ": return 3
        case "キッスインザダーク": return 3
        case "キッスオブファイア": return 3
        case "ギムレット": return 3
        case "キャメロンズキック": return 3
        case "キングスバレー": return 3
        case "クイーンエリザベス": return 3
        case "クラシック": return 3
        case "グリーンシー": return 3
        case "グリーンスパイダー": return 3
        case "ケリーブルー": return 3
        case "ケンタッキー": return 3
        case "ゴーリキーパーク": return 3
        case "コザック": return 3
        case "コスモポリタン": return 3
        case "ゴッドファーザー": return 3
        case "ゴッドマザー": return 3
        case "コモドール": return 3
        case "コルクスクリュー": return 3
        case "コルコバード": return 3
        case "サイドカー": return 3
        case "ザザ": return 3
        case "サンチャゴ": return 3
        case "シクラメン": return 3
        case "シルクストッキングス": return 3
        case "シルバーウィング": return 3
        case "ジンアンドイット": return 3
        case "ジンアンドビターズ": return 3
        case "ジンデイジー": return 3
        case "スカイダイビング": return 3
        case "スティンガー": return 3
        case "スモーキーマティーニ": return 3
        case "スリーミラーズ": return 3
        case "スレッジハンマー": return 3
        case "セブンスヘブン": return 3
        case "ダーティーマザー": return 3
        case "ダイキリ": return 3
        case "チェリーブロッサム": return 3
        case "チャーチル": return 3
        case "テキーラマンハッタン": return 3
        case "デビル": return 3
        case "ドローレス": return 3
        case "トロイカ": return 3
        case "ニューヨーク": return 3
        case "ネグローニ": return 3
        case "ネバダ": return 3
        case "ハーバード": return 3
        case "バーバラ": return 3
        case "バーバリーコースト": return 3
        case "バーボネラ": return 3
        case "バカラ": return 3
        case "パディ": return 3
        case "パナマ": return 3
        case "ハニーサックル": return 3
        case "バラライカ": return 3
        case "ハリケーン": return 3
        case "パリジャン": return 3
        case "ハワイアン": return 3
        case "ハンター": return 3
        case "ビーズニーズ": return 3
        case "ピカドール": return 3
        case "ビトウィーンザシーツ": return 3
        case "ピンクジン": return 3
        case "プラチナブロンド": return 3
        case "ブラックホーク": return 3
        case "ブラックルシアン": return 3
        case "ブランデーサワー": return 3
        case "ブルートリップ": return 3
        case "ブルーマルガリータ": return 3
        case "ブルーマンデー": return 3
        case "ブルームーン": return 3
        case "フレンチカクタス": return 3
        case "フレンチコネクション": return 3
        case "ブロンクス": return 3
        case "ホールインワン": return 3
        case "ホノルル": return 3
        case "ポロネーズ": return 3
        case "ホワイトウェイ": return 3
        case "ホワイトスパイダー": return 3
        case "ホワイトルシアン": return 3
        case "ホワイトレディ": return 3
        case "マイアミ": return 3
        case "マイアミビーチ": return 3
        case "マイタイ": return 3
        case "マイトウキョウ": return 3
        case "マジックトレース": return 3
        case "マティーニ": return 3
        case "マリリンモンロー": return 3
        case "マルガリータ": return 3
        case "マンハッタン": return 3
        case "ミッドナイトカウボーイ": return 3
        case "ミントジュレップ": return 3
        case "ムーランルージュ": return 3
        case "メリーウィドウ": return 3
        case "ユニオンジャック": return 3
        case "ラスティネイル": return 3
        case "ラストキッス": return 3
        case "ラテンラバー": return 3
        case "ラムジュレップ": return 3
        case "リトルデビル": return 3
        case "リトルプリンセス": return 3
        case "ルシアン": return 3
        case "ルシアンネイル": return 3
        case "ロードランナー": return 3
        case "ロックローモンド": return 3
        case "ロブロイ": return 3
        case "雪国": return 3
        case "青い珊瑚礁": return 3
            
        default: return 4
        }
    }
    
    func isNewRecipe73() -> Bool {
        switch self{
        case "アーティスツスペシャル": return true
        case "アーント・アガサ": return true
        case "アイオープナー": return true
        case "アイリッシュコーヒー・デラックス": return true
        case "アイリッシュブラックソーン": return true
        case "アイリッシュルシアン": return true
        case "アップトゥデイト": return true
        case "アップルショコラ": return true
        case "アップルフレーズル": return true
        case "アフターディナー": return true
        case "アプリコットフィズ": return true
        case "アマレットカフェ": return true
        case "アラスカ": return true
        case "アルゴンキン": return true
        case "アンダルシア": return true
        case "アンバードリーム": return true
        case "イエローパロット": return true
        case "イグアナ": return true
        case "イスラ・デ・ピノス": return true
        case "イタリアンカイピリーニャ": return true
        case "インペリアルフィズ": return true
        case "ヴァージンピニャコラーダ": return true
        case "ヴァージンモヒート": return true
        case "ウィスキーサイドカー": return true
        case "ウィスキーリッキー": return true
        case "ウォッカアイスバーグ": return true
        case "ウォッカコリンズ": return true
        case "ウォッカトニック": return true
        case "オーロラ": return true
        case "カーネルコリンズ": return true
        case "カイピリーニャ": return true
        case "カシスウーロン": return true
        case "カシスグレープフルーツ": return true
        case "カシスコラーダ": return true
        case "カシスソーダ": return true
        case "カシスミルク": return true
        case "カフェロワイヤル": return true
        case "カプリ": return true
        case "カルーアウーロン": return true
        case "カルーアオレンジ": return true
        case "カルーアベリー": return true
        case "カンパリグレープフルーツ": return true
        case "カンパリトニック": return true
        case "ギネスカシス": return true
        case "キュラソークーラー": return true
        case "クエーカーズ": return true
        case "クォーターデック": return true
        case "クリームフィズ": return true
        case "グリーンアラスカ": return true
        case "クレオパトラ": return true
        case "クレッチマ": return true
        case "グレナデントニック": return true
        case "グレナデンフィズ": return true
        case "クレビヨン": return true
        case "クロンダイクハイボール": return true
        case "コーヒーエッグノッグ": return true
        case "コーヒーグラスホッパー": return true
        case "コープス・リバイバー": return true
        case "ゴールデンフィズ": return true
        case "ココナッツドリーム": return true
        case "コパ・デ・オロ": return true
        case "コモドアー": return true
        case "コロラドブルドッグ": return true
        case "コンカドロ": return true
        case "サウスオブザボーダー": return true
        case "サケサワー": return true
        case "サケティーニ": return true
        case "ザンシア": return true
        case "サンフランシスコ": return true
        case "シェリーフリップ": return true
        case "ジェントルブル": return true
        case "ジャーナリスト": return true
        case "シャムロック": return true
        case "シャルトリューズオレンジ": return true
        case "シャルトリューズトニック": return true
        case "シャンギロンゴ": return true
        case "ジャングル": return true
        case "ジョージアミントジュレップ": return true
        case "シルビア": return true
        case "ジンサワー": return true
        case "ジンジュレップ": return true
        case "ジンライム": return true
        case "スコッチキルト": return true
        case "スタンレー": return true
        case "スプリングフィーリング": return true
        case "スマイリング": return true
        case "ゼウス": return true
        case "セーフセックスオンザビーチ": return true
        case "セプテンバーモーン": return true
        case "センチュリー": return true
        case "ソノラ": return true
        case "ダービーフィズ": return true
        case "ダンロップ": return true
        case "チェリーラムフィズ": return true
        case "チャイニーズレディ": return true
        case "チョコカシスソーダ": return true
        case "チョコティーニ": return true
        case "チョコレートカイピリーニャ": return true
        case "チョコレートギムレット": return true
        case "チョコレートサワー": return true
        case "チョコレートスリング": return true
        case "チョコレートファッションド": return true
        case "チョコレートマルガリータ": return true
        case "チョコレートモヒート": return true
        case "ツァリーヌ": return true
        case "ディタエイジア": return true
        case "ディタクランベリールージュ": return true
        case "ディタグレープフルーツ": return true
        case "ティツィアーノ": return true
        case "ティファナサンライズ": return true
        case "ティフィンレモンソーダ": return true
        case "テキーニ": return true
        case "テキーラトニック": return true
        case "デプスボム": return true
        case "トロピカルファジーネーブル": return true
        case "ドンキホーテ": return true
        case "ナインティーンスホール": return true
        case "ニノチカ": return true
        case "ノックアウト": return true
        case "ハーバードクーラー": return true
        case "バイア": return true
        case "バイオレットフィズ": return true
        case "パイナップルクーラー": return true
        case "パイナップルフィズ": return true
        case "ハイランドクーラー": return true
        case "パッセンジャーリスト": return true
        case "パッソアバナナパイン": return true
        case "バノックバーン": return true
        case "バレエ・リュス": return true
        case "バロン": return true
        case "パンチョ・ビラ": return true
        case "バンブー": return true
        case "ピーチツリートニック": return true
        case "ピーチフィズ": return true
        case "ピエールコリンズ": return true
        case "ビューティフル": return true
        case "ピンクパイナップル": return true
        case "ブザム・カレッサー": return true
        case "プッシーキャット": return true
        case "ブラックアンドホワイト": return true
        case "ブラックベルベット": return true
        case "ブラッディサム": return true
        case "ブランデーエッグノッグ": return true
        case "ブランデーガンプ": return true
        case "ブランデーバック": return true
        case "ブランデーフリップ": return true
        case "ブルーカイピリーニャ": return true
        case "ブルータートル": return true
        case "フルーツパンチ": return true
        case "ブルーレディ": return true
        case "ブレイブブル": return true
        case "ヘアライザー": return true
        case "ペイトンプレイス": return true
        case "ベルベットキッス": return true
        case "ベルモットキュラソー": return true
        case "ベレッタ": return true
        case "ポーラーショートカット": return true
        case "ホットシャルトリューズ": return true
        case "ボヘミアンドリーム": return true
        case "ボルガ": return true
        case "ボルガボートマン": return true
        case "ホワイトリリー": return true
        case "マイラ": return true
        case "マウントフジ": return true
        case "マッドスライド": return true
        case "マネッティ": return true
        case "ミッドナイトサン": return true
        case "ミドリカイピリーニャ": return true
        case "ミドリマルガリータ": return true
        case "メキシカン・エル・ディアブロ": return true
        case "メキシカンコーヒー": return true
        case "メキシコローズ": return true
        case "モッキンバード": return true
        case "モンマルトル": return true
        case "ヤングマン": return true
        case "ラバーズドリーム": return true
        case "ラムクーラー": return true
        case "ラム・スウィズル": return true
        case "ラム・デュボネ": return true
        case "ラムトニック": return true
        case "ルシアンバレエ": return true
        case "ルビーカシス": return true
        case "ルビーフィズ": return true
        case "レイククイーン": return true
        case "レッドソンブレロ": return true
        case "レッドライオン": return true
        case "ロイヤルフィズ": return true
        case "ロイヤルルシアン": return true
        case "ローマホリデー": return true
        case "ロバートバーンズ": return true
        case "ロブソン": return true
        case "ワイオミング・スイング": return true
        case "ワイルドミュール": return true
        case "ワシントン": return true


        default: return false
        }
    }
    
    func isNewRecipe80() -> Bool {
        switch self{
        case "アイアンレディ": return true
        case "アカシア": return true
        case "アップルシャワー": return true
        case "アップルパイ": return true
        case "アビエーション": return true
        case "アフターサパー": return true
        case "アプリコットクーラー": return true
        case "アプリコットサワー": return true
        case "アペタイザー": return true
        case "アメリカンビューティ": return true
        case "アライズ": return true
        case "アレン": return true
        case "イーストインディアン": return true
        case "イエロージン": return true
        case "イエロー・ラットラー": return true
        case "イングリッシュブラックソーン": return true
        case "インディアンリバー": return true
        case "ウィスキーコブラー": return true
        case "ウィスキー・スウィズル": return true
        case "ウィスキースマッシュ": return true
        case "ウィスキーデイジー": return true
        case "ウェディングベル": return true
        case "ウォッカギブソン": return true
        case "ウォッカバック": return true
        case "ウォッカマティーニ": return true
        case "エクストラドライマティーニ": return true
        case "エッグサワー": return true
        case "エルクスオウン": return true
        case "エンジェルフェイス": return true

        case "キッスフロムヘブン": return true
        case "ギブソン": return true
        case "キャロル": return true
        case "キューバン": return true
        case "キューバンカクテル": return true
        case "キルシュカシス": return true
        case "クイーンズカクテル": return true
        case "クラリッジ": return true
        case "グリーンティーフィズ": return true
        case "グリーンドラゴン": return true
        case "グリーンルーム": return true
        case "ゲーリックコーヒー": return true
        case "ケル・ヴィー": return true
        case "ゴールデンキャデラック": return true
        case "ゴールデンドリーム": return true
        case "コールドデッキ": return true
        case "コロニアル": return true

        case "サーウォルター": return true
        case "サードレール": return true
        case "サケリーニャ": return true
        case "シェリーコブラー": return true
        case "ジプシー": return true
        case "ジャーマンコーヒー": return true
        case "シャンパンジュレップ": return true
        case "シャンパンピックミーアップ": return true
        case "シルバーフィズ": return true
        case "シルバーブレット": return true
        case "ジンアンドフレンチ": return true
        case "ジンコブラー": return true
        case "ジン・スウィズル": return true
        case "ジンスマッシュ": return true
        case "シンデレラハネムーン": return true
        case "ジンフィックス": return true
        case "スロージンフィズ": return true

        case "タワーリシチ": return true
        case "チャーリー・チャップリン": return true
        case "チョコレートソルジャー": return true
        case "デービス": return true
        case "テキーラバック": return true
        case "テキーラフィズ": return true
        case "テキーラリッキー": return true
        case "デビルズ": return true
        case "デュボネフィズ": return true
        case "ドービル": return true

        case "ナップフラッペ": return true
        
        case "パーフェクトマティーニ": return true
        case "ハーベイウォールバンガー": return true
        case "パイナップルミントクーラー": return true
        case "ハネムーン": return true
        case "ビーアンドビー": return true
        case "ビューティスポット": return true
        case "ブランデーコブラー": return true
        case "ブランデー・スウィズル": return true
        case "ブランデースカッファ": return true
        case "ブランデースマッシュ": return true
        case "ブランデーデイジー": return true
        case "ブランデーフィックス": return true
        case "ブランデーミルクパンチ": return true
        case "プリンストン": return true
        case "フローズンダイキリ": return true
        case "フローズンピーチマルガリータ": return true
        case "フローズンマルガリータ": return true
        case "フロープ": return true
        case "ブロンクスシルバー": return true
        case "ベネディクト": return true
        case "ポートフリップ": return true
        case "ホットバタード・ラム": return true
        case "ホットバタード・ラム・カウ": return true
        case "ホップ・トード": return true
        case "ホワイトサテン": return true

        case "マウンテン": return true
        case "マリアンヌ": return true
        case "ミドリアレキサンダー": return true
        case "ミントクーラー": return true
        case "メキシカンバナナ": return true
        case "モンタナ": return true
        case "モンクスコーヒー": return true
        case "モンテカルロ": return true
            
        case "ラムコブラー": return true
        case "ラムスマッシュ": return true
        case "ラムデイジー": return true
        case "ラムバック": return true
        case "ラムフリップ": return true
        case "ラムリッキー": return true
        case "ロングアイランド・ビーチ": return true

        default: return false
        }
    }
}
