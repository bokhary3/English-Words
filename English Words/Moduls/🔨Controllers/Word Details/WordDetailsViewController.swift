//
//  WordDetailsViewController.swift
//  English Words
//
//  Created by Elsayed Hussein on 11/4/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

class WordDetailsViewController: UIViewController {
    
    //MARK: Variables
    var word: Word!
    //MARK: Outlets
    @IBOutlet weak var wordLabel: UILabel!
    
    
    //MARK: View lifcycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup views
        setupViews()
        
    }
    
    //MARK: Actions
    
    //MARK: Methods
    func setupViews() {
        wordLabel.text = word.title
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
