//
//  HandleRegisterManager.swift
//  JSFunc
//
//  Created by taoyuanheng on 2018/6/22.
//  Copyright © 2018年 iber. All rights reserved.
//

import Foundation
import UIKit

protocol ScanAction {
    func push(vc: UIViewController)
}

class HandleRegisterManager: NSObject {
    
    fileprivate weak var lbxScanViewController: LBXScanViewController?
    
    fileprivate var scannerHandler: SWVBResponseCallBack!
    
    var scanActionDelegate: ScanAction?
    
    static let share = HandleRegisterManager()
    
    private override init() {
        super.init()
    }
    
    func registerAllHandle(bridge: SwiftWebViewBridge) {
        self.registerScanner(bridge: bridge)
        self.registerAddressBook(bridge: bridge)
    }
}

// register methods
extension HandleRegisterManager {
    
    // 注册扫码功能
    fileprivate func registerScanner(bridge: SwiftWebViewBridge) {
        bridge.registerHandlerForJS(handlerName: "scanner", handler: { [unowned self] jsonData, responseCallback in
            self.printReceivedParmas(jsonData)
            self.scannerHandler = responseCallback
            self.openScannerVC()
        })
    }
    
    // 注册通讯录功能
    fileprivate func registerAddressBook(bridge: SwiftWebViewBridge) {
        bridge.registerHandlerForJS(handlerName: "addressBook", handler: { [unowned self] jsonData, responseCallback in
            self.printReceivedParmas(jsonData)
            AddressBook.getAddressBook({ (success, msg, data) in
                responseCallback([
                    "success": success,
                    "message": msg,
                    "data": data
                    ])
            })
        })
    }
}

extension HandleRegisterManager {
    fileprivate func openScannerVC() {
        let scannerVC = ScanQR.getScanVC()
        self.lbxScanViewController = scannerVC
        self.lbxScanViewController?.scanResultDelegate = self
        self.scanActionDelegate?.push(vc: self.lbxScanViewController!)
    }
    
    fileprivate func printReceivedParmas(_ data: AnyObject) {
        print("webview recieved data passed from JS: \(data)")
    }
}

// 获取扫码结果并回调给js
extension HandleRegisterManager: LBXScanViewControllerDelegate {
    func scanFinished(scanResult: LBXScanResult, error: String?) {
    
        self.scannerHandler([
            "success": error == nil,
            "message": error == nil ? "" : error ?? "",
            "data": scanResult.strScanned ?? ""
            ])
    }
}


