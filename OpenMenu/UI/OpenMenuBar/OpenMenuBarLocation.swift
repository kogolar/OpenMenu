//
//  OpenMenuBarLocation.swift
//  OpenMenu
//

import SwiftUI

/// Locations where the OpenMenu Bar can appear.
enum OpenMenuBarLocation: Int, CaseIterable, Identifiable {
    /// The OpenMenu Bar will appear in different locations based on context.
    case dynamic = 0

    /// The OpenMenu Bar will appear centered below the mouse pointer.
    case mousePointer = 1

    /// The OpenMenu Bar will appear centered below the OpenMenu icon.
    case openMenuIcon = 2

    var id: Int { rawValue }

    /// Localized string key representation.
    var localized: LocalizedStringKey {
        switch self {
        case .dynamic: "Dynamic"
        case .mousePointer: "Mouse pointer"
        case .openMenuIcon: "OpenMenu icon"
        }
    }
}
