
//
//  AddressBook.swift
//  JSFunc
//
//  Created by taoyuanheng on 2018/6/21.
//  Copyright © 2018年 iber. All rights reserved.
//

import Foundation
import UIKit

typealias AddressBookResult = (_ success: Bool,_  message: String,_  data: [String]) -> Void

class AddressBook: NSObject {
    
    class func getAddressBook(_ block: @escaping AddressBookResult) {
        
        PPGetAddressBook.getOriginalAddressBook(addressBookArray: { (addressBookArray) in
            
            var temp: [String] = [String]()
            for item in addressBookArray {
                temp.append(item.toJSONString() ?? "")
            }
            block(true, "获取通讯录成功", temp)
        }, authorizationFailure: {
            let alertView = UIAlertController.init(title: "提示",
                                                   message: "请在iPhone的“设置-隐私-通讯录”选项中，允许访问您的通讯录",
                                                   preferredStyle: UIAlertControllerStyle.alert)
            let confirm = UIAlertAction.init(title: "知道啦", style: UIAlertActionStyle.cancel, handler: { (action) in
                block(false, "获取权限失败", [])
            })
            alertView.addAction(confirm)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
        })
    }
}
