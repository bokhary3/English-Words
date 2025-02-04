//
//  MainTableViewController.swift
//  English Words
//
//  Created by Elsayed Hussein on 12/20/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAnalytics
import MOLH

protocol WordsDelegate: AnyObject {
    func refresh()
}

class MainTableViewController: UITableViewController {
    
    //MARK: Variables
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
        Analytics.logEvent(screenName, parameters: ["class": screenClass])
        // [END set_current_screen]
    }
    //MARK: Outlets
    @IBOutlet var viewModel: MainViewModel!
    
    //MARK: Actions
    @IBAction func searchBarButtonAction(_ sender: UIBarButtonItem) {
        let upgardeManager = UpgradeVersionManager(viewController: self)
        upgardeManager.alertUpgardeMessage(message: NSLocalizedString("upgradeSearchFeature", comment: ""))
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
        
            navigationItem.hidesSearchBarWhenScrolling = false
    }
    func setTableViewHeader() {
        // create banner view
        // setup search bar
        setupSearchBar()
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
        cell.detailTextLabel?.text = word.translated
        
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
             let expandedAngle: CGFloat = MOLHLanguage.isArabic() ? (.pi/2): -(.pi/2)
            headerView.oBtnDropDown.rotate(expandedAngle)
        } else {
            let collapsedAngle: CGFloat = MOLHLanguage.isArabic() ? -(.pi/2): (.pi/2)
            headerView.oBtnDropDown.rotate(collapsedAngle)
        }
        if char.words.count > 0 {
            var black = UIColor.black
            var gray = UIColor.gray
            if #available(iOS 13, *) {
                black = UIColor.label
                gray = UIColor.systemGray
            }
            let mutableAttributed = NSMutableAttributedString(string: "\(char.words[0].title.capitalized.first!)", attributes: [NSAttributedString.Key.foregroundColor: black])
            let attributedString = NSAttributedString(string: " (\(char.words.count))", attributes: [NSAttributedString.Key.foregroundColor: gray])
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

extension MainTableViewController {
    func openSectionOf(char: Char, section: Int) {
        char.isExpanded = !char.isExpanded
        if char.isExpanded {
            self.tableView.reloadSections(
                [section], with: UITableViewRowAnimation.automatic)
            tableView.scrollToRow(at: [section, 0], at: .middle, animated: true)
        } else {
            self.tableView.reloadSections(
                [section], with: UITableViewRowAnimation.automatic)
        }
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
//        tableView.reloadData()
    }
}

extension MainTableViewController: CustomHeaderDelegate {
    func didTapButton(in section: Int) {
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
