//
//  WordTableViewCell.swift
//  English Words
//
//  Created by Elsayed Hussein on 12/20/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import SafariServices
import CoreData

class WordTableViewCell: UITableViewCell {
    
    //MARK: Variables
    static let identifier = "WordCell"
    
    //MARK: Outlets
    @IBOutlet weak var oLblWordTitle: UILabel!
    
    //MARK: Actions
    
    //MARK: Methods
    
    func configureCell(indexPath: IndexPath, word: Word) {
        oLblWordTitle.text = word.title
    }
}
