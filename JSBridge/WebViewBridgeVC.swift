//
//  WebViewBridgeVC.swift
//  JSFunc
//
//  Created by taoyuanheng on 2018/6/21.
//  Copyright © 2018年 iber. All rights reserved.
//

import UIKit

class WebViewBridgeVC: UIViewController {

    // 本地是 .local
    // 远端是 .remote
    fileprivate let loadType: LoadType = .remote
    
    fileprivate var isFirst = true
    
    // 远端URL配置
    fileprivate let remoteUrl = "http://218.2.130.246:2011/index.html?f=\(arc4random())"
    
    // 本地入口文件配置
    fileprivate struct localResConfig {
        // 文件名
        static let name: String = "index"
        // 文件类型
        static let type: String = "html"
        // 文件夹
        static let folder: String = "/widget/"
    }
    
    fileprivate var bridge: SwiftWebViewBridge!
    
    fileprivate var webView: UIWebView!
    
    
    fileprivate var indicatorView: NVActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicatorView = {
            let view = NVActivityIndicatorView(frame: CGRect.init(
                x: self.view.center.x - 25,
                y: self.view.center.y + 25,
                width: 50.0,
                height: 50.0))
            view.type = .lineScale
            view.color = UIColor.darkGray
            return view
        }()
        
        webView = {
            let view = UIWebView()
            view.delegate = self
            view.scalesPageToFit = true
            view.scrollView.bounces = false
            view.backgroundColor = UIColor.white
            return view
        }()
        
        self.view.addSubview(indicatorView)
        
        self.view.insertSubview(webView, belowSubview: self.indicatorView)

        webView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        self.initBridge()
        
        HandleRegisterManager.share.scanActionDelegate = self
        HandleRegisterManager.share.registerAllHandle(bridge: self.bridge)
        
        loadType == .local ?  self.loadLocalWebPage() : self.loadRemoteWebPage(urlStr: remoteUrl)
    }
    
    func initBridge() {
        self.bridge = SwiftWebViewBridge.bridge(webView, defaultHandler: { data, responseCallback in
            print("webview received message from JS: \(data)")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                responseCallback(["msg": "webview already got your msg"])
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// webview 加载周期
extension WebViewBridgeVC: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        if self.isFirst {
            self.indicatorView.startAnimating()
            Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [unowned self] (timer) in
                self.indicatorView.stopAnimating()
                self.isFirst = false
            }
        }
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.indicatorView.stopAnimating()
        self.isFirst = false
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("\(error)")
    }
}

extension WebViewBridgeVC: ScanAction {
    func push(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension WebViewBridgeVC {
    fileprivate func loadLocalWebPage() {
        guard let urlPath = Bundle.main.url(forResource: localResConfig.name, withExtension: localResConfig.type, subdirectory: localResConfig.folder) else {
            print("Couldn't find the index.html file in bundle!")
            return
        }
        
        var urlString: String
        do {
            urlString  = try String(contentsOf: urlPath)
            self.webView.loadHTMLString(urlString, baseURL: urlPath)
        } catch let error as NSError {
            NSLog("\(error)")
            return
        }
    }
    
    fileprivate func loadRemoteWebPage(urlStr: String) {
        guard let url = URL(string: urlStr) else { return}
        
        let urlRequest = URLRequest(url: url )
        self.webView.loadRequest(urlRequest)
    }
}

enum LoadType: Int {
    case local
    case remote
}

