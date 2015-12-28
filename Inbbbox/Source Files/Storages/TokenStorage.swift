//
//  TokenStorage.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 14/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import KeychainAccess

final class TokenStorage {
    
    private static let KeychainService = "co.netguru.inbbbox.keychain.token"
    private static let keychain = Keychain(service: KeychainService)
    
    class var currentToken: String {
        return keychain[Key.Token.rawValue] ?? ""
    }
    
    class func storeToken(token: String) {
        keychain[Key.Token.rawValue] = token
    }
    
    class func clear() {
        keychain[Key.Token.rawValue] = nil
    }
    
    private enum Key: String {
        case Token = "co.netguru.inbbbox.keychain.token.key"
    }
}