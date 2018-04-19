//
//  Helpers.swift
//  English Words
//
//  Created by Elsayed Hussein on 12/20/17.
//  Copyright © 2017 mac. All rights reserved.
//

import Foundation
class Helper{
    
    class func readDataFromCSV(fileName:String, fileType: String)-> String!{
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
    class func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
                cleanFile = cleanFile.replacingOccurrences(of: "\"", with: "")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";\n", with: "")
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
    class func emptyTableView(tableView:UITableView,dataCount:Int,dataCome:Bool,emptyTableViewMessage:String ,seperatorStyle:UITableViewCellSeparatorStyle)->Int{
        if dataCome {
            if dataCount > 0
            {
                tableView.separatorStyle = seperatorStyle
                tableView.backgroundView = nil
            }
            else
            {
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text          = emptyTableViewMessage
                noDataLabel.textColor     = UIColor.darkGray
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
            }
        }
        else{
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
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
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
}

import UIKit

class Loader {
    
    
    private class func createLoaderView()->UIView{
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        let loaderView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        loaderView.layer.cornerRadius = 4
        loaderView.backgroundColor = .lightGray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = loaderView.center
        activityIndicator.tag = 100
        activityIndicator.color = UIColor.white
        loaderView.tag = 1000
        loaderView.addSubview(activityIndicator)
        return loaderView
    }
    class func show(view:UIView) {
        let loaderView = createLoaderView()
        let activityIndicator = loaderView.viewWithTag(100) as! UIActivityIndicatorView
        activityIndicator.startAnimating()
        loaderView.center = view.center
        view.addSubview(loaderView)
        view.isUserInteractionEnabled = false
    }
    
    class func hide(view:UIView) {
        for subview in view.subviews {
            if subview.tag == 1000 {
                subview.removeFromSuperview()
            }
        }
        view.isUserInteractionEnabled = true
    }
}
