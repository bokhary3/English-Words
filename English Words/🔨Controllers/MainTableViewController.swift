//
//  MainTableViewController.swift
//  English Words
//
//  Created by Elsayed Hussein on 12/20/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

class MainTableViewController: UITableViewController {
    
    //MARK: Variables
    var chars = [Char]()
    var remembredWords = [NSManagedObject]()
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var searchController = UISearchController(searchResultsController: nil)
    var cleanWords = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    //MARK: Outlets
    //MARK: Actions
    
    //MARK: Methods
    func setupViews() {
        
        
        // create banner view
        bannerView = GADBannerView(adSize: kGADAdSizeMediumRectangle)
        bannerView.adUnitID = Constants.Keys.adMobBannerUnitID
        bannerView.rootViewController = self
        bannerView.delegate = self
        self.tableView.tableHeaderView = bannerView
        self.bannerView.load(GADRequest())
        
        // create interstistial
        interstitial = self.createAndLoadInterstitial()
        
        
        // setup search bar
        setupSearchBar()
        
        
        // load words from file
        loadWordsFromExcelFile()
    }
    func loadWordsFromExcelFile(){
        var data = Helper.readDataFromCSV(fileName: Constants.englishFileName, fileType: "csv")
        data = Helper.cleanRows(file: data!)
        let csvRows = Helper.csv(data: data!)
        cleanWords = csvRows.flatMap { (wordss) -> String? in
            wordss.first
        }
        
        
        for word in cleanWords{
            if self.save(word: word) == 2 {
                break
            }
        }
        self.rememberedWordsCount()
        fetchWords(words: cleanWords)
    }
    func setupSearchBar(){
        let searchVC = Initializer.createVCWith(identifier: Constants.StoryboardIds.searchResultTVC) as! SearchResultTableViewController
        
        searchController = UISearchController(searchResultsController: searchVC)
        searchController.searchResultsUpdater = searchVC
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.delegate = self
      
        self.tableView.tableHeaderView = searchController.searchBar
        
    }
    
    
    func fetchWords(words:[String]){
        for _char  in "abcdefghijklmnopqrstuvwxyz".characters {
            let wordsByChar = words.filter({ (word) -> Bool in
                word.hasPrefix("\(_char)")
            }).map({ (fetchedWord) -> Word in
                Word(isRemebered: false, title: fetchedWord)
            })
            let char = Char(isExpanded: false, words: wordsByChar)
            self.chars.append(char)
        }
        self.tableView.reloadData()
    }
    func save(word: String)-> Int {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return 0
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        if !someEntityExists(id: word, managedContext: managedContext){
            // 2
            let entity =
                NSEntityDescription.entity(forEntityName: "WordObject",
                                           in: managedContext)!
            
            let wordObj = NSManagedObject(entity: entity,
                                          insertInto: managedContext)
            
            // 3
            wordObj.setValue(word, forKeyPath: "id")
            wordObj.setValue(false, forKey: "isRemember")
            // 4
            do {
                try managedContext.save()
                self.remembredWords.append(wordObj)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            return 1
        }
        else{
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WordObject")
            var results: [NSManagedObject] = []
            
            do {
                results = try managedContext.fetch(fetchRequest)
                self.remembredWords = results
                return 2
            }
            catch {
                print("error executing fetch request: \(error)")
            }
        }
        return 3
    }
    
    func someEntityExists(id: String,managedContext:NSManagedObjectContext) -> Bool {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WordObject")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        var results: [NSManagedObject] = []
        
        do {
            results = try managedContext.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return results.count > 0
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
        
        var results: [NSManagedObject] = []
        
        do {
            results = try managedContext.fetch(fetchRequest)
            self.navigationItem.title = "\(results.count)\\\(self.remembredWords.count)"
        }
        catch {
            print("error executing fetch request: \(error)")
        }
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.chars.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chars[section].isExpanded ? self.chars[section].words.count : 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WordTableViewCell.identifier, for: indexPath) as! WordTableViewCell
        cell.mainTVC = self
        
        // Configure the cell...
        cell.configureCell(indexPath: indexPath)
        
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: SectionTableViewCell.identifier) as! SectionTableViewCell
        let char = self.chars[section]
        cell.mainTVC = self
        cell.oBtnDropDown.tag = section
        cell.oBtnSelect.tag = section
        if char.isExpanded {
            cell.oBtnDropDown.rotate(char.isExpanded ? .pi/2 : .pi)
        }
        if char.words.count > 0 {
            cell.oLblSectionTitle.text = "\(char.words[0].title.capitalized.first!)"
        }
        else{
            cell.oLblSectionTitle.text = "X"
            
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
extension MainTableViewController:GADBannerViewDelegate{
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}

extension MainTableViewController:GADInterstitialDelegate{
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: Constants.Keys.adMobInterstitial)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
}
extension MainTableViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let searchResultVC = self.searchController.searchResultsController as! SearchResultTableViewController
        searchResultVC.allWords = self.cleanWords.map({ (title) in
            Word(isRemebered: false, title: title)
        })
        searchResultVC.remembredWords = self.remembredWords
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.rememberedWordsCount()
        self.tableView.reloadData()
    }
}
