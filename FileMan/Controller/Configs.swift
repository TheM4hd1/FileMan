//
//  Configs.swift
//  FileMan
//
//  Created by Mahdi on 8/22/18.
//  Copyright © 2018 Mahdi Makhdumi. All rights reserved.
//

import Foundation

class Configs {
    
    static let shared = Configs()
    private let userDefaults = UserDefaults.standard
    
    private let PROXY_KEY = "ProxyStatus"
    var proxyStatus: String {
        get {
            return userDefaults.value(forKey: PROXY_KEY) as? String ?? "Disabled"
        } set {
            userDefaults.set(newValue, forKey: PROXY_KEY)
        }
    }
    
    private let BYTES_DOWNLOADED = "DownloadedBytes"
    var totalDownloadedBytes: Int64 {
        get {
            return userDefaults.value(forKey: BYTES_DOWNLOADED) as? Int64 ?? 0
        } set {
            userDefaults.set(newValue, forKey: BYTES_DOWNLOADED)
        }
    }
    
    let CURRENT_PATH_CHANGED_NOTIF = Notification.Name("currentPathChangedNotif")
}
