//
//  RemoveFromBucketQuery.swift
//  Inbbbox
//
//  Created by Peter Bruz on 08/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct RemoveFromBucketQuery: Query {
    
    let method = Method.DELETE
    let path: String
    let service: SecureNetworkService = DribbbleNetworkService()
    var parameters = Parameters(encoding: .JSON)
    
    init(shotID: Int, bucketID: Int) {
        path = "/buckets/" + bucketID.stringValue + "/shots"
        parameters["shot_id"] = shotID
    }
}