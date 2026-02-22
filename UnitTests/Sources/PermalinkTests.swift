//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

@testable import ketal
import MatrixRustSDK
import XCTest

/// Just for API sanity checking, they're already properly tested in the SDK/Ruma
class PermalinkTests: XCTestCase {
    func testUserIdentifierPermalink() {
        let invalidUserId = "This1sN0tV4lid!@#$%^&*()"
        XCTAssertNil(try? matrixToUserPermalink(userId: invalidUserId))
        
        let validUserId = "@abcdefghijklmnopqrstuvwxyz1234567890._-=/:ketals.online"
        XCTAssertEqual(try? matrixToUserPermalink(userId: validUserId), .some("https://ketals.online/#/@abcdefghijklmnopqrstuvwxyz1234567890._-=%2F:ketals.online"))
    }
    
    func testPermalinkDetection() {
        var url: URL = "https://www.ketals.online"
        XCTAssertNil(parseMatrixEntityFrom(uri: url.absoluteString))
        
        url = "https://ketals.online/#/@bob:ketals.online?via=ketals.online"
        XCTAssertEqual(parseMatrixEntityFrom(uri: url.absoluteString),
                       MatrixEntity(id: .user(id: "@bob:ketals.online"),
                                    via: ["ketals.online"]))
        
        url = "https://ketals.online/#/!roomidentifier:ketals.online?via=ketals.online"
        XCTAssertEqual(parseMatrixEntityFrom(uri: url.absoluteString),
                       MatrixEntity(id: .room(id: "!roomidentifier:ketals.online"),
                                    via: ["ketals.online"]))
        
        url = "https://ketals.online/#/%23roomalias:ketals.online?via=ketals.online"
        XCTAssertEqual(parseMatrixEntityFrom(uri: url.absoluteString),
                       MatrixEntity(id: .roomAlias(alias: "#roomalias:ketals.online"),
                                    via: ["ketals.online"]))
        
        url = "https://ketals.online/#/!roomidentifier:ketals.online/$eventidentifier?via=ketals.online"
        XCTAssertEqual(parseMatrixEntityFrom(uri: url.absoluteString),
                       MatrixEntity(id: .eventOnRoomId(roomId: "!roomidentifier:ketals.online", eventId: "$eventidentifier"),
                                    via: ["ketals.online"]))
        
        url = "https://ketals.online/#/#roomalias:ketals.online/$eventidentifier?via=ketals.online"
        XCTAssertEqual(parseMatrixEntityFrom(uri: url.absoluteString),
                       MatrixEntity(id: .eventOnRoomAlias(alias: "#roomalias:ketals.online", eventId: "$eventidentifier"),
                                    via: ["ketals.online"]))
    }
}
