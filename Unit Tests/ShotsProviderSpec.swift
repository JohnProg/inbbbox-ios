//
//  ShotsProviderSpec.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 3/1/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import Dobby
import PromiseKit
import CoreData

@testable import Inbbbox

class ShotsProviderSpec: QuickSpec {

    override func spec() {

        var sut: ShotsProvider!

        beforeEach {
            sut = ShotsProvider()
        }

        afterEach {
            sut = nil
        }

        it("should have api shots provider") {
            expect(sut.apiShotsProvider).toNot(beNil())
        }

        it("should have managed shots provider") {
            expect(sut.managedShotsProvider).toNot(beNil())
        }

        it("should have user storage class") {
            expect(sut.userStorageClass).toNot(beNil())
        }

        describe("provide my liked shots") {

            var likedShots: [ShotType]!

            context("when user is not signed in") {

                var inMemoryManagedObjectContext: NSManagedObjectContext!

                beforeEach {
                    inMemoryManagedObjectContext = setUpInMemoryManagedObjectContext()
                    let managedShotsProviderMock = ManagedShotsProviderMock()
                    let managedObjectsProvider = ManagedObjectsProvider(managedObjectContext: inMemoryManagedObjectContext)
                    let managedShot = managedObjectsProvider.managedShot(Shot.fixtureShotWithIdentifier("fixture managed shot identifier"))
                    let likedManagedShot = LikedShot(likeIdentifier: "", createdAt: Date(), shot: managedShot)
                    managedShotsProviderMock.provideLikedShotsStub.on(any(), return: Promise<[LikedShot]?> { fulfill, _ in fulfill([likedManagedShot]) })
                    sut.managedShotsProvider = managedShotsProviderMock

                    firstly {
                        sut.provideMyLikedShots()
                    }.then { shots in
                        likedShots = shots?.map({ $0.shot })
                    }.catch { error in
                        print(error)
                    }
                }

                it("should return proper shots") {
                    expect(likedShots.count).toEventually(equal(1))
                    let firstShot = likedShots[0]
                    expect(firstShot.identifier).toEventually(equal("fixture managed shot identifier"))
                }
            }

            context("when user is signed in") {

                beforeEach {
                    let userStorageClassMock = UserStorageMock.self
                    userStorageClassMock.userIsSignedInStub.on(any(), return: true)
                    sut.userStorageClass = userStorageClassMock

                    let apiShotsProviderMock = APILikedShotsProviderMock()
                    let apiShot = Shot.fixtureShotWithIdentifier("fixture api shot identifier")
                    let likedApiShot = LikedShot(likeIdentifier: "", createdAt: Date(), shot: apiShot)
                    apiShotsProviderMock.provideLikedShotsStub.on(any(), return: Promise<[LikedShot]?> { fulfill, _ in fulfill([likedApiShot]) })
                    sut.apiLikedShotsProvider = apiShotsProviderMock
                }

                it("should return proper shots") {

                    waitUntil { done in
                        firstly {
                            sut.provideMyLikedShots()
                        }.then { shots -> Void in
                            likedShots = shots?.map({ $0.shot })
                            done()
                        }.catch { _ in }
                    }

                    expect(likedShots.count).toEventually(equal(1))
                    let firstShot = likedShots[0]
                    expect(firstShot.identifier).toEventually(equal("fixture api shot identifier"))
                }
            }
        }
    }
}
