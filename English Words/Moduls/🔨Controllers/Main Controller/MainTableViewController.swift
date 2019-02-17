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
import FirebaseAnalytics

protocol WordsDelegate: AnyObject {
    func refresh()
}

class MainTableViewController: UITableViewController {
    
    //MARK: Variables
    
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
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
    @IBOutlet var viewModel: MainViewModel!
    
    //MARK: Actions
    @IBAction func searchBarButtonAction(_ sender: UIBarButtonItem) {
        let upgardeManager = UpgradeVersionManager(viewController: self)
        upgardeManager.alertUpgardeMessage(message: "Upgrade version to can use search feature")
    }
    
    //MARK: Methods
    func setupViews() {
        tableView.register(UINib(nibName: "SectionView", bundle: nil), forHeaderFooterViewReuseIdentifier: "header")
        
        viewModel.delegate = self
        // build header table view
        setTableViewHeader()
        
        // load words from file
        self.viewModel.loadWordsFromExcelFile()
        
        // hide search button if purchased
        if UserStatus.productPurchased {
            navigationItem.leftBarButtonItem = nil
        }
        
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
    
    func refreshUI() {
        tableView.reloadData()
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
        return viewModel.chars[indexPath.section].isExpanded ? 60 : 0
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! SectionTableViewCell
        let char = viewModel.charOfSection(section: section)
        headerView.delegate = self
        headerView.sectionNumber = section
        headerView.containerView.backgroundColor = section % 2 == 0 ? UIColor(named: "evenColor") : UIColor(named: "oddColor")
        
        if char.isExpanded {
            headerView.oBtnDropDown.rotate(char.isExpanded ? .pi/2 : .pi)
        }
        if char.words.count > 0 {
            let mutableAttributed = NSMutableAttributedString(string: "\(char.words[0].title.capitalized.first!)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
            let attributedString = NSAttributedString(string: " (\(char.words.count))", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            mutableAttributed.append(attributedString)
            headerView.oLblSectionTitle.attributedText = mutableAttributed
        }
        else{
            headerView.oLblSectionTitle.text = "X"
        }
        return headerView
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let word = viewModel.wordOf(indexPath: indexPath)
        showAdsBanner()
        performSegue(withIdentifier: "showWordDetails", sender: word)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWordDetails" {
            let wordDetailsController = segue.destination as! WordDetailsTableViewController
            wordDetailsController.delegate = self
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
    func openSectionOf(char: Char, section: Int) {
        char.isExpanded = !char.isExpanded
        let viewHeader = tableView.headerView(forSection: section) as! SectionTableViewCell
        if char.isExpanded {
            viewHeader.oBtnDropDown.rotate(char.isExpanded ? .pi/2 : .pi)
            self.tableView.reloadSections(
                [section], with: UITableViewRowAnimation.automatic)
            tableView.scrollToRow(at: [section, 0], at: .middle, animated: true)
        } else {
            viewHeader.oBtnDropDown.rotate(0)
            self.tableView.reloadSections(
                [section], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func showAdsBanner() {
        if !UserStatus.productPurchased {
            if viewModel.adsClicksCount % 5 == 0 {
                if interstitial.isReady {
                    interstitial.present(fromRootViewController: self)
                } else {
                    print("Ad wasn't ready")
                }
            }
            viewModel.adsClicksCount += 1
        }
    }
}

extension MainTableViewController: GADInterstitialDelegate {
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
extension MainTableViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let searchResultVC = self.searchController.searchResultsController as! SearchResultTableViewController
        searchResultVC.allWords = viewModel.cleanWords.map({ (title) in
            Word(isRemebered: false, data: title)
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        refreshUI()
    }
}

extension MainTableViewController: ViewModelDelegate {
    func updateUI() {
        refreshUI()
    }
    
    func didLoadData() {
        tableView.reloadData()
    }
    
}

extension MainTableViewController: CustomHeaderDelegate {
    func didTapButton(in section: Int) {
        showAdsBanner()
        let char  = viewModel.charOfSection(section: section)
        if char.words.count > 0 {
            openSectionOf(char: char, section: section)
        }
    }
}

extension MainTableViewController: WordsDelegate {
    func refresh() {
        refreshUI()
    }
}
