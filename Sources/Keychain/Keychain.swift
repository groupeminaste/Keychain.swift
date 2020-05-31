//
//  Keychain.swift
//  FWi-Fi
//
//  Created by PlugN on 28/02/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import Foundation
import Security

public class Keychain {
    
    private let accessGroup: String?
    
    public init(accessGroup: String? = nil) {
        self.accessGroup = accessGroup
    }

    public func save(_ data: Any, forKey: String) -> Bool {
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
        var query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : forKey,
            kSecValueData as String   : savedData] as [String : Any]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as String
        }
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == noErr {
            return true
        } else {
            return false
        }
    }

    public func value(forKey: String) -> Any? {
        var query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : forKey,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne] as [String : Any]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as String
        }

        var dataTypeRef: AnyObject?

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

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
    
    public func remove(forKey: String) -> Bool {
        var query = [
        kSecClass as String       : kSecClassGenericPassword as String,
        kSecAttrAccount as String : forKey] as [String : Any]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as String
        }
        
        let status: OSStatus = SecItemDelete(query as CFDictionary)

        if status == noErr {
            return true
        } else {
            return false
        }
    }

    private func createUniqueID() -> String {
        let uuid: CFUUID = CFUUIDCreate(nil)
        let cfStr: CFString = CFUUIDCreateString(nil, uuid)

        let swiftString: String = cfStr as String
        return swiftString
    }
}
