//
//  Loader.swift
//  English Words
//
//  Created by Elsayed Hussein on 7/17/18.
//  Copyright © 2018 mac. All rights reserved.
//
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
