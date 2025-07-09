// Design Tokens - Adaptive Colors
// Auto-generated on 7/9/2025 - Do not edit manually
// These colors automatically adapt to light/dark mode using iOS's built-in appearance system

import UIKit

extension UIColor {

    // MARK: - Adaptive Design System Colors


    /// Light: {Neutral.Solid.96W} → #f5f5f5, Dark: {Neutral.Solid.08B} → #141414
    static let solidZ1 = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.078, green: 0.078, blue: 0.078, alpha: 1.0)
            : UIColor(red: 0.961, green: 0.961, blue: 0.961, alpha: 1.0)
    }


    /// Light: {Neutral.Solid.100W} → #ffffff, Dark: {Neutral.Solid.04B} → #0a0a0a
    static let solidZ0 = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.039, green: 0.039, blue: 0.039, alpha: 1.0)
            : UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.0)
    }


    /// Light: {Neutral.Solid.90W} → #e5e5e5, Dark: {Neutral.Solid.12B} → #1f1f1f
    static let solidZ2 = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.122, green: 0.122, blue: 0.122, alpha: 1.0)
            : UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1.0)
    }


    /// Light: {Neutral.Solid.16W} → #292929, Dark: {Neutral.Solid.70B} → #b2b2b2
    static let solidZ6 = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.698, green: 0.698, blue: 0.698, alpha: 1.0)
            : UIColor(red: 0.161, green: 0.161, blue: 0.161, alpha: 1.0)
    }


    /// Light: {Neutral.Solid.88W} → #e0e0e0, Dark: {Neutral.Solid.20B} → #333333
    static let solidZ3 = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.200, green: 0.200, blue: 0.200, alpha: 1.0)
            : UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1.0)
    }


    /// Light: {Neutral.Solid.72W} → #b8b8b8, Dark: {Neutral.Solid.24B} → #3d3d3d
    static let solidZ4 = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.239, green: 0.239, blue: 0.239, alpha: 1.0)
            : UIColor(red: 0.722, green: 0.722, blue: 0.722, alpha: 1.0)
    }


    /// Light: {Neutral.Solid.40W} → #666666, Dark: {Neutral.Solid.50B} → #808080
    static let solidZ5 = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.502, green: 0.502, blue: 0.502, alpha: 1.0)
            : UIColor(red: 0.400, green: 0.400, blue: 0.400, alpha: 1.0)
    }


    /// Light: {Neutral.Solid.04W} → #0a0a0a, Dark: {Neutral.Solid.100B} → #ffffff
    static let solidZ7 = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.0)
            : UIColor(red: 0.039, green: 0.039, blue: 0.039, alpha: 1.0)
    }


    static let onsurfaceOnsurfaceinverse = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(named: "{Solid.Z0}") ?? .systemBackground
            : UIColor(named: "{Solid.Z0}") ?? .systemBackground
    }


    static let onsurfaceOnsurfacesecondary = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(named: "{Solid.Z6}") ?? .systemBackground
            : UIColor(named: "{Solid.Z5}") ?? .systemBackground
    }


    static let onsurfaceOnsurfacetertiary = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.247, green: 0.247, blue: 0.247, alpha: 1.0)
            : UIColor(red: 0.600, green: 0.600, blue: 0.600, alpha: 1.0)
    }


    static let onsurfaceOnsurfaceprimary = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(named: "{Solid.Z7}") ?? .systemBackground
            : UIColor(named: "{Solid.Z7}") ?? .systemBackground
    }


    /// Light: {Archive.Overlay.Dark.20%} → #00000033, Dark: {Archive.Overlay.Dark.20%} → #00000033
    static let interactHover = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.0)
            : UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.0)
    }


    static let accentsPurple = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.667, green: 0.631, blue: 0.949, alpha: 1.0)
            : UIColor(red: 0.667, green: 0.631, blue: 0.945, alpha: 1.0)
    }


    static let accentsYellow = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.000, green: 0.937, blue: 0.384, alpha: 1.0)
            : UIColor(red: 1.000, green: 0.937, blue: 0.384, alpha: 1.0)
    }


    static let accentsOrange = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.000, green: 0.620, blue: 0.620, alpha: 1.0)
            : UIColor(red: 1.000, green: 0.620, blue: 0.620, alpha: 1.0)
    }


    static let accentsBlue = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.388, green: 0.557, blue: 1.000, alpha: 1.0)
            : UIColor(red: 0.388, green: 0.557, blue: 1.000, alpha: 1.0)
    }


    static let accentsGreen = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.478, green: 0.816, blue: 0.522, alpha: 1.0)
            : UIColor(red: 0.478, green: 0.816, blue: 0.522, alpha: 1.0)
    }


    static let accentsPink = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.000, green: 0.408, blue: 0.690, alpha: 1.0)
            : UIColor(red: 1.000, green: 0.408, blue: 0.690, alpha: 1.0)
    }


    /// Light: {Archive.Dark 600} → #616161, Dark: {Archive.Dark 600} → #616161
    static let onaccentsurfacesecondary = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.380, green: 0.380, blue: 0.380, alpha: 1.0)
            : UIColor(red: 0.380, green: 0.380, blue: 0.380, alpha: 1.0)
    }


    /// Light: {Archive.Red 500} → #ff0000, Dark: {Archive.Red 500} → #ff0000
    static let alertCritical = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.000, green: 0.000, blue: 0.000, alpha: 1.0)
            : UIColor(red: 1.000, green: 0.000, blue: 0.000, alpha: 1.0)
    }


    /// Light: {Archive.Dark 900} → #111111, Dark: {Archive.Dark 900} → #111111
    static let onaccentsurfaceprimary = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.067, green: 0.067, blue: 0.067, alpha: 1.0)
            : UIColor(red: 0.067, green: 0.067, blue: 0.067, alpha: 1.0)
    }


    /// Light: {Neutral.Transparent.4B} → #0000000a, Dark: {Neutral.Transparent.04W} → #ffffff0a
    static let transparentT1 = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.0)
            : UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.0)
    }


    /// Light: {Neutral.Transparent.8B} → #00000014, Dark: {Neutral.Transparent.08W} → #ffffff17
    static let transparentT2 = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.0)
            : UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.0)
    }


    /// Light: {Neutral.Transparent.12B} → #0000001f, Dark: {Neutral.Transparent.16W} → #ffffff2b
    static let transparentT3 = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.0)
            : UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.0)
    }


    /// Light: {Neutral.Transparent.28B} → #00000047, Dark: {Neutral.Transparent.20W} → #ffffff36
    static let transparentT4 = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.0)
            : UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.0)
    }


    /// Light: {Neutral.Transparent.64B} → #00000099, Dark: {Neutral.Transparent.48W} → #ffffff7a
    static let transparentT5 = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.0)
            : UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.0)
    }


    /// Light: {Neutral.Transparent.84B} → #000000d6, Dark: {Neutral.Transparent.68W} → #ffffffb0
    static let transparentT6 = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.0)
            : UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.0)
    }


    /// Light: {Neutral.Transparent.100B} → #000000, Dark: {Neutral.Transparent.100W} → #ffffff
    static let transparentT7 = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.0)
            : UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.0)
    }

}

// MARK: - Usage Example
/*
// These colors automatically adapt to light/dark mode:

// Set background color (automatically switches between light/dark)
view.backgroundColor = .solidZ0

// Set text color (automatically adapts)
label.textColor = .onSurfacePrimary

// In SwiftUI, convert to SwiftUI Color:
Color(UIColor.solidZ0)

// The system automatically chooses the appropriate color based on:
// - Current appearance (light/dark)
// - User's system setting
// - App's overrideUserInterfaceStyle setting
*/