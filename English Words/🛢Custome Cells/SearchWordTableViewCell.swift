//
//  SearchWordTableViewCell.swift
//  English Words
//
//  Created by Elsayed Hussein on 1/4/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import SafariServices
import CoreData
class SearchWordTableViewCell: UITableViewCell {
    //MARK: Variables
    static let identifier = "SearchWordCell"
    var searchResultTVC:SearchResultTableViewController!
    //MARK: Outlets
    @IBOutlet weak var oLblWordTitle: UILabel!
    @IBOutlet weak var oBtnDictionary: UIButton!
    @IBOutlet weak var oBtnInfo: UIButton!
    @IBOutlet weak var oBtnTranslate: UIButton!
    @IBOutlet weak var oBtnRemember: UIButton!
    @IBOutlet weak var oBtnYouGlish: UIButton!
    
    //MARK: Actions
    @IBAction func aBtnDictionary(_ sender: UIButton) {
        let indexPath = self.searchResultTVC.tableView.indexPath(for: sender)!
        let word = self.searchResultTVC.matchingWords[indexPath.row]
        self.openActionSheetSites(sender: sender, word: word.title)
    }
    @IBAction func aBtnInfo(_ sender: UIButton) {
        let indexPath = self.searchResultTVC.tableView.indexPath(for: sender)!
        let word = self.searchResultTVC.matchingWords[indexPath.row]

        let alert = UIAlertController(title: "\'\(word.title)\' info", message: "\'\(word.title)\' is (\(word.title.components(separatedBy: ",(")[1]), occures \(word.title.components(separatedBy: ",")[1]) ", preferredStyle: .alert)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.searchResultTVC.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func aBtnTranslate(_ sender: UIButton) {
        let indexPath = self.searchResultTVC.tableView.indexPath(for: sender)!
        let word = self.searchResultTVC.matchingWords[indexPath.row]

        let url = Constants.WebSites.googleTranslate + word.title
        self.openSafariVC(url: url)
    }
    @IBAction func aBtnRememper(_ sender: UIButton) {
        let indexPath = self.searchResultTVC.tableView.indexPath(for: sender)!
        let word = self.searchResultTVC.matchingWords[indexPath.row]
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "WordObject")
        
        fetchRequest.predicate = NSPredicate(format: "id = %@", word.title)
        
        var results: [NSManagedObject] = []
        
        do {
            results = try managedContext.fetch(fetchRequest)
            if results.count > 0 {
                let wordObj = results[0]
                var isRemeber = wordObj.value(forKey: "isRemember") as! Bool
                isRemeber = !isRemeber
                word.isRemebered = isRemeber
                wordObj.setValue(isRemeber, forKey: "isRemember")
                try managedContext.save()
                self.searchResultTVC.tableView.reloadData()
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
    }
    @IBAction func aBtnYouGlish(_ sender: UIButton) {
        let indexPath = self.searchResultTVC.tableView.indexPath(for: sender)!
        let word = self.searchResultTVC.matchingWords[indexPath.row]
        let url = Constants.WebSites.youGlish + word.title
            self.openSafariVC(url: url)
    }
    
    
    
    //MARK: Methods
    func setupViews() {
        
    }
    func configureCell(indexPath:IndexPath){
        let word =  self.searchResultTVC.matchingWords[indexPath.row]
        let wordObjs = self.searchResultTVC.remembredWords.filter { (wordObj) -> Bool in
            wordObj.value(forKey: "id") as! String == word.title
        }
        if wordObjs.count > 0 {
            word.isRemebered = wordObjs[0].value(forKey: "isRemember") as! Bool
        }
        self.oBtnRemember.setBackgroundImage(word.isRemebered ? #imageLiteral(resourceName: "check-box"):#imageLiteral(resourceName: "blank-check") , for: .normal)
        
        self.oLblWordTitle.text = word.title

        
    }
    
    func openActionSheetSites(sender:UIButton,word:String){
        let alert  = UIAlertController(title: "Translate \'\(word)\' by dictionary of ", message: "", preferredStyle: .actionSheet)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        let oxfordAction = UIAlertAction(title: "Oxford", style: .default) { (_) in
            let url = Constants.WebSites.oxfordLink + word
            self.openSafariVC(url: url)
        }
        let cambridgeAction = UIAlertAction(title: "Cambridge", style: .default) { (_) in
            let url = Constants.WebSites.cambridge + word
            self.openSafariVC(url: url)
        }
        let merriamWebsterAction = UIAlertAction(title: "Merriam Webster", style: .default) { (_) in
            let url = Constants.WebSites.merriam + word
            self.openSafariVC(url: url)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(oxfordAction)
        alert.addAction(cambridgeAction)
        alert.addAction(merriamWebsterAction)
        alert.addAction(cancelAction)
        self.searchResultTVC.present(alert, animated: true, completion: nil)
        
    }
    
    func openSafariVC(url:String){
        let safariVC = SFSafariViewController(url: URL(string:url)!)
        self.searchResultTVC.present(safariVC, animated: true, completion: nil)
    }
    

}
