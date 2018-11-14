//
//  WebViewController.swift
//  English Words
//
//  Created by Elsayed Hussein on 11/10/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import WebKit
import GoogleMobileAds
import FirebaseAnalytics

class WebViewController: UIViewController {
    
    //MARK: Variables
    var url: URL!
    var bannerView: GADBannerView!
    
    //MARK: Outlets
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: View lifcycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup views
        setupViews()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        recordScreenView()
        
        Analytics.logEvent("WebViewController", parameters: ["URL String" : url.absoluteString])
    }
    func recordScreenView() {
        // These strings must be <= 36 characters long in order for setScreenName:screenClass: to succeed.
        guard let screenName = title else {
            return
        }
        let screenClass = classForCoder.description()
        
        // [START set_current_screen]
        Analytics.setScreenName(screenName, screenClass: screenClass)
        // [END set_current_screen]
    }
    //MARK: Actions
    
    //MARK: Methods
    func setupViews() {
        webView.navigationDelegate = self
        let request = URLRequest(url: url)
        webView.load(request)
        addADSBanner()
    }
    func addADSBanner() {
        if !UserStatus.productPurchased {
            let bannerSize = UIDevice.current.userInterfaceIdiom == .phone ? kGADAdSizeBanner : kGADAdSizeLeaderboard
            bannerView = GADBannerView(adSize: bannerSize)
            
            bannerView.adUnitID = Constants.Keys.adMobBannerUnitID
            bannerView.rootViewController = self
            bannerView.delegate = self
            bannerView.load(GADRequest())
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bannerView)
            
            positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
        }
        else{
            
        }
    }
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
        // Position the banner. Stick it to the bottom of the Safe Area.
        // Make it constrained to the edges of the safe area.
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
            ])
        bannerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
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
extension WebViewController: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}
