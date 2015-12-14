//
//  DribbbleNetworkService.swift
//  Tindddler
//
//  Created by Radoslaw Szeja on 14/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct DribbbleNetworkService: SecureNetworkService, HeaderAuthorizable {
    
    let host = "api.dribbble.com/v1/"
    
    func authorizeRequest(request: NSMutableURLRequest) {
        let header = authorizationHeader(TokenStorage.currentToken)
        request.setHeader(header)
    }
}

extension NSMutableURLRequest {
    func setHeader(header: HTTPHeader) {
        setValue(header.value, forHTTPHeaderField: header.name)
    }
}