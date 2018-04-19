//
//  RememberedWordsTableViewController.swift
//  English Words
//
//  Created by Elsayed Hussein on 1/11/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import CoreData
class RememberedWordsTableViewController: UITableViewController {
    
    //MARK: Variables
    var results: [NSManagedObject] = []
    var dataCome = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    //MARK: Outlets
    //MARK: Actions
    
    //MARK: Methods
    func setupViews() {
        self.navigationItem.title = "Remembered Words"
        self.tableView.tableFooterView = UIView(frame:CGRect.zero)
        DispatchQueue.main.async {
            self.rememberedWordsCount()
        }
    }
    func rememberedWordsCount(){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WordObject")
        fetchRequest.predicate = NSPredicate(format: "isRemember = %@", true as CVarArg)
        
        
        do {
            results = try managedContext.fetch(fetchRequest)
            self.dataCome = true
            self.tableView.reloadData()
        }
        catch {
            print("error executing fetch request: \(error)")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Helper.emptyTableView(tableView: tableView, dataCount: self.results.count, dataCome: self.dataCome, emptyTableViewMessage: "You didn't remember any word! :(", seperatorStyle: .singleLine)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Configure the cell...
        let wordObj = self.results[indexPath.row]
        let word = wordObj.value(forKey: "id") as? String ?? ""
        let components = word.components(separatedBy: ",")
        if components.count > 0 {
            cell.textLabel?.text = components[0]
        }
        else{
            cell.textLabel?.text = ""
        }
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
