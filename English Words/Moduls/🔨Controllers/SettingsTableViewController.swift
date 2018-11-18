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
import MessageUI
import FirebaseAnalytics

class SettingsTableViewController: UITableViewController {
    
    //MARK: Variables
    var upgradeVersionManager: UpgradeVersionManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        recordScreenView()
    }
    func recordScreenView() {
        // These strings must be <= 36 characters long in order for setScreenName:screenClass: to succeed.
        guard let screenName = title else {
            return
        }
        let screenClass = classForCoder.description()
        
        // [START set_current_screen]
        Analytics.setScreenName(screenName, screenClass: screenClass)
        // [END set_current_screen]
    }
    //MARK: Outlets
    @IBOutlet weak var oCellPurchaseProduct: UITableViewCell!
    @IBOutlet weak var oCellRestore: UITableViewCell!
    //MARK: Actions
    
    //MARK: Methods
    func setupViews() {
        upgradeVersionManager = UpgradeVersionManager(viewController: self)
    }
    
    func shareApp(){
        let textToShare = "Download the English Words app, it contains most important words in english language, it help you to increase your english vocabulary."
        
        if let myWebsite = NSURL(string: "http://itunes.apple.com/app/id1332815701") {
            let objectsToShare = [textToShare, myWebsite] as [AnyObject]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //Excluded Activities
            activityVC.excludedActivityTypes = [UIActivityType.airDrop,UIActivityType.addToReadingList]
            //
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    func sendFeedback() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["englishwords18@gmail.com"])
            mail.setSubject("My Feedback")
            present(mail, animated: true)
        } else {
            Helper.alert(title: "Oops!", message: "Please configure your Mail app to send your valuable feedback.", viewController: self)
        }
    }
    
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
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
                upgradeVersionManager.verifyPurchase()
            }
            else if indexPath.row == 1 { //restore
                upgradeVersionManager.restorePurchase()
            }
        } else if indexPath.section == 1 {
            shareApp()
        } else {
            sendFeedback()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if UserStatus.productPurchased {
                return "You can restore your purchase"
            }
            return "Upgrade version to get all features of app, remove ads, search about specific word, translate word by google translate, and also word reading feature."
        } else if section == 1 {
            return "Share English Words app"
        }
        return "Describe an issue or share your ideas"
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerTitle =  UserStatus.productPurchased ? "You can restore your purchase" : "Upgrade version to get all features of app, remove ads, search about specific word, translate word by google translate, and also word reading feature."
        guard let tableViewHeaderFooterView = view as? UITableViewHeaderFooterView
            else { return }
        tableViewHeaderFooterView.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        tableViewHeaderFooterView.textLabel?.textColor = .darkGray
        if section == 0 {
            tableViewHeaderFooterView.textLabel?.text = headerTitle
        } else if section == 1 {
            tableViewHeaderFooterView.textLabel?.text = "Share English Words app"
        } else {
            tableViewHeaderFooterView.textLabel?.text = "Describe an issue or share your ideas"
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
