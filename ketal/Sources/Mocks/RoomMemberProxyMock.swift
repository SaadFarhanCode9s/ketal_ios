//
// Copyright 2025 Element Creations Ltd.
// Copyright 2023-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation
import MatrixRustSDK

struct RoomMemberProxyMockConfiguration {
    var userID: String
    var displayName: String?
    var avatarURL: URL?
    
    var membership: MembershipState
    var isIgnored = false
    
    var powerLevel = RoomPowerLevel(value: 0)
}

extension RoomMemberProxyMock {
    convenience init(with configuration: RoomMemberProxyMockConfiguration) {
        self.init()
        userID = configuration.userID
        displayName = configuration.displayName
        
        if let displayName = configuration.displayName {
            disambiguatedDisplayName = "\(displayName) (\(userID))"
        }
        
        avatarURL = configuration.avatarURL
        
        membership = configuration.membership
        isIgnored = configuration.isIgnored
        
        powerLevel = configuration.powerLevel
    }

    /// Mocks
    static var mockMe: RoomMemberProxyMock {
        RoomMemberProxyMock(with: .init(userID: "@me:ketals.online",
                                        displayName: "Me",
                                        avatarURL: .mockMXCUserAvatar,
                                        membership: .join))
    }
    
    static var mockMeAdmin: RoomMemberProxyMock {
        RoomMemberProxyMock(with: .init(userID: "@me:ketals.online",
                                        displayName: "Me",
                                        avatarURL: .mockMXCUserAvatar,
                                        membership: .join,
                                        powerLevel: .init(value: 100)))
    }
    
    static var mockMeCreator: RoomMemberProxyMock {
        RoomMemberProxyMock(with: .init(userID: "@me:ketals.online",
                                        displayName: "Me",
                                        avatarURL: .mockMXCUserAvatar,
                                        membership: .join,
                                        powerLevel: .infinite))
    }
    
    static var mockAlice: RoomMemberProxyMock {
        RoomMemberProxyMock(with: .init(userID: "@alice:ketals.online",
                                        displayName: "Alice",
                                        membership: .join))
    }
    
    static var mockInvitedAlice: RoomMemberProxyMock {
        RoomMemberProxyMock(with: .init(userID: "@alice:ketals.online",
                                        displayName: "Alice",
                                        membership: .invite))
    }

    static var mockBob: RoomMemberProxyMock {
        RoomMemberProxyMock(with: .init(userID: "@bob:ketals.online",
                                        displayName: "Bob",
                                        membership: .join))
    }

    static var mockCharlie: RoomMemberProxyMock {
        RoomMemberProxyMock(with: .init(userID: "@charlie:ketals.online",
                                        displayName: "Charlie",
                                        membership: .join))
    }

    static var mockDan: RoomMemberProxyMock {
        RoomMemberProxyMock(with: .init(userID: "@dan:ketals.online",
                                        displayName: "Dan",
                                        avatarURL: .mockMXCUserAvatar,
                                        membership: .join))
    }
    
    static var mockVerbose: RoomMemberProxyMock {
        RoomMemberProxyMock(with: .init(userID: "@charliev:ketals.online",
                                        displayName: "Charlie is the best display name",
                                        membership: .join))
    }
    
    static var mockNoName: RoomMemberProxyMock {
        RoomMemberProxyMock(with: .init(userID: "@anonymous:ketals.online",
                                        membership: .join))
    }
    
    static var mockInvited: RoomMemberProxyMock {
        RoomMemberProxyMock(with: .init(userID: "@invited:ketals.online",
                                        displayName: "Invited",
                                        membership: .invite,
                                        isIgnored: true))
    }

    static var mockIgnored: RoomMemberProxyMock {
        RoomMemberProxyMock(with: .init(userID: "@ignored:ketals.online",
                                        displayName: "Ignored",
                                        membership: .join,
                                        isIgnored: true))
    }
    
    static var mockAdmin: RoomMemberProxyMock {
        RoomMemberProxyMock(with: .init(userID: "@admin:ketals.online",
                                        displayName: "Arthur",
                                        membership: .join,
                                        powerLevel: .init(value: 100)))
    }
    
    static var mockCreator: RoomMemberProxyMock {
        RoomMemberProxyMock(with: .init(userID: "@creator:ketals.online",
                                        displayName: "God",
                                        membership: .join,
                                        powerLevel: .infinite))
    }
    
    static var mockOwner: RoomMemberProxyMock {
        RoomMemberProxyMock(with: .init(userID: "@owner:ketals.online",
                                        displayName: "Guinevere",
                                        membership: .join,
                                        powerLevel: .value(150)))
    }
    
    static var mockModerator: RoomMemberProxyMock {
        RoomMemberProxyMock(with: .init(userID: "@mod:ketals.online",
                                        displayName: "Merlin",
                                        membership: .join,
                                        powerLevel: .init(value: 50)))
    }
    
    static var mockBanned: [RoomMemberProxyMock] {
        [
            RoomMemberProxyMock(with: .init(userID: "@mischief:ketals.online",
                                            membership: .ban)),
            RoomMemberProxyMock(with: .init(userID: "@spam:ketals.online",
                                            membership: .ban)),
            RoomMemberProxyMock(with: .init(userID: "@angry:ketals.online",
                                            membership: .ban)),
            RoomMemberProxyMock(with: .init(userID: "@fake:ketals.online",
                                            displayName: "The President",
                                            membership: .ban))
        ]
    }
}

extension Array where Element == RoomMemberProxyMock {
    static let allMembers: [RoomMemberProxyMock] = [
        .mockMe,
        .mockAlice,
        .mockBob,
        .mockCharlie,
        .mockDan,
        .mockInvited,
        .mockIgnored
    ]
    
    static let allMembersAsAdmin: [RoomMemberProxyMock] = [
        .mockMeAdmin,
        .mockAlice,
        .mockBob,
        .mockCharlie,
        .mockDan,
        .mockInvited,
        .mockIgnored,
        .mockAdmin,
        .mockModerator
    ]
    
    /// This also includes the creator and the owner role.
    static let allMembersAsAdminV2: [RoomMemberProxyMock] = [
        .mockMeAdmin,
        .mockAlice,
        .mockBob,
        .mockCharlie,
        .mockDan,
        .mockInvited,
        .mockIgnored,
        .mockAdmin,
        .mockModerator,
        .mockOwner,
        .mockCreator
    ]
    
    static let allMembersAsCreator: [RoomMemberProxyMock] = [
        .mockAdmin,
        .mockAlice,
        .mockBob,
        .mockCharlie,
        .mockDan,
        .mockInvited,
        .mockIgnored,
        .mockModerator,
        .mockCreator,
        .mockMeCreator,
        .mockOwner
    ]
}
