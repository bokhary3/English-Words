//
//  Helpers.swift
//  English Words
//
//  Created by Elsayed Hussein on 12/20/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import SafariServices

class Helper{
    
    class func readDataFromCSV(fileName: String, fileType: String)-> String! {
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                return nil
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    class func cleanRows(file: String) -> String {
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\"", with: "")
        return cleanFile
    }
    
    class func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ";")
            result.append(columns)
        }
        return result
    }
    
    class func emptyTableView(tableView: UITableView, dataCount: Int, dataCome: Bool ,emptyTableViewMessage: String ,seperatorStyle: UITableViewCellSeparatorStyle) -> Int {
        if dataCome {
            if dataCount > 0 {
                tableView.separatorStyle = seperatorStyle
                tableView.backgroundView = nil
            } else {
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text          = emptyTableViewMessage
                noDataLabel.textColor     = UIColor.darkGray
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
            }
        } else {
            let activityIndicatior = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width:50, height: 50))
            activityIndicatior.activityIndicatorViewStyle = .whiteLarge
            activityIndicatior.color = .lightGray
            activityIndicatior.center = tableView.center
            activityIndicatior.startAnimating()
            tableView.backgroundView  = activityIndicatior
            tableView.separatorStyle  = .none
        }
        return dataCount
    }
    
    class func alert(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
}

