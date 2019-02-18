//
//  RememberedWordsTableViewController.swift
//  English Words
//
//  Created by Elsayed Hussein on 1/11/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAnalytics

class RememberedWordsTableViewController: UITableViewController {
    
    //MARK: Variables
    var results: [NSManagedObject] = []
    var dataCome = false
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
        self.navigationItem.title = "Memorized Words"
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
        fetchRequest.predicate = NSPredicate(format: "isRemember = %d", true)
        
        
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
            cell.textLabel?.text = components[0].capitalized
        }
        else{
            cell.textLabel?.text = ""
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = results[indexPath.row]
        let wordData = data.value(forKey: "id") as? String ?? ""
        let word = Word(isRemebered: true, data: wordData)
        performSegue(withIdentifier: "showWordDetails", sender: word)
    }
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWordDetails" {
            let wordDetailsController = segue.destination as! WordDetailsTableViewController
            wordDetailsController.word = sender as? Word
        }
    }
    
}
