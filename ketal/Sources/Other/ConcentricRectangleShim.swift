//
// Copyright 2025 Ketal.
//
// Shim for missing ConcentricRectangle type which appears to be anticipated in future Compound versions
// or exists in a specific branch not currently present.
// Since usage is guarded by `if #available(iOS 26, *)`, this code is unreachable on current devices.
//

import SwiftUI

struct ConcentricRectangle: Shape {
    struct Corners {
        static func concentric(minimum: CGFloat) -> Corners {
            return Corners()
        }
    }

    init(corners: Corners) {}

    func path(in rect: CGRect) -> Path {
        // Return a basic rectangle path since this code shouldn't execute
        return Path(roundedRect: rect, cornerRadius: 0)
    }
}
