//
//  MainViewModel.swift
//  English Words
//
//  Created by Elsayed Hussein on 7/17/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import CoreData

class MainViewModel: NSObject {
    
    //MARK: Variables
    var chars = [Char]()
    var remembredWords = [NSManagedObject]()
    var cleanWords = [String]()
    var dataCome = false
    var adsClicksCount = 0
    weak var delegate: ViewModelDelegate!
    
    //MARK: Methods
    func loadWordsFromExcelFile(){
        var data = Helper.readDataFromCSV(fileName: Constants.englishFileName, fileType: "csv")
        data = Helper.cleanRows(file: data!)
        let csvRows = Helper.csv(data: data!)
        cleanWords = csvRows.compactMap { (wordss) -> String? in
            wordss.first
        }
        
        // 
        if !UserStatus.productPurchased {
            cleanWords = cleanWords.chunks(cleanWords.count-750)[0]
        }
        
        // deleate words from core data if you come from purchase
        WordObjectManager.shared?.deleteWordFromCoreData()
        
        DispatchQueue.global().async(execute: {
            
            // get exist words
            self.remembredWords = WordObjectManager.shared!.getExistWords(cleanWords: self.cleanWords)
            
            // show remembered words to navigation item
            DispatchQueue.main.async(execute: {
                self.delegate.updateUI()
            })
            
        })
        
        fetchWords(words: cleanWords)
    }
    
    func fetchWords(words:[String]){
        for _char  in "abcdefghijklmnopqrstuvwxyz" {
            let wordsByChar = words.filter({ (word) -> Bool in
                word.hasPrefix("\(_char)")
            }).map({ (fetchedWord) -> Word in
                Word(isRemebered: false, data: fetchedWord)
            })
            let char = Char(isExpanded: false, words: wordsByChar)
            chars.append(char)
        }
        dataCome = true
        delegate.didLoadData()
    }
    
    func numberOfSections() -> Int {
        return UserStatus.productPurchased ? self.chars.count : self.chars.count - 10
    }
    
    func numberOfRowsFor(section: Int) -> Int {
        return self.chars[section].isExpanded ? self.chars[section].words.count : 0
    }
    func wordOf(indexPath: IndexPath) -> Word {
        return chars[indexPath.section].words[indexPath.row]
    }
    
    func checkIfWordIsRemeberedOf(indexPath: IndexPath) -> Word {
        let word =  wordOf(indexPath: indexPath)
        let wordObjs = remembredWords.filter { (wordObj) -> Bool in
            wordObj.value(forKey: "id") as! String == word.title
        }
        if wordObjs.count > 0 {
            word.isRemebered = wordObjs[0].value(forKey: "isRemember") as! Bool
        }
        
        return word
    }
    
    func charOfSection(section: Int) -> Char {
        return chars[section]
    }
}
