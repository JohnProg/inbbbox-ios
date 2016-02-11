//
//  UpdateCommentQuerySpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 11/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import Inbbbox

class UpdateCommentQuerySpec: QuickSpec {
    override func spec() {

        SharedQuerySpec.performSpecForQuery( { Void -> Query in
            return UpdateCommentQuery(shot: Shot.fixtureShot(), comment:  Comment.fixtureComment())
        }) { Void -> QueryExpectation in
            return (method: .PUT, encoding: .URL, path: "/shots/fixture.identifier/comments/fixture.identifier")
        }
        
        describe("when newly initialized with shot") {
            
            var sut: UpdateCommentQuery!
            
            beforeEach {
                sut = UpdateCommentQuery(shot: Shot.fixtureShot(), comment:  Comment.fixtureComment())
            }
            
            afterEach {
                sut = nil
            }
            
            it("should have empty parameters") {
                expect(sut.parameters.queryItems).to(beEmpty())
            }
        }
    }
}
