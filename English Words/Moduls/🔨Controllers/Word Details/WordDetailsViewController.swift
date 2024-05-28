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
import FirebaseAnalytics
import MOLH

class WordDetailsTableViewController: UITableViewController {
    
    //MARK: Variables
    var word: Word!
    
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
    
    
    //MARK: View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup views
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
        Analytics.logEvent(screenName, parameters: ["class": screenClass])
        // [END set_current_screen]
    }
    
    //MARK: Actions
    @IBAction func speakWordButtonTapped(_ sender: UIButton) {
        if UserStatus.productPurchased {
            let audioSession = AVAudioSession() // 2) handle audio session first, before trying to read the text
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault, options: .duckOthers)
                try audioSession.setActive(false)
            } catch let error {
                print("❓", error.localizedDescription)
            }
            let utterance = AVSpeechUtterance(string: self.wordLabel.text ?? "")
            let voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.voice = voice
            self.speechSynthesizer.speak(utterance)
            Analytics.logEvent("Word_Details", parameters: ["speak_word" : word.title.replacingOccurrences(of: " ", with: "_")])
        } else {
            let upgradeManager = UpgradeVersionManager(viewController: self)
            upgradeManager.alertUpgardeMessage(message: NSLocalizedString("upgradeSpeakFeature", comment: ""))
        }
        
    }
    
    //MARK: Methods
    func chooseSpeechVoices() -> [AVSpeechSynthesisVoice] {
        // List all available voices in en-US language
        let voices = AVSpeechSynthesisVoice.speechVoices()
            .filter({$0.language == "en-US"})
        
        // split male/female voices
        let maleVoices = voices.filter({$0.gender == .male})
        let femaleVoices = voices.filter({$0.gender == .female})
        
        // pick voices
        let selectedMaleVoice = maleVoices.first(where: {if #available(iOS 16.0, *) {
            $0.quality == .premium
        } else {
            // Fallback on earlier versions
            $0.quality == .enhanced
        }}) ?? maleVoices.first // premium is only available from iOS 16
        let selectedFemaleVoice = femaleVoices.first(where: {$0.quality == .enhanced}) ?? femaleVoices.first
        
        //
        //        if selectedMaleVoice == nil && selectedFemaleVoice == nil {
        //            showAlert("Text to speech feature is not available on your device")
        //        } else if selectedMaleVoice == nil {
        //            showAlert("Text to speech with Male voice is not available on your device")
        //        } else if selectedFemaleVoice == nil {
        //            showAlert("Text to speech with Female voice is not available on your device")
        //        }
        if let selectedMaleVoice, let selectedFemaleVoice {
            return [selectedMaleVoice, selectedFemaleVoice]
        }
        return []
    }
    func setupViews() {
        
        self.speechSynthesizer.delegate = self
        
        wordLabel.text = word.title
        translatedWordLabel.text = word.translated
        
        rememberCell.accessoryType = WordObjectManager.shared!.isRemeberWord(word: word) ? .checkmark : .none
        
        if MOLHLanguage.isArabic() {
            wordInfoLabel.textLabel?.text = "كلمة '\(word.title)' هي \(word.info) وتتكرر \(word.occurs) مرة"
        } else  {
            wordInfoLabel.textLabel?.text = "\'\(word.title)\' is \(word.info), occures \(word.occurs) times."
        }
        wordInfoLabel.textLabel?.sizeToFit()
        
        setMemorizeText()
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
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let height =  wordInfoLabel.textLabel?.requiredHeight ?? UITableViewAutomaticDimension
            return height + 20
            
        }
        
        return 50
    }
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
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshMemorizedWords"), object: nil)
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
        Analytics.logEvent("Word_Details", parameters: ["word_in_dictionary" : urlPath])
        openWebViewController(urlPath: urlPath)
    }
    
    func translateByGoogle() {
        if UserStatus.productPurchased {
            let urlPath = Constants.WebSites.googleTranslate + word.title
            Analytics.logEvent("Word_Details", parameters: ["translate_by_word" : urlPath])
            openWebViewController(urlPath: urlPath)
        } else {
            let upgradeManager = UpgradeVersionManager(viewController: self)
            upgradeManager.alertUpgardeMessage(message: NSLocalizedString("upgradeGoogleTranslateFeature", comment: ""))
        }
    }
    func listenToTheWord() {
        let urlPath = Constants.WebSites.youGlish + word.title
        Analytics.logEvent("Word_Details", parameters: ["Listen_to_word" : urlPath])
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
            iMemorizedThisWordLabel.text = NSLocalizedString("yesImemorizeIt", comment: "")
        } else {
            if MOLHLanguage.isArabic() {
                iMemorizedThisWordLabel.text = "هل تحفظ كلمة '\(word.title)'؟"
            } else {
                iMemorizedThisWordLabel.text = "Do you memorize '\(word.title)' word?"
            }
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
