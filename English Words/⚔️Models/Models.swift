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
    init(isRemebered: Bool, data: String) {
        self.isRemebered = isRemebered
        self.data = data
        
        let wordComponent =  data.components(separatedBy: ",")
        if wordComponent.count > 0 {
            self.title = wordComponent.first!.capitalized
        } else {
            self.title =  data.capitalized
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
