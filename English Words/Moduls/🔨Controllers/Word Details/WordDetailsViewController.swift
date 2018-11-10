//
//  WordDetailsViewController.swift
//  English Words
//
//  Created by Elsayed Hussein on 11/4/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import CoreData

class WordDetailsTableViewController: UITableViewController {
    
    //MARK: Variables
    var word: Word!
    weak var delegate: WordsDelegate!
    
    //MARK: Outlets
    @IBOutlet weak var wordInfoLabel: UITableViewCell!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var rememberCell: UITableViewCell!
    
    
    //MARK: View lifcycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup views
        setupViews()
        
    }
    
    //MARK: Actions

    //MARK: Methods
    func setupViews() {
        wordLabel.text = word.title
        
        rememberCell.accessoryType = WordObjectManager.shared!.isRemeberWord(word: word) ? .checkmark : .none
        
        wordInfoLabel.textLabel?.text = "\'\(word.title)\' is (\(word.data.components(separatedBy: ",(")[1]), occures \(word.data.components(separatedBy: ",")[1]) times."
        
    }
    
    func openWebViewController(urlPath: String) {
        let url = URL(string: urlPath)
        performSegue(withIdentifier: "showWebViewController", sender: url)
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebViewController" {
            let webController = segue.destination as! WebViewController
            webController.url = sender as? URL
        }
    }
    
    
}

//MARK: UITableView delegate methods
extension WordDetailsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 3
        }
        return 1
    }
}

//MARK: UITableView datasource methods

extension WordDetailsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            handleDictionariesSection(row: indexPath.row)
        } else if indexPath.section == 2 {
            translateByGoogle()
        } else if indexPath.section == 3 {
            listenToTheWord()
        } else if indexPath.section == 4 {
            rememberTheWord()
            tableView.deselectRow(at: indexPath, animated: true)
            delegate.refresh()
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !UserStatus.productPurchased {
            if indexPath.section == 2 {
                if indexPath.row == 0 {
                    return 0
                }
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !UserStatus.productPurchased {
            if section == 2 {
                return 0.001
            }
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if !UserStatus.productPurchased {
            if section == 2 {
                return 0.001
            }
        }
        return super.tableView(tableView, heightForFooterInSection: section)
    }
    
    func handleDictionariesSection(row: Int) {
        var urlPath = Constants.WebSites.oxfordLink + word.title
        switch row {
        case 1:
            urlPath = Constants.WebSites.cambridge + word.title
        case 2:
            urlPath = Constants.WebSites.merriam + word.title
        default:
            break
        }
        openWebViewController(urlPath: urlPath)
    }
   
    func translateByGoogle() {
        let urlPath = Constants.WebSites.googleTranslate + word.title
       openWebViewController(urlPath: urlPath)
    }
    func listenToTheWord() {
        let urlPath = Constants.WebSites.youGlish + word.title
        openWebViewController(urlPath: urlPath)
    }
    
    func rememberTheWord() {
        WordObjectManager.shared?.remeberWord(word: word)
        rememberCell.accessoryType = word.isRemebered ? .checkmark : .none
    }
}
