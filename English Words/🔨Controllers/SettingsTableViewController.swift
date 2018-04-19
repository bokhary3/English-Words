//
//  SettingsTableViewController.swift
//  English Words
//
//  Created by Elsayed Hussein on 1/10/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
class SettingsTableViewController: UITableViewController {
    
    //MARK: Variables
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    //MARK: Outlets
    @IBOutlet weak var oCellPurchaseProduct: UITableViewCell!
    @IBOutlet weak var oCellRestore: UITableViewCell!
    //MARK: Actions
    
    //MARK: Methods
    func setupViews() {
        
        //        if UserStatus.productPurchased{
        //            oCellPurchaseProduct.isUserInteractionEnabled = false
        //        }
        //        else{
        //            oCellRestore.isUserInteractionEnabled = false
        //        }
    }
    func restorePurchase(){
        Loader.show(view: self.view)
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            Loader.hide(view: self.view)
            for purchase in results.restoredPurchases where purchase.needsFinishTransaction {
                // Deliver content from server, then:
                SwiftyStoreKit.finishTransaction(purchase.transaction)
            }
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                return Alert.alert(title: "Restore failed", message: "Unknown error. Please contact support", alertActionTitle: "Ok")
            } else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                return self.relaunchApp(title: "Purchases Restored", message: "All purchases have been restored",productPurchased: false)
            } else {
                print("Nothing to Restore")
                return Alert.alert(title: "Nothing to restore", message: "No previous purchases were found", alertActionTitle: "Ok")
            }
        }
    }
    func verifyPurchase(){
        Loader.show(view: self.view)
        SwiftyStoreKit.retrieveProductsInfo([Constants.PurchaseData.productID]) { result in
            Loader.hide(view: self.view)
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
    func shareApp(){
        let textToShare = "Download the English Words app, it containt most important word in english language, it help you to increase your english vocabulary."
        
        if let myWebsite = NSURL(string: "http://itunes.apple.com/app/id1332815701") {
            let objectsToShare = [textToShare, myWebsite] as [AnyObject]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //Excluded Activities
            activityVC.excludedActivityTypes = [UIActivityType.airDrop,UIActivityType.addToReadingList]
            //
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    func purchaseProduct(product:SKProduct){
        Loader.show(view: self.view)
        SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
            Loader.hide(view: self.view)
            switch result {
            case .success(let purchase):
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
    func relaunchApp(title:String,message:String,productPurchased:Bool = true){
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
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { // for purchase
            if indexPath.row == 0 { // upgrade
                self.verifyPurchase()
            }
            else if indexPath.row == 1 { //restore
                self.restorePurchase()
            }
        } else {
            shareApp()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if UserStatus.productPurchased {
                return "You can restore your purchase"
            }
            return "Upgarde version to get all featurs of app, remove ads, search about specific word and translate word by google translate."
        }
        return "Share English Words app"
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerTitle =  UserStatus.productPurchased ? "You can restore your purchase" : "Upgarde version to get all featurs of app, remove ads, get all words, search about specific word and translate word by google translate."
        guard let tableViewHeaderFooterView = view as? UITableViewHeaderFooterView
            else { return }
        if section == 0 {
            tableViewHeaderFooterView.textLabel?.text = headerTitle
        }
        else{
            tableViewHeaderFooterView.textLabel?.text = "Share English Words app"
        }
    }
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }    
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
