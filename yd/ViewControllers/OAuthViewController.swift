//
//  ViewController.swift
//  tryYD
//
//  Created by Максим Трунников on 21/04/2019.
//  Copyright © 2019 Максим Трунников. All rights reserved.
//

import UIKit
import WebKit

class OAuthViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authURL = yaDiskAPI.authString + yaDiskAPI.CLIENT_ID
        let urlRequest = URLRequest.init(url: URL.init(string: authURL)!)
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.load(urlRequest)
    }
    
    func checkRequestForCallbackURL(request: URLRequest) {
        guard let requestURLString = (request.url?.absoluteString) else {
            return
        }
        if requestURLString.contains("#access_token=") {
            var startIndex = requestURLString.firstIndex(of: "=")
            startIndex = requestURLString.index(after: startIndex!)
            let endIndex = requestURLString.firstIndex(of: "&")
            yaDiskAPI.token = String(requestURLString[startIndex!..<endIndex!])
            print(yaDiskAPI.token)
            self.present((storyboard?.instantiateViewController(withIdentifier: "AfterLoginTBVC"))!, animated: true, completion: nil)
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        checkRequestForCallbackURL(request: navigationAction.request)
        decisionHandler(.allow)
    }
}
