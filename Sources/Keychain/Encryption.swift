//
//  Encryption.swift
//  
//
//  Created by PlugN on 16/05/2020.
//

import Foundation
import Security


public class Encryption {
    
    public func getKeys(useEncryptionModule: CFString, keySize: Int) -> (publicKey: SecKey?, privateKey: SecKey?) {
        //Generation of RSA private and public keys
        let parameters: [String:Any] = [
            kSecAttrKeyType as String: useEncryptionModule,
            kSecAttrKeySizeInBits as String: keySize
        ]

        var publicKey, privateKey: SecKey?

        SecKeyGeneratePair(parameters as CFDictionary, &publicKey, &privateKey)
        
        return (publicKey: publicKey, privateKey: privateKey)
    }
    
    public func getBlockSize(key: SecKey) -> Int {
        return SecKeyGetBlockSize(key)
    }
    
    #if !os(macOS)
    @available(iOS, obsoleted: 10.0)
    public func encrypt(content: CFData, publicKey: SecKey, padding: SecPadding) -> CFData? {
        var ucontent = [UInt8](content as Data)
        let blockSize = SecKeyGetBlockSize(publicKey)
        var messageEncrypted = [UInt8](repeating: 0, count: blockSize)
        var messageEncryptedSize = blockSize

        var error: OSStatus
        
        error = SecKeyEncrypt(publicKey, padding, &ucontent, ucontent.count, &messageEncrypted, &messageEncryptedSize)
        
        if error != noErr {
            return nil
        }
        
        let createData = NSKeyedArchiver.archivedData(withRootObject: ucontent)
        
        return createData as CFData
    }
    
    #endif
    
    
    @available(iOS 10.0, macOS 10.12, watchOS 3.0, *)
    public func encrypt(content: CFData, publicKey: SecKey, usingAlgorithm: SecKeyAlgorithm) -> CFData? {
        var status = Unmanaged<CFError>?.init(nilLiteral: ())
            
        let data = SecKeyCreateEncryptedData(publicKey, usingAlgorithm, content, &status)
            
        if let stat = status?.takeRetainedValue(), stat.localizedDescription.isEmpty {
            return nil
        }
            
        return data
    }
    
    #if !os(macOS)
    @available(iOS, obsoleted: 10.0)
    public func decrypt(privateKey: SecKey, content: CFData, padding: SecPadding) -> CFData? {
        // Fallback on earlier versions
        
        let blockSize = getBlockSize(key: privateKey)
        var messageDecrypted = [UInt8](repeating: 0, count: blockSize)
        let messageEncryptedSize = blockSize
        var messageDecryptedSize = messageEncryptedSize
        
        var error: OSStatus
        
        let unarchive = NSKeyedUnarchiver.unarchiveObject(with: content as Data) as? Data ?? Data()
        let data = [UInt8](unarchive)
        
        error = SecKeyDecrypt(privateKey, padding, data, messageEncryptedSize, &messageDecrypted, &messageDecryptedSize)
        
        if error != noErr {
            return nil
        }
        
        let createData = NSKeyedArchiver.archivedData(withRootObject: messageDecrypted)
        
        return createData as CFData
    }
    #endif
    
    @available(iOS 10.0, macOS 10.12, watchOS 3.0, *)
    public func decrypt(privateKey: SecKey, content: CFData, usingAlgorithm: SecKeyAlgorithm) -> CFData? {
        //Decrypt the entrypted string with the private key
        var status = Unmanaged<CFError>?.init(nilLiteral: ())
        
        let decrypted = SecKeyCreateDecryptedData(privateKey, usingAlgorithm, content, &status)
            
        if let stat = status?.takeRetainedValue(), stat.localizedDescription.isEmpty {
            return nil
        }
                    
        return decrypted
    }
    
}
