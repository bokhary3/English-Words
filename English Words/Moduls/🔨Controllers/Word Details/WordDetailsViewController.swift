//
//  WordDetailsViewController.swift
//  English Words
//
//  Created by Elsayed Hussein on 11/4/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import GoogleMobileAds
import FirebaseAnalytics

class WordDetailsTableViewController: UITableViewController {
    
    //MARK: Variables
    var word: Word!
    weak var delegate: WordsDelegate!
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var pitch: Float = 1.0
    private var rate = AVSpeechUtteranceDefaultSpeechRate
    private var volume: Float = 1.0
    
    //MARK: Outlets
    @IBOutlet weak var wordInfoLabel: UITableViewCell!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var rememberCell: UITableViewCell!
    @IBOutlet weak var speakButton: UIButton!
    @IBOutlet weak var iMemorizedThisWordLabel: UILabel!
    @IBOutlet weak var translatedWordLabel: UILabel!
    
    
    //MARK: View lifcycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup views
        setupViews()
        
        addADSBanner()
        
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
    
    //MARK: Actions
    @IBAction func speakWordButtonTapped(_ sender: UIButton) {
        if UserStatus.productPurchased {
            let utterance = AVSpeechUtterance(string: self.wordLabel.text ?? "")
            self.speechSynthesizer.speak(utterance)
            Analytics.logEvent("Word Details", parameters: ["speak_word" : word.title])
        } else {
            let upgradeManager = UpgradeVersionManager(viewController: self)
            upgradeManager.alertUpgardeMessage(message: "Upgrade Version to can use speak feature!")
        }
        
    }
    
    //MARK: Methods
    func setupViews() {
        
        self.speechSynthesizer.delegate = self
        
        wordLabel.text = word.title
        translatedWordLabel.text = word.translated
        
        rememberCell.accessoryType = WordObjectManager.shared!.isRemeberWord(word: word) ? .checkmark : .none
        wordInfoLabel.textLabel?.text = "\'\(word.title)\' is \(word.info), occures \(word.occurs) times."
        
        setMemorizeText()
    }
    
    func addADSBanner() {
        if !UserStatus.productPurchased {
            // add banner view
            let bannerSize = UIDevice.current.userInterfaceIdiom == .phone ? kGADAdSizeLargeBanner : kGADAdSizeLeaderboard
            let bannerView = GADBannerView(adSize: bannerSize)
            bannerView.adUnitID = Constants.Keys.adMobBannerUnitID
            bannerView.rootViewController = self
            bannerView.delegate = self
            self.tableView.tableFooterView = bannerView
            bannerView.load(GADRequest())
            
        }
        else{
            // setup search bar
        }
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
        Analytics.logEvent("Word Details", parameters: ["word_in_dictionary" : urlPath])
        openWebViewController(urlPath: urlPath)
    }
    
    func translateByGoogle() {
        if UserStatus.productPurchased {
            let urlPath = Constants.WebSites.googleTranslate + word.title
            Analytics.logEvent("Word Details", parameters: ["translate_by_word" : urlPath])
            openWebViewController(urlPath: urlPath)
        } else {
            let upgradeManager = UpgradeVersionManager(viewController: self)
            upgradeManager.alertUpgardeMessage(message: "Upgrade Version to can use Google translate feature!")
        }
    }
    func listenToTheWord() {
        let urlPath = Constants.WebSites.youGlish + word.title
        Analytics.logEvent("Word Details", parameters: ["Listen_to_word" : urlPath])
        openWebViewController(urlPath: urlPath)
    }
    
    func rememberTheWord() {
        Analytics.logEvent("Word Details", parameters: ["remember_word" : word.title])
        WordObjectManager.shared?.remeberWord(word: word)
        rememberCell.accessoryType = word.isRemebered ? .checkmark : .none
        
        setMemorizeText()
    }
    
    private func setMemorizeText() {
        if word.isRemebered {
            iMemorizedThisWordLabel.text = "Yes, I memorize it."
        } else {
            iMemorizedThisWordLabel.text = "Do you memorize '\(word.title)' word?"
        }
    }
}

extension WordDetailsTableViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.speakButton.isEnabled = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.speakButton.isEnabled = true
    }
}
extension WordDetailsTableViewController: GADBannerViewDelegate {
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
