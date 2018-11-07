//
//  WordDetailsViewController.swift
//  English Words
//
//  Created by Elsayed Hussein on 11/4/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import SafariServices
import CoreData

class WordDetailsTableViewController: UITableViewController {
    
    //MARK: Variables
    var word: Word!
    
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
        
        rememberCell.accessoryType = word.isRemebered ? .checkmark : .none
        
        wordInfoLabel.textLabel?.text = "\'\(word.title)\' is (\(word.data.components(separatedBy: ",(")[1]), occures \(word.data.components(separatedBy: ",")[1]) times."
        
    }
    
    func openSafariViewController(urlPath: String) {
        if let url = URL(string: urlPath) {
        let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
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
        }
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
        openSafariViewController(urlPath: urlPath)
    }
   
    func translateByGoogle() {
        let urlPath = Constants.WebSites.googleTranslate + word.title
       openSafariViewController(urlPath: urlPath)
    }
    func listenToTheWord() {
        let urlPath = Constants.WebSites.youGlish + word.title
        openSafariViewController(urlPath: urlPath)
    }
    
    func rememberTheWord() {
        WordObjectManager.shared?.remeberWord(word: word)
        rememberCell.accessoryType = word.isRemebered ? .checkmark : .none
    }
}
