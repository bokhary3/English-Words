//
//  WebViewController.swift
//  English Words
//
//  Created by Elsayed Hussein on 11/10/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    //MARK: Variables
    var url: URL!
    
    //MARK: Outlets
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: View lifcycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup views
        setupViews()
    }
    
    //MARK: Actions
    
    //MARK: Methods
    func setupViews() {
        webView.navigationDelegate = self
        let request = URLRequest(url: url)
        webView.load(request)
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
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("FAIL WK:\(error.localizedDescription)")
    }
}
