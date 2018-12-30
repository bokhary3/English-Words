//
//  UserStatus.swift
//  English Words
//
//  Created by Elsayed Hussein on 1/8/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import KeychainAccess

class UserStatus {
    static let userDefault = UserDefaults.standard
    static var depricatedProductPurchased: Bool {
        get{
            return userDefault.bool(forKey: Constants.UserData.productPurchasedKey)
        }
        set{
            userDefault.set(newValue, forKey: Constants.UserData.productPurchasedKey)
        }
    }
    
    static var productPurchased: Bool {
        let keychain = Keychain(service: Constants.PurchaseData.productID)
        // if there is value correspond to the productIdentifier key in the keychain
        let value = try? keychain.get(Constants.UserData.productPurchasedKey) ?? ""
        if value == "purchased" {
            return true
        }
        return false
    }
    
}
