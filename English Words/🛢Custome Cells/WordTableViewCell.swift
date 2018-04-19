//
//  WordTableViewCell.swift
//  English Words
//
//  Created by Elsayed Hussein on 12/20/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import SafariServices
import CoreData
import EasyTipView
class WordTableViewCell: UITableViewCell {
    
    //MARK: Variables
    static let identifier = "WordCell"
    var mainTVC:MainTableViewController!
    //MARK: Outlets
    @IBOutlet weak var oLblWordTitle: UILabel!
    @IBOutlet weak var oBtnRemember: UIButton!
    @IBOutlet weak var oBtnDictionary: UIButton!
    @IBOutlet weak var oBtnInfo: UIButton!
    @IBOutlet weak var oBtnTranslate: UIButton!
    @IBOutlet weak var oBtnYouGlish: UIButton!
    
    //MARK: Actions
    @IBAction func aBtnRememper(_ sender: UIButton) {
        let indexPath = self.mainTVC.tableView.indexPath(for: sender)!
        let word = self.mainTVC.chars[indexPath.section].words[indexPath.row]
        let cell = self.mainTVC.tableView.cellForRow(at: indexPath)
        if !UserStatus.rememberTipShowed {
            UserStatus.rememberTipShowed = true
            self.showRemeberTipe(sender: sender, cell: cell!,message: "Remember it?")
        }
        else{
            self.remeberWord(word: word)
        }
    }
    @IBAction func aBtnDictionary(_ sender: UIButton) {
        let indexPath = self.mainTVC.tableView.indexPath(for: sender)!
        let word = self.mainTVC.chars[indexPath.section].words[indexPath.row]
        self.openActionSheetSites(sender: sender, word: word.title.components(separatedBy: ",").first!)
    }
    @IBAction func aBtnInfo(_ sender: UIButton) {
        let indexPath = self.mainTVC.tableView.indexPath(for: sender)!
        let word = self.mainTVC.chars[indexPath.section].words[indexPath.row]
        
        let alert = UIAlertController(title: "\'\(word.title.components(separatedBy: ",").first!)\' info", message: "\'\(word.title.components(separatedBy: ",").first!)\' is (\(word.title.components(separatedBy: ",(")[1]), occures \(word.title.components(separatedBy: ",")[1]) times.", preferredStyle: .alert)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.mainTVC.present(alert, animated: true, completion: nil)
    }
    @IBAction func aBtnTranslate(_ sender: UIButton) {
        let indexPath = self.mainTVC.tableView.indexPath(for: sender)!
        let word = self.mainTVC.chars[indexPath.section].words[indexPath.row]
        
        let url = Constants.WebSites.googleTranslate + word.title.components(separatedBy: ",").first!
        self.openSafariVC(url: url)
    }
    @IBAction func aBtnYouGlish(_ sender: UIButton) {
        let indexPath = self.mainTVC.tableView.indexPath(for: sender)!
        let word = self.mainTVC.chars[indexPath.section].words[indexPath.row]
        let cell = self.mainTVC.tableView.cellForRow(at: indexPath)
        if !UserStatus.youGlishTipShowed {
            UserStatus.youGlishTipShowed = true
            self.showRemeberTipe(sender: sender, cell: cell!,message: "Listen to this word?")
        }
        else{
            let url = Constants.WebSites.youGlish + word.title.components(separatedBy: ",").first!
            self.openSafariVC(url: url)
        }
    }
    //MARK: Methods
    func setupViews() {

    }
    func remeberWord(word:Word){
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
                self.mainTVC.rememberedWordsCount()
                self.mainTVC.tableView.reloadData()
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
    }
    func showRemeberTipe(sender:UIButton,cell:UITableViewCell,message: String){
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont(name: "Futura-Medium", size: 15)!
        preferences.drawing.foregroundColor = .white
        preferences.drawing.backgroundColor = Helper.colorOf(hex: "007AFF")
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
        
        /*
         * Optionally you can make these preferences global for all future EasyTipViews
         */
        EasyTipView.globalPreferences = preferences
        EasyTipView.show(forView: sender,
                         withinSuperview: cell.contentView,
                         text: message,
                         preferences: preferences,
                         delegate: self.mainTVC)
    }
    func configureCell(indexPath:IndexPath){
        let word =  self.mainTVC.chars[indexPath.section].words[indexPath.row]
        let wordObjs = self.mainTVC.remembredWords.filter { (wordObj) -> Bool in
            wordObj.value(forKey: "id") as! String == word.title
        }
        if wordObjs.count > 0 {
            word.isRemebered = wordObjs[0].value(forKey: "isRemember") as! Bool
        }
        self.oBtnRemember.setBackgroundImage(word.isRemebered ? #imageLiteral(resourceName: "check-box"):#imageLiteral(resourceName: "blank-check") , for: .normal)
        
        let wordComponent = word.title.components(separatedBy: ",")
        if wordComponent.count > 0 {
            self.oLblWordTitle.text = wordComponent.first
        }
        else{
            self.oLblWordTitle.text =  word.title
        }
        self.oBtnTranslate.isHidden = !UserStatus.productPurchased
        
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
        self.mainTVC.present(alert, animated: true, completion: nil)
        
    }
    
    func openSafariVC(url:String){
        let safariVC = SFSafariViewController(url: URL(string:url)!)
        self.mainTVC.present(safariVC, animated: true, completion: nil)
    }
    
}

extension MainTableViewController:EasyTipViewDelegate{
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        tipView.dismiss()
    }
    
    
}
