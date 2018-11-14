//
//  SearchResultTableViewController.swift
//  English Words
//
//  Created by Elsayed Hussein on 1/4/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAnalytics

class SearchResultTableViewController: UITableViewController {
    
    //MARK: Variables
    var allWords = [Word]()
    var matchingWords = [Word]()
    
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
    //MARK: Actions
    
    //MARK: Methods
    func setupViews() {
        self.matchingWords = self.allWords
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.matchingWords.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchWordCell", for: indexPath)
        
        cell.textLabel?.text = matchingWords[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let word = matchingWords[indexPath.row]
        if (self.parent is UISearchController) {
            openWordDetailsController(word: word)
        }
    }
    
    func openWordDetailsController(word: Word) {
        let navigationController = self.parent?.presentingViewController?.navigationController
        let wordDetailsController = storyboard?.instantiateViewController(withIdentifier: "WordDetailsTableViewController") as! WordDetailsTableViewController
        let mainNavigatioController = Initializer.getMainNavigationController()
        for controller in mainNavigatioController.viewControllers {
            if controller is MainTableViewController {
                let mainViewController = controller as! MainTableViewController
                wordDetailsController.delegate = mainViewController
            }
        }
        wordDetailsController.word = word
        navigationController?.pushViewController(wordDetailsController, animated: true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    
}
extension SearchResultTableViewController:UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text!
        if !searchText.isEmpty{
            matchingWords = allWords.filter({
                $0.title.lowercased().contains(searchText.lowercased())
            })
        }
        else {
            matchingWords = allWords
        }
        self.tableView.reloadData()
    }
}
