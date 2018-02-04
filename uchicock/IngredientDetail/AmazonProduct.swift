//
//  AmazonProduct.swift
//  uchicock
//
//  Created by Kou Kinyo on 2018/01/08.
//  Copyright © 2018年 Kou. All rights reserved.
//

import Foundation

struct Amazon{
    static let product = [
        "アップルジュース",
        "アップル・ジュース",
        "アマレット",
        "アーモンドリキュール",
        "アーモンド・リキュール",
        "ウイスキー",
        "ウィスキー",
        "ウォッカ",
        "オレンジキュラソー",
        "オレンジ・キュラソー",
        "オレンジジュース",
        "オレンジ・ジュース",
        "カルーア",
        "カルーアコーヒー",
        "カルーア・コーヒー",
        "カルーアコーヒーリキュール",
        "カルーア・コーヒー・リキュール",
        "コーヒーリキュール",
        "コーヒー・リキュール",
        "カンパリ",
        "クリーム・ド・カカオ",
        "クリームドカカオ",
        "クリーム・ド・カカオ・ブラウン",
        "クリーム・ド・カカオブラウン",
        "クリームドカカオブラウン",
        "クレーム・ド・カカオ・ホワイト",
        "クレーム・ド・カカオホワイト",
        "クレームドカカオホワイト",
        "カカオリキュール",
        "カカオ・リキュール",
        "クレーム・ド・カシス",
        "クレームドカシス",
        "カシスリキュール",
        "カシス・リキュール",
        "グレープジュース",
        "グレープ・ジュース",
        "グレープフルーツジュース",
        "グレープフルーツ・ジュース",
        "グレナデンシロップ",
        "グレナデン・シロップ",
        "クローブ",
        "コーラ",
        "コカコーラ",
        "コカ・コーラ",
        "シュガーシロップ",
        "シュガー・シロップ",
        "ジンジャエール",
        "ジンジャーエール",
        "ソーダ",
        "炭酸水",
        "たんさん",
        "たんさんすい",
        "タンサン",
        "タンサンスイ",
        "ディタ",
        "ディタライチ",
        "ディタ・ライチ",
        "パライソ",
        "パライソライチ",
        "パライソ・ライチ",
        "ライチリキュール",
        "ライチ・リキュール",
        "テキーラ",
        "トニック",
        "トニックウォーター",
        "トニック・ウォーター",
        "トマトジュース",
        "トマト・ジュース",
        "ジン",
        "ドライジン",
        "ドライ・ジン",
        "ベルモット",
        "ドライベルモット",
        "ドライ・ベルモット",
        "スイートベルモット",
        "スイート・ベルモット",
        "チンザノ",
        "ナツメグ",
        "パイナップルジュース",
        "パイナップル・ジュース",
        "ピーチツリー",
        "ピーチ・ツリー",
        "ピーチリキュール",
        "ピーチ・リキュール",
        "ビール",
        "ブランデー",
        "ブルーキュラソー",
        "ブルー・キュラソー",
        "ベイリーズ",
        "ベイリーズアイリッシュクリーム",
        "ベイリーズ・アイリッシュクリーム",
        "ホワイトキュラソー",
        "ホワイト・キュラソー",
        "コアントロー",
        "ラム",
        "ホワイトラム",
        "ホワイト・ラム",
        "ライトラム",
        "ライト・ラム",
        "ゴールドラム",
        "ゴールド・ラム",
        "ダークラム",
        "ダーク・ラム",
        "マンゴヤン",
        "マンゴーリキュール",
        "マンゴー・リキュール",
        "ミドリ",
        "ミドリリキュール",
        "ミドリ・リキュール",
        "メロンリキュール",
        "メロン・リキュール",
        "ミネラルウォーター",
        "ミネラル・ウォーター",
        "ライムジュース",
        "ライム・ジュース",
        "レモンジュース",
        "レモン・ジュース",
        "烏龍茶",
        "ウーロン茶",
        "日本酒",
        "牛乳",
        "赤ワイン",
        "白ワイン",
        "ワイン",
        "生クリーム",
        "しお",
        "塩",
        "食塩",
        "角砂糖",
        "砂糖",
        "さとう",
        "はちみつ",
        "ハチミツ",
        "蜂蜜",
        "クレーム・ド・アプリコット",
        "クレームドアプリコット",
        "アプリコットリキュール",
        "アプリコット・リキュール",
        "マリブ",
        "ココナッツリキュール",
        "ココナッツ・リキュール",
        "ミントチェリー",
        "ミント・チェリー",
        "チェリー",
        "クランベリージュース",
        "クランベリー・ジュース",
        "クレーム・ド・フランボワーズ",
        "クレームドフランボワーズ",
        "フランボワーズリキュール",
        "フランボワーズ・リキュール",
        "ラズベリーリキュール",
        "ラズベリー・リキュール",
        "ココナッツミルク",
        "ココナッツ・ミルク",
        "ティフィン",
        "ティフィン・ティー・リキュール",
        "ティフィンティーリキュール",
        "パッソア",
        "アイスコーヒー",
        "アイス・コーヒー",
        "バーボンウィスキー",
        "バーボン・ウィスキー",
        "バーボンウイスキー",
        "バーボン・ウイスキー",
        "アイリッシュウィスキー",
        "アイリッシュ・ウィスキー",
        "アイリッシュウイスキー",
        "アイリッシュ・ウイスキー",
        "アンゴスチュラビターズ",
        "アンゴスチュラ・ビターズ",
        "アンゴスチュラアロマティックビターズ",
        "アンゴスチュラ・アロマティック・ビターズ",
        "シャンパン",
        "スパークリングワイン",
        "スパークリング・ワイン",
        "ピーチネクター",
        "ピーチ・ネクター",
        "ホワイトペパーミント",
        "ホワイト・ペパーミント",
        "ペパーミントホワイト",
        "ペパーミント・ホワイト",
        "赤唐辛子",
        "チェリーブランデー",
        "チェリー・ブランデー",
        "紹興酒",
        "卵白",
        "レモンピール",
        "レモン・ピール",
        "サンブーカ",
        "ドランブイ",
        "アブサン",
        "アブサント",
        "マラスキーノ",
        "スコッチウィスキー",
        "スコッチ・ウィスキー",
        "スコッチウイスキー",
        "スコッチ・ウイスキー",
        "グリーンティーリキュール",
        "グリーンティー・リキュール",
        "デュボネ",
        "デュボネルージュ",
        "デュボネ・ルージュ",
        "クレームドバナナ",
        "クレーム・ド・バナナ",
        "バナナリキュール",
        "バナナ・リキュール",
        "ライウィスキー",
        "ライ・ウィスキー",
        "ライウイスキー",
        "ライ・ウイスキー",
        "シナモンスティック",
        "シナモン・スティック",
        "カナディアンウィスキー",
        "カナディアン・ウィスキー",
        "カナディアンウイスキー",
        "カナディアン・ウイスキー",
        "アメリカンウィスキー",
        "アメリカン・ウィスキー",
        "アメリカンウイスキー",
        "アメリカン・ウイスキー",
        "テネシーウィスキー",
        "テネシー・ウィスキー",
        "テネシーウイスキー",
        "テネシー・ウイスキー",
        "ジャパニーズウィスキー",
        "ジャパニーズ・ウィスキー",
        "ジャパニーズウイスキー",
        "ジャパニーズ・ウイスキー",
        "アプリコットブランデー",
        "アプリコット・ブランデー",
        "オレンジビターズ",
        "オレンジ・ビターズ",
        "スロージン",
        "スロー・ジン",
        "ドライシェリー",
        "ドライ・シェリー",
    ]
}
