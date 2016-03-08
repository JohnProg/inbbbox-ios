//
//  ManagedBucketsRequester.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/23/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit
import CoreData
import SwiftyJSON

class ManagedBucketsRequester {
    
    let managedObjectContext: NSManagedObjectContext
    let managedObjectsProvider: ManagedObjectsProvider
    
    init() {
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        managedObjectsProvider = ManagedObjectsProvider(managedObjectContext: managedObjectContext)
    }
    
    func addBucket(name: String, description: NSAttributedString?) -> Promise<BucketType> {
        
        var identifier: String
        do {
            let fetchRequest = NSFetchRequest(entityName: ManagedBucket.entityName)
            let managedBuckets = try managedObjectContext.executeFetchRequest(fetchRequest) as! [ManagedBucket]
            identifier = (managedBuckets.count+1).stringValue
        } catch {
            return Promise(error: error)
        }

        let bucket = Bucket(
            identifier: identifier,
            name: name,
            attributedDescription: description,
            shotsCount: 0,
            createdAt: NSDate(),
            owner: User(json: guestJSON))
        
        
        let managedBucket = managedObjectsProvider.managedBucket(bucket)
        
        return Promise<BucketType> { fulfill, reject in
            do {
                try managedObjectContext.save()
                fulfill(managedBucket)
            } catch {
                reject(error)
            }
        }
    }
    
    func addShot(shot: ShotType, toBucket bucket: BucketType) -> Promise<Void> {
        let managedBucket = managedObjectsProvider.managedBucket(bucket)
        let managedShot = managedObjectsProvider.managedShot(shot)
        if let managedShots = managedBucket.shots {
            managedShots.setByAddingObject(managedShot)
        } else {
            managedBucket.shots = NSSet(object: managedShot)
        }
        return Promise<Void> { fulfill, reject in
            do {
                fulfill(try managedObjectContext.save())
            } catch {
                reject(error)
            }
        }
    }

    func removeShot(shot: ShotType, fromBucket bucket: BucketType) -> Promise<Void> {

        let managedBucket = managedObjectsProvider.managedBucket(bucket)
        let managedShot = managedObjectsProvider.managedShot(shot)
        if let managedShots = managedBucket.shots{
            let mutableShots = NSMutableSet(set: managedShots)
            mutableShots.removeObject(managedShot)
            managedBucket.shots = mutableShots.copy() as? NSSet
        }
        return Promise<Void> { fulfill, reject in
            do {
                fulfill(try managedObjectContext.save())
            } catch {
                reject(error)
            }
        }
    }
}

var guestJSON: JSON {
    let guestString = "{\"id\" : \"guest.identifier\"" +
        "\"name\" : \"guest.name\"," +
        "\"username\" : \"guest.username\"," +
        "\"avatar_url\" : \"guest.avatar.url\"," +
        "\"shots_count\" : 0," +
        "\"param_to_omit\" : \"guest.param\"," +
        "\"type\" : \"User\"" +
        "}"
    return JSON.parse(guestString)
}
