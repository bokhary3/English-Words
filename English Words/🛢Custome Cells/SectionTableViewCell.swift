//
//  SectionTableViewCell.swift
//  English Words
//
//  Created by Elsayed Hussein on 12/20/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import MOLH

protocol CustomHeaderDelegate: class {
    func didTapButton(in section: Int)
}

class SectionTableViewCell: UITableViewHeaderFooterView {
    
    //MARK: Variables
    static let identifier = "SectionCell"
    weak var delegate: CustomHeaderDelegate?
    var sectionNumber: Int!
    
    //MARK: Outlets
    @IBOutlet weak var oLblSectionTitle: UILabel!
    @IBOutlet weak var oBtnDropDown: UIButton!
    @IBOutlet weak var oBtnSelect: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    //MARK: Actions
    @IBAction func didTapButton(_ sender: AnyObject) {
        delegate?.didTapButton(in: sectionNumber)
    }
    
    //MARK: Methods
    override func prepareForReuse() {
        if MOLHLanguage.isArabic() {
            oBtnDropDown.setImage(#imageLiteral(resourceName: "arrow_right_ar"), for: .normal)
        } else {
             oBtnDropDown.setImage(#imageLiteral(resourceName: "arrow_right_en"), for: .normal)
        }
    }
    override func awakeFromNib() {
        if MOLHLanguage.isArabic() {
            oBtnDropDown.setImage(#imageLiteral(resourceName: "arrow_right_ar"), for: .normal)
        } else {
            oBtnDropDown.setImage(#imageLiteral(resourceName: "arrow_right_en"), for: .normal)
        }
    }
}
