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
import MOLH

class SettingsTableViewController: UITableViewController {
    
    //MARK: Variables
    var upgradeVersionManager: UpgradeVersionManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "refreshMemorizedWords"), object: nil, queue: nil) { [weak self](notification) in
            self?.memorizedWordsLabel.text = "\(NSLocalizedString("memorizedWords", comment: "")) (\(WordObjectManager.shared!.rememberedWordsCount()))"
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "refreshMemorizedWords"), object: nil)
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
        Analytics.logEvent(screenName, parameters: ["class": screenClass])
        // [END set_current_screen]
    }
    //MARK: Outlets
    @IBOutlet weak var oCellPurchaseProduct: UITableViewCell!
//    @IBOutlet weak var oCellRestore: UITableViewCell!
    @IBOutlet weak var memorizedWordsLabel: UILabel!
    //MARK: Actions
    
    //MARK: Methods
    func setupViews() {
        upgradeVersionManager = UpgradeVersionManager(viewController: self)
        
        memorizedWordsLabel.text = "\(NSLocalizedString("memorizedWords", comment: "")) (\(WordObjectManager.shared!.rememberedWordsCount()))"
    }
    
    func shareApp(){
        let textToShare = NSLocalizedString("shareAppText", comment: "")
        
        if let myWebsite = NSURL(string: Constants.productPath) {
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
            mail.setSubject(NSLocalizedString("myFeedback", comment: ""))
            present(mail, animated: true)
        } else {
            Helper.alert(title: NSLocalizedString("Oops", comment: ""), message: NSLocalizedString("mailWarning", comment: ""), viewController: self)
        }
    }
    
    // MARK: - Table view data source
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 3
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return 2
//        } else if section == 1 {
//            return 1
//        }
//        return 4
//    }
//    
    fileprivate func changeLanguage() {
        let alert = UIAlertController(title: NSLocalizedString("selectYourLanguage", comment: ""), message: "", preferredStyle: .alert)
        let englishAction = UIAlertAction(title: "English", style: .default) { (_) in
            
            if MOLHLanguage.isArabic() {
                MOLH.setLanguageTo("en")
                MOLH.reset()
            }
            
        }
        
        let arabicAction = UIAlertAction(title: "عربي", style: .default) { (_) in
            if !MOLHLanguage.isArabic() {
                MOLH.setLanguageTo("ar")
                MOLH.reset()
            }
        }
        
        alert.addAction(englishAction)
        alert.addAction(arabicAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { // for purchase
            if indexPath.row == 0 { // upgrade
                upgradeVersionManager.verifyPurchase()
            }
//            else if indexPath.row == 1 { //restore
//                upgradeVersionManager.restorePurchase()
//            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "showMemorizedWords", sender: nil)
            }
        } else {
            if indexPath.row == 0 {
                shareApp()
            } else if indexPath.row == 1 {
                guard let productURL = URL(string: Constants.productPath) else { return }
                
                var components = URLComponents(url: productURL, resolvingAgainstBaseURL: false)
                components?.queryItems = [
                    URLQueryItem(name: "action", value: "write-review")
                ]
                guard let writeReviewURL = components?.url else {
                    return
                }
                UIApplication.shared.open(writeReviewURL)
            } else if indexPath.row == 2 {
                sendFeedback()
            } else {
                changeLanguage()
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Tips"
        } else if section == 2 {
            return "English Words"
        }
        return ""
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerTitle =  "Tips"//UserStatus.productPurchased ? NSLocalizedString("restoreUpgradeMessage", comment: "") : NSLocalizedString("upgradeMessage", comment: "")
        
        guard let tableViewHeaderFooterView = view as? UITableViewHeaderFooterView
            else { return }
        tableViewHeaderFooterView.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        tableViewHeaderFooterView.textLabel?.textColor = .darkGray
        if section == 0 {
            tableViewHeaderFooterView.textLabel?.text = headerTitle
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
