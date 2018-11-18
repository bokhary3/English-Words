//
//  UpgradeVersionManager.swift
//  English Words
//
//  Created by Elsayed Hussein on 11/18/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
import FirebaseAnalytics

class UpgradeVersionManager {
    
    var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func alertUpgardeMessage(message: String) {
        let alert = UIAlertController(title: "Note", message: message, preferredStyle: .alert)
        let upgradeAction = UIAlertAction(title: "Upgrade", style: .default) { (_) in
            self.verifyPurchase()
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(upgradeAction)
        
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    func verifyPurchase() {
        Loader.show(view: viewController!.view)
        SwiftyStoreKit.retrieveProductsInfo([Constants.PurchaseData.productID]) { result in
            Loader.hide(view: self.viewController!.view)
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
                self.purchaseProduct(product: product)
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                Alert.alert(message: "Invalid product identifier: \(invalidProductId)")
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(String(describing: result.error))")
                if let error = result.error{
                    Alert.alert(message: error.localizedDescription)
                }
            }
        }
    }
    
    func purchaseProduct(product: SKProduct) {
        Loader.show(view: viewController!.view)
        SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
            Loader.hide(view: self.viewController!.view)
            switch result {
            case .success(let purchase):
                Analytics.logEvent("Purchase", parameters: ["action": "Buy Product \(product.price)"])
                self.relaunchApp(title: "", message: "Purchase Success: \(purchase.productId)")
                print("Purchase Success: \(purchase.productId)")
            case .error(let error):
                switch error.code {
                case .unknown: Alert.alert(message: "Unknown error. Please contact support")
                print("Unknown error. Please contact support")
                case .clientInvalid:Alert.alert(message: "Not allowed to make the payment")
                print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: Alert.alert(message: "The purchase identifier was invalid")
                print("The purchase identifier was invalid")
                case .paymentNotAllowed: Alert.alert(message: "The device is not allowed to make the payment")
                print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: Alert.alert(message: "The product is not available in the current storefront")
                print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: Alert.alert(message: "Access to cloud service information is not allowed")
                print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed:Alert.alert(message: "Could not connect to the network")
                print("Could not connect to the network")
                case .cloudServiceRevoked: Alert.alert(message: "User has revoked permission to use this cloud service")
                print("User has revoked permission to use this cloud service")
                }
            }
        }
    }
    
    func restorePurchase(){
        Loader.show(view: viewController!.view)
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            Loader.hide(view: self.viewController!.view)
            for purchase in results.restoredPurchases where purchase.needsFinishTransaction {
                // Deliver content from server, then:
                SwiftyStoreKit.finishTransaction(purchase.transaction)
            }
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                return Alert.alert(title: "Restore failed", message: "Unknown error. Please contact support", alertActionTitle: "Ok")
            } else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                Analytics.logEvent("Purchase", parameters: ["action": "Restore Product \(results.restoredPurchases.count)"])
                
                return self.relaunchApp(title: "Purchases Restored", message: "All purchases have been restored",productPurchased: false)
            } else {
                print("Nothing to Restore")
                return Alert.alert(title: "Nothing to restore", message: "No previous purchases were found", alertActionTitle: "Ok")
            }
        }
    }
    
    func relaunchApp(title: String, message: String, productPurchased: Bool = true) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {
            _ in
            UserStatus.productPurchased = productPurchased
            Constants.fromPurchaseProcess = true
            let homeVC = Initializer.createVCWith(identifier: Constants.StoryboardIds.homeNC)
            Initializer.getAppdelegate().window?.rootViewController = homeVC
            UIView.transition(with: Initializer.getAppdelegate().window!, duration: 0.2, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        })
        alert.addAction(okAction)
        
        viewController!.present(alert, animated: true, completion: nil)
    }
}
