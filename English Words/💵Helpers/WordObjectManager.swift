//
//  WordObjectManager.swift
//  English Words
//
//  Created by Elsayed Hussein on 7/17/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import CoreData

class WordObjectManager {
    //MARK: Variables
    static let shared = WordObjectManager()
    private let managedContext: NSManagedObjectContext
    private var existWords = [NSManagedObject]()
    
    //MARK: Methods
    private init!() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        
        // 1
        self.managedContext =
            appDelegate.persistentContainer.viewContext
    }
    
    func getExistWords(cleanWords: [String]) -> [NSManagedObject] {
        existWords.removeAll()
        for word in cleanWords {
            if someEntityExists(id: word) {
                // get exist words from core data
                getExistWordsFromCoreData()
                break
            } else {
                // add word to core data
                addWordToCoreData(word: word)
            }
        }
        return existWords
    }
    func remeberWord(word: Word) {
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "WordObject")
        
        fetchRequest.predicate = NSPredicate(format: "id = %@", word.data)
        
        var results: [NSManagedObject] = []
        
        do {
            results = try managedContext.fetch(fetchRequest)
            if results.count > 0 {
                let wordObj = results[0]
                var isRemeber = wordObj.value(forKey: "isRemember") as! Bool
                isRemeber = !isRemeber
                word.isRemebered = isRemeber
                wordObj.setValue(isRemeber, forKey: "isRemember")
                try managedContext.save()
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
    }
    func isRemeberWord(word: Word) -> Bool {
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "WordObject")
        
        fetchRequest.predicate = NSPredicate(format: "id = %@", word.data)
        
        var results: [NSManagedObject] = []
        
        do {
            results = try managedContext.fetch(fetchRequest)
            if results.count > 0 {
                let wordObj = results[0]
                let isRemeber = wordObj.value(forKey: "isRemember") as! Bool
                return isRemeber
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return false
    }
    
    private func addWordToCoreData(word: String) {
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
            self.existWords.append(wordObj)
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private func getExistWordsFromCoreData() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WordObject")
        var results: [NSManagedObject] = []
        
        do {
            results = try managedContext.fetch(fetchRequest)
            self.existWords = results
        }
        catch {
            print("error executing fetch request: \(error)")
        }
    }
    
    private func someEntityExists(id: String) -> Bool {
        
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
    
    func rememberedWordsCount() -> Int {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WordObject")
        fetchRequest.predicate = NSPredicate(format: "isRemember = %d", true)
        
        var results: [NSManagedObject] = []
        
        do {
            results = try managedContext.fetch(fetchRequest)
            return results.count
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return 0
    }
    
    func allWordsAcount() -> Int {
        return existWords.count
    }
    
    func deleteWordFromCoreData() {
        if Constants.fromPurchaseProcess {
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "WordObject")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            
            do {
                try managedContext.execute(deleteRequest)
                try managedContext.save()
            } catch {
                print ("There was an error")
            }
        }
    }
}
