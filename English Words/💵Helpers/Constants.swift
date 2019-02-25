//
//  Constants.swift
//  English Words
//
//  Created by Elsayed Hussein on 12/20/17.
//  Copyright © 2017 mac. All rights reserved.
//

import Foundation

struct Constants {
    static let englishFileName = "English_Words"//"Words_English"
    static let productPath = "http://itunes.apple.com/app/id1332815701"
    struct StoryboardIds {
        static let mainSB = "Main"
        static let searchResultTVC = "SearchResultTVC"
        static let homeNC = "HomeNC"
    }
    
    struct WebSites {
        static let oxfordLink = "https://en.oxforddictionaries.com/definition/"
        static let cambridge = "https://dictionary.cambridge.org/dictionary/english-arabic/"
        static let merriam = "https://www.merriam-webster.com/dictionary/"
        static let googleTranslate = "https://translate.google.com/#en/ar/"
        static let youGlish = "https://youglish.com/search/"
    }
    
    struct Keys {
        static let adMobAPIKey = "ca-app-pub-1448110355544135~7666189534"
        static let adMobBannerUnitID = "ca-app-pub-1448110355544135/3744036640"
        static let adMobInterstitial = "ca-app-pub-1448110355544135/6755344804"
    }
    
    struct UserData {
        static let productPurchasedKey = "PRODUCTPURCHASED"
    }
    
    struct PurchaseData {
        static let productID = "bokhary.All.English.Words.RemoveAds"
    }
    
    static var fromPurchaseProcess = false
    
    struct UserDefaultsKeys {
        static let APP_OPENED_COUNT = "APP_OPENED_COUNT"
    }
}
