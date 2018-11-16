//
//  StoreReviewHelper.swift
//  Template1
//
//  Created by Apple on 14/11/17.
//  Copyright © 2017 Mobiotics. All rights reserved.
//
import Foundation
import StoreKit
import FirebaseAnalytics

struct StoreReviewHelper {
    static let Defaults = UserDefaults.standard
    static func incrementAppOpenedCount() { // called from appdelegate didfinishLaunchingWithOptions:
        guard var appOpenCount = Defaults.value(forKey: Constants.UserDefaultsKeys.APP_OPENED_COUNT) as? Int else {
            Defaults.set(1, forKey: Constants.UserDefaultsKeys.APP_OPENED_COUNT)
            return
        }
        appOpenCount += 1
        Defaults.set(appOpenCount, forKey: Constants.UserDefaultsKeys.APP_OPENED_COUNT)
    }
    static func checkAndAskForReview() { // call this whenever appropriate
        // this will not be shown everytime. Apple has some internal logic on how to show this.
        guard let appOpenCount = Defaults.value(forKey: Constants.UserDefaultsKeys.APP_OPENED_COUNT) as? Int else {
            Defaults.set(1, forKey: Constants.UserDefaultsKeys.APP_OPENED_COUNT)
            return
        }
        
        switch appOpenCount {
        case 10,50:
            StoreReviewHelper().requestReview()
            Analytics.logEvent("rate_app", parameters: ["rate_in_launch_number" : appOpenCount])
        case _ where appOpenCount%100 == 0 :
            StoreReviewHelper().requestReview()
        default:
            print("App run count is : \(appOpenCount)")
            break;
        }
        
    }
    fileprivate func requestReview() {
        SKStoreReviewController.requestReview()
    }
}
