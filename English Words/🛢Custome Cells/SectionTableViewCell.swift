//
//  SectionTableViewCell.swift
//  English Words
//
//  Created by Elsayed Hussein on 12/20/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

class SectionTableViewCell: UITableViewCell {
    
    //MARK: Variables
    static let identifier = "SectionCell"
    var mainTVC:MainTableViewController!
    //MARK: Outlets
    @IBOutlet weak var oLblSectionTitle: UILabel!
    @IBOutlet weak var oBtnDropDown: UIButton!
    @IBOutlet weak var oBtnSelect: UIButton!
    //MARK: Actions
    @IBAction func aBtnDropDown(_ sender: UIButton) {
        if !UserStatus.productPurchased{
            if self.mainTVC.adsClicksCount % 8 == 0 {
            if self.mainTVC.interstitial.isReady {
                self.mainTVC.interstitial.present(fromRootViewController: self.mainTVC)
            } else {
                print("Ad wasn't ready")
            }
        }
        }
        self.mainTVC.adsClicksCount += 1
        let char  = self.mainTVC.chars[sender.tag]
        if char.words.count > 0 {
            char.isExpanded = !char.isExpanded
            if char.isExpanded{
                self.mainTVC.tableView.reloadData()
                self.mainTVC.tableView.scrollToRow(at: IndexPath(row:0,section:sender.tag), at: .top, animated: true)
            }
            else{
                UIView.transition(with: self.mainTVC.tableView,
                                  duration: 0.3,
                                  options: UIViewAnimationOptions.curveLinear,
                                  animations: { self.mainTVC.tableView.reloadData() })
            }
        }
    }
    
    //MARK: Methods
    func setupViews() {
        
    }
    
    
}
