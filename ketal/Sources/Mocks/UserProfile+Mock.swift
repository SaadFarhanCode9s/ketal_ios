//
// Copyright 2025 Element Creations Ltd.
// Copyright 2023-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

extension UserProfileProxy {
    /// Mocks
    static var mockAlice: UserProfileProxy {
        .init(userID: "@alice:ketals.online", displayName: "Alice", avatarURL: "mxc://ketals.online/UcCimidcvpFvWkPzvjXMQPHA")
    }

    static var mockBob: UserProfileProxy {
        .init(userID: "@bob:ketals.online", displayName: "Bob", avatarURL: nil)
    }

    static var mockBobby: UserProfileProxy {
        .init(userID: "@bobby:ketals.online", displayName: "Bobby", avatarURL: nil)
    }

    static var mockCharlie: UserProfileProxy {
        .init(userID: "@charlie:ketals.online", displayName: "Charlie", avatarURL: nil)
    }
    
    static var mockDan: UserProfileProxy {
        .init(userID: "@dan:ketals.online", displayName: "Dan", avatarURL: .mockMXCUserAvatar)
    }
    
    static var mockVerbose: UserProfileProxy {
        .init(userID: "@charlie:ketals.online", displayName: "Charlie is the best display name", avatarURL: nil)
    }
}
