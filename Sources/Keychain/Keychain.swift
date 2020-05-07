//
//  Keychain.swift
//  FWi-Fi
//
//  Created by PlugN on 28/02/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import Foundation
import Security

class Keychain {
    
    let accessGroup:String
    
    init(accessGroup: String) {
        self.accessGroup = accessGroup
    }

    func save(_ data: Any, forKey: String) -> Bool {
        let savedData: Data
        do {
            if #available(iOS 11.0, *) {
                savedData = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
            } else {
                // Fallback on earlier versions
                savedData = NSKeyedArchiver.archivedData(withRootObject: data)
            }
        } catch {
            savedData = Data()
        }
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : forKey,
            kSecValueData as String   : savedData,
            kSecAttrAccessGroup as String : accessGroup as String] as [String : Any]

        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        print(status)
        
        if status == noErr {
            return true
        } else {
            return false
        }
    }

    func value(forKey: String) -> Any? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : forKey,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne,
            kSecAttrAccessGroup as String : accessGroup as String] as [String : Any]

        var dataTypeRef: AnyObject? = nil

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        print(status)

        if status == noErr {
            if let d = dataTypeRef as? Data {
                let data: Any?
                do {
                    data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(d)
                } catch {
                    data = nil
                }
                return data
            }
            return nil
        } else {
            return nil
        }
    }
    
    func remove(forKey: String) -> Bool {
        let query = [
        kSecClass as String       : kSecClassGenericPassword as String,
        kSecAttrAccount as String : forKey,
        kSecAttrAccessGroup as String : accessGroup as String] as [String : Any]

        let status: OSStatus = SecItemDelete(query as CFDictionary)
        print(status)

        if status == noErr {
            return true
        } else {
            return false
        }
    }

    func createUniqueID() -> String {
        let uuid: CFUUID = CFUUIDCreate(nil)
        let cfStr: CFString = CFUUIDCreateString(nil, uuid)

        let swiftString: String = cfStr as String
        return swiftString
    }
}
