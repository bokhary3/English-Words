//
//  SearchResultTableViewController.swift
//  English Words
//
//  Created by Elsayed Hussein on 1/4/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import CoreData
class SearchResultTableViewController: UITableViewController {
    
    //MARK: Variables
    var allWords = [Word]()
    var matchingWords = [Word]()
    var remembredWords = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchWordTableViewCell.identifier, for: indexPath)    as! SearchWordTableViewCell
        
        // Configure the cell...
        cell.searchResultTVC = self
        cell.configureCell(indexPath: indexPath)
        return cell
    }
    
    
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
