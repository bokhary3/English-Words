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
    
    class func colorOf(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count != 6 {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    class func openActionSheetSites(sender: UIButton, word: String, viewController: UIViewController) {
        
        let alert  = UIAlertController(title: "Translate \'\(word)\' by dictionary of ", message: "", preferredStyle: .actionSheet)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        let oxfordAction = UIAlertAction(title: "Oxford", style: .default) { (_) in
            let url = Constants.WebSites.oxfordLink + word
            self.openSafariVC(url: url, viewController: viewController)
        }
        let cambridgeAction = UIAlertAction(title: "Cambridge", style: .default) { (_) in
            let url = Constants.WebSites.cambridge + word
            self.openSafariVC(url: url, viewController: viewController)
        }
        let merriamWebsterAction = UIAlertAction(title: "Merriam Webster", style: .default) { (_) in
            let url = Constants.WebSites.merriam + word
            self.openSafariVC(url: url, viewController: viewController)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(oxfordAction)
        alert.addAction(cambridgeAction)
        alert.addAction(merriamWebsterAction)
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    class func openSafariVC(url: String, viewController: UIViewController) {
        let safariVC = SFSafariViewController(url: URL(string:url)!)
        viewController.present(safariVC, animated: true, completion: nil)
    }
    
    class func alert(title: String, message: String, sender: UIView, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
}

