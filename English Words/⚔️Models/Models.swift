//
//  Models.swift
//  English Words
//
//  Created by Elsayed Hussein on 12/20/17.
//  Copyright © 2017 mac. All rights reserved.
//

import Foundation
class Word {
    var isRemebered:Bool = false
    var title:String = ""
    init(isRemebered:Bool,title:String) {
        self.isRemebered = isRemebered
        self.title = title
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
