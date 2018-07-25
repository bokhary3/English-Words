//
//  Alert.swift
//  English Words
//
//  Created by Elsayed Hussein on 1/10/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import UIKit
class Alert {
    
    class func alert(title: String = "" , message: String , alertActionTitle: String = "Ok") {
        
        if let topController = UIApplication.topViewController() {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            
            topController.present(alert, animated: true, completion: nil)
        }
        
    }
}

