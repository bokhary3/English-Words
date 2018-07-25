//
//  ViewModelDelegate.swift
//  English Words
//
//  Created by Elsayed Hussein on 7/17/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation

protocol ViewModelDelegate: AnyObject {
    func didLoadData()
    func updateUI()
}
