//
//  UserStatus.swift
//  English Words
//
//  Created by Elsayed Hussein on 1/8/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation

class UserStatus {
    static let userDefault = UserDefaults.standard
    static var productPurchased: Bool {
        get{
            return userDefault.bool(forKey: Constants.UserData.productPurchasedKey)
        }
        set{
            userDefault.set(newValue, forKey: Constants.UserData.productPurchasedKey)
        }
    }
    
}
