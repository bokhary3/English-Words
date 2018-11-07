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
    
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    //MARK: Outlets
    @IBOutlet weak var oViewNavigationTitle: UIView!
    @IBOutlet weak var oLblNavigationTitle: UILabel!
    @IBOutlet weak var oActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var viewModel: MainViewModel!
    
    //MARK: Actions
    
    //MARK: Methods
    func setupViews() {
        tableView.register(UINib(nibName: "SectionView", bundle: nil), forHeaderFooterViewReuseIdentifier: "header")
        
        viewModel.delegate = self
        // build header table view
        setTableViewHeader()
        
        // load words from file
        self.viewModel.loadWordsFromExcelFile()
    }
    func setTableViewHeader() {
        // create banner view
        if !UserStatus.productPurchased {
            let bannerSize = UIDevice.current.userInterfaceIdiom == .phone ? kGADAdSizeBanner : kGADAdSizeLeaderboard
            bannerView = GADBannerView(adSize: bannerSize)
            bannerView.adUnitID = Constants.Keys.adMobBannerUnitID
            bannerView.rootViewController = self
            bannerView.delegate = self
            self.tableView.tableHeaderView = bannerView
            self.bannerView.load(GADRequest())
            
            // create interstistial
            interstitial = self.createAndLoadInterstitial()
        }
        else{
            // setup search bar
            setupSearchBar()
        }
    }
    
    func setupSearchBar(){
        let searchVC = Initializer.createVCWith(identifier: Constants.StoryboardIds.searchResultTVC) as! SearchResultTableViewController
        
        searchController = UISearchController(searchResultsController: searchVC)
        searchController.searchResultsUpdater = searchVC
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
    }
    
    func refershUI() {
        setNavigationTitle()
        tableView.reloadData()
    }
    func setNavigationTitle() {
        oLblNavigationTitle.text = "\(WordObjectManager.shared!.rememberedWordsCount())\\\(WordObjectManager.shared!.allWordsAcount())"
        
        oViewNavigationTitle.isHidden = false
        oActivityIndicator.stopAnimating()
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let count = viewModel.numberOfSections()
        return Helper.emptyTableView(tableView: tableView, dataCount: count, dataCome: viewModel.dataCome, emptyTableViewMessage: "There is no words", seperatorStyle: .singleLine)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsFor(section: section)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        
        // Configure the cell...
        let word = viewModel.wordOf(indexPath: indexPath)
        
        cell.textLabel?.text =  word.title
        
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let word = viewModel.wordOf(indexPath: indexPath)
        if word.isExpanded {
            return 90
        }
        return 70
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! SectionTableViewCell
        let char = viewModel.charOfSection(section: section)
        headerView.delegate = self
        headerView.sectionNumber = section
        
        if char.isExpanded {
            headerView.oBtnDropDown.rotate(char.isExpanded ? .pi/2 : .pi)
        }
        if char.words.count > 0 {
            headerView.oLblSectionTitle.text = "\(char.words[0].title.capitalized.first!)"
        }
        else{
            headerView.oLblSectionTitle.text = "X"
            
        }
        return headerView
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let word = viewModel.wordOf(indexPath: indexPath)
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
extension MainTableViewController: GADBannerViewDelegate {
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

extension MainTableViewController {
    @IBAction func aBtnRememper(_ sender: UIButton) {
        let cellInfo =  cellInformation(sender: sender)
        if !UserStatus.rememberTipShowed {
            UserStatus.rememberTipShowed = true
            Helper.showRemeberTipe(sender: sender, cell: cellInfo.1, message: "Remember it?")
        } else {
            WordObjectManager.shared?.remeberWord(word: cellInfo.0)
            refershUI()
        }
    }
    @IBAction func aBtnDictionary(_ sender: UIButton) {
        let cellInfo =  cellInformation(sender: sender)
        
        Helper.openActionSheetSites(sender: sender, word: cellInfo.0.title, viewController: self)
    }
    @IBAction func aBtnInfo(_ sender: UIButton) {
        let cellInfo =  cellInformation(sender: sender)
        
        
        let title = "\'\(cellInfo.0.title)\' info"
        let message = "\'\(cellInfo.0.title)\' is (\(cellInfo.0.title.components(separatedBy: ",(")[1]), occures \(cellInfo.0.title.components(separatedBy: ",")[1]) times."
        
        Helper.alert(title: title, message: message, sender: sender, viewController: self)
    }
    @IBAction func aBtnTranslate(_ sender: UIButton) {
        let cellInfo =  cellInformation(sender: sender)
        
        let url = Constants.WebSites.googleTranslate + cellInfo.0.title
        Helper.openSafariVC(url: url, viewController: self)
    }
    @IBAction func aBtnYouGlish(_ sender: UIButton) {
        let cellInfo =  cellInformation(sender: sender)
        
        if !UserStatus.youGlishTipShowed {
            UserStatus.youGlishTipShowed = true
            Helper.showRemeberTipe(sender: sender, cell: cellInfo.1, message: "Listen to this word?")
        }
        else{
            let url = Constants.WebSites.youGlish + cellInfo.0.title
            Helper.openSafariVC(url: url, viewController: self)
        }
    }
    @IBAction func aBtnDropDown(_ sender: UIButton) {
        if !UserStatus.productPurchased {
            showAdsBanner()
        }
        viewModel.adsClicksCount += 1
        
        let char  = viewModel.charOfSection(section: sender.tag)
        if char.words.count > 0 {
            openSectionOf(char: char, section: sender.tag)
        }
    }
    
    func openSectionOf(char: Char, section: Int) {
        char.isExpanded = !char.isExpanded
        let viewHeader = tableView.headerView(forSection: section) as! SectionTableViewCell
        if char.isExpanded {
            viewHeader.oBtnDropDown.rotate(char.isExpanded ? .pi/2 : .pi)
            self.tableView.reloadSections(
                [section], with: UITableViewRowAnimation.none)
        } else {
            viewHeader.oBtnDropDown.rotate(0)
            self.tableView.reloadSections(
                [section], with: UITableViewRowAnimation.none)
        }
    }
    
    func showAdsBanner() {
        if viewModel.adsClicksCount % 8 == 0 {
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
        }
    }
    
    func cellInformation(sender: UIButton) -> (Word,UITableViewCell){
        let indexPath = tableView.indexPath(for: sender)!
        let word = viewModel.wordOf(indexPath: indexPath)
        let cell = tableView.cellForRow(at: indexPath)
        return (word,cell!)
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
        searchResultVC.allWords = viewModel.cleanWords.map({ (title) in
            Word(isRemebered: false, data: title)
        })
        searchResultVC.remembredWords = viewModel.remembredWords
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        refershUI()
    }
}

extension MainTableViewController: ViewModelDelegate {
    func updateUI() {
        refershUI()
    }
    
    func didLoadData() {
        tableView.reloadData()
    }
    
}

extension MainTableViewController: CustomHeaderDelegate {
    func didTapButton(in section: Int) {
        if !UserStatus.productPurchased {
            showAdsBanner()
        }
        viewModel.adsClicksCount += 1
        
        let char  = viewModel.charOfSection(section: section)
        if char.words.count > 0 {
            openSectionOf(char: char, section: section)
        }
    }
}
