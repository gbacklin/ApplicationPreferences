//
//  AppPreferences.swift
//  SimplePreference
//
//  Created by Gene Backlin on 2/24/18.
//  Copyright © 2018 Gene Backlin. All rights reserved.
//

import UIKit

class AppPreferences: NSObject {
    
    var preferenceIds: [String]?
    var preferences: [String : AnyObject]?
    
    // MARK: - Initialization
    
    init(ids: [String]) {
        super.init()
        
        preferenceIds = ids
        preferences = getPrefrences(keys: ids)
    }
    
    func getPrefrences(keys: [String]) -> [String : AnyObject]? {
        var localDefaults: [String : AnyObject] = [String : AnyObject]()
        
        if let settings: [String : AnyObject] = bundleSettings() {
            
            for prefItem: String in settings.keys {
                if let tempDict: [String : AnyObject] = settings[prefItem] as? [String : AnyObject] {
                    localDefaults[prefItem] = tempDict as AnyObject
                }
            }
            UserDefaults.standard.register(defaults: localDefaults)
            UserDefaults.standard.synchronize()
        }
        
        return localDefaults
    }
    
    func bundleSettings() -> [String : AnyObject]? {
        let path: String = Bundle.main.bundlePath
        let settingsPath: String = path.stringByAppendingPathComponent(path: "Settings.bundle")
        let rootPath: String = settingsPath.stringByAppendingPathComponent(path: "Root.plist")
        
        var plistDict: [String : AnyObject] = [String : AnyObject]()
        var settingsDict: [String : AnyObject]? = NSDictionary(contentsOfFile: rootPath) as? [String: AnyObject]
        var preferenceSpecifiers: [[String : AnyObject]]? = settingsDict!["PreferenceSpecifiers"] as? [[String : AnyObject]]
        
        for tempDict: [String : AnyObject] in preferenceSpecifiers! {
            let typeValueStr: String = tempDict["Type"] as! String
            if typeValueStr == "PSChildPaneSpecifier" {
                let key: String = tempDict["Key"] as! String
                let keyValueStr: String = "\(key).plist"
                let plistPath: String = settingsPath.stringByAppendingPathComponent(path: keyValueStr)
                if let childSettings: [String : AnyObject] = NSDictionary(contentsOfFile: plistPath) as? [String: AnyObject] {
                    if let childArray: [[String : AnyObject]] = childSettings["PreferenceSpecifiers"] as? [[String : AnyObject]] {
                        for tempChildDict in childArray {
                            preferenceSpecifiers?.append(tempChildDict)
                            if let childKey: String = tempChildDict["Key"] as? String {
                                plistDict[childKey] = tempChildDict as AnyObject
                            }
                        }
                    }
                }
            } else {
                if let childKey: String = tempDict["Key"] as? String {
                    plistDict[childKey] = tempDict as AnyObject
                }
            }
        }
        
        return plistDict
    }
    
    func valueFor(key: String) -> Any? {
        var keyValue: Any? = UserDefaults.standard.object(forKey: key)
        
        if let tempDict: [String : AnyObject] = preferences![key] as? [String : AnyObject] {
            let typeValueStr: String = tempDict["Type"] as! String
            if typeValueStr == "PSMultiValueSpecifier" {
                let titles: [String]? = tempDict["Titles"] as? [String]
                if keyValue is [String : AnyObject] {
                    if let index: Int = Int((tempDict["DefaultValue"] as? String)!) {
                        keyValue = titles![index]
                    } else {
                        keyValue = titles![0]
                    }
                } else {
                    if let index: Int = Int(keyValue as! String) {
                        keyValue = titles![index]
                    }
                }
            } else if typeValueStr == "PSTextFieldSpecifier" {
                if keyValue is [String : AnyObject] {
                    keyValue = tempDict["DefaultValue"]
                }
            } else {
                if keyValue is [String : AnyObject] {
                    keyValue = tempDict["DefaultValue"]
                }
            }
        }
        
        return keyValue
    }
    
}

