//
//  Models.swift
//  English Words
//
//  Created by Elsayed Hussein on 12/20/17.
//  Copyright © 2017 mac. All rights reserved.
//

import Foundation

class Word {
    var isRemebered = false
    var isExpanded = false
    var data = ""
    var title: String
    var translated: String
    var info: String
    var occurs: String
    
    init(isRemebered: Bool, data: String) {
        self.isRemebered = isRemebered
        self.data = data
        if let last = data.lastIndex(of: ",") {
            let index = data.index(after: last)
            
            self.translated = String(data[index...])
            
        } else {
            self.translated = data
        }
        
        let wordComponent =  data.components(separatedBy: ",")
        if wordComponent.count > 0 {
            self.title = wordComponent.first!.capitalized
            self.occurs = wordComponent[1]
        } else {
            self.title =  data.capitalized
            self.occurs = data
        }
        
        if let firstInfoIndex = data.firstIndex(of: "("),
            let lastInfoIndex = data.firstIndex(of: ")") {
            self.info = String(data[firstInfoIndex...lastInfoIndex])
        } else {
            self.info = ""
        }
        
    }
    
}
class Char {
    var isExpanded:Bool = false
    var words:[Word] = []
    init(isExpanded:Bool,words:[Word]) {
        self.isExpanded = isExpanded
        self.words = words
    }
}
