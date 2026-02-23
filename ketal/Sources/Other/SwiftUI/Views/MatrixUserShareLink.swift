//
// Copyright 2025 Element Creations Ltd.
// Copyright 2023-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import MatrixRustSDK
import SwiftUI

struct MatrixUserShareLink<Label: View>: View {
    private let permalink: URL?
    private let label: Label
    
    init(userID: String, @ViewBuilder label: () -> Label) {
        self.label = label()
        if let rawPermalink = try? matrixToUserPermalink(userId: userID) {
            permalink = URL(string: rawPermalink.replacingOccurrences(of: "matrix.to", with: "element.ketals.online"))
        } else {
            permalink = nil
        }
    }
    
    var body: some View {
        if let permalink {
            ShareLink(
                item: permalink,
                subject: Text(L10n.inviteFriendsText(InfoPlistReader.main.bundleDisplayName, permalink.absoluteString)),
                message: Text(L10n.inviteFriendsText(InfoPlistReader.main.bundleDisplayName, permalink.absoluteString)),
                preview: SharePreview("Ketal", image: Image("KetalLogo"))
            ) {
                label
            }
        }
    }
}

struct MatrixUserPermalink_Previews: PreviewProvider, TestablePreview {
    static var previews: some View {
        MatrixUserShareLink(userID: "@someone:somewhere.org") {
            Label("Share", icon: \.shareIos)
        }
    }
}
