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
    @IBOutlet weak var oBtnRemember: UIButton!
    @IBOutlet weak var oBtnDictionary: UIButton!
    @IBOutlet weak var oBtnInfo: UIButton!
    @IBOutlet weak var oBtnTranslate: UIButton!
    @IBOutlet weak var oBtnYouGlish: UIButton!
    @IBOutlet weak var wordActionsStackView: UIStackView!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    //MARK: Actions
    
    //MARK: Methods
    
    func configureCell(indexPath: IndexPath, word: Word) {
        
        oBtnRemember.setBackgroundImage(word.isRemebered ? #imageLiteral(resourceName: "check-box"):#imageLiteral(resourceName: "blank-check") , for: .normal)
        oLblWordTitle.text = word.title
        
        oBtnTranslate.isHidden = !UserStatus.productPurchased
        if word.isExpanded {
            let rotateDegree = word.isExpanded ? CGFloat.pi/2 : CGFloat.pi
            arrowImageView.rotate(rotateDegree)
        }
        UIView.animate(withDuration: 0.3) {
            // This is workaround because setting stackviews's hidden property in animation block not work correctly
            if self.wordActionsStackView.isHidden != !word.isExpanded {
                self.wordActionsStackView.isHidden = !word.isExpanded
            }
            print(self.oLblWordTitle.text!,self.wordActionsStackView.isHidden,word.isExpanded)
        }
        
    }
    
    
    
    
    
}
