//
//  GeneralSettingsManager.swift
//  OpenMenu
//

import Combine
import Foundation

@MainActor
final class GeneralSettingsManager: ObservableObject {
    /// A Boolean value that indicates whether the OpenMenu icon
    /// should be shown.
    @Published var showOpenMenuIcon = true

    /// An icon to show in the menu bar, with a different image
    /// for when items are visible or hidden.
    @Published var openMenuIcon: ControlItemImageSet = .defaultOpenMenuIcon

    /// The last user-selected custom OpenMenu icon.
    @Published var lastCustomOpenMenuIcon: ControlItemImageSet?

    /// A Boolean value that indicates whether custom OpenMenu icons
    /// should be rendered as template images.
    @Published var customOpenMenuIconIsTemplate = false

    /// A Boolean value that indicates whether to show hidden items
    /// in a separate bar below the menu bar.
    @Published var useOpenMenuBar = false

    /// The location where the OpenMenu Bar appears.
    @Published var openMenuBarLocation: OpenMenuBarLocation = .dynamic

    /// A Boolean value that indicates whether the hidden section
    /// should be shown when the mouse pointer clicks in an empty
    /// area of the menu bar.
    @Published var showOnClick = true

    /// A Boolean value that indicates whether the hidden section
    /// should be shown when the mouse pointer hovers over an
    /// empty area of the menu bar.
    @Published var showOnHover = false

    /// A Boolean value that indicates whether the hidden section
    /// should be shown or hidden when the user scrolls in the
    /// menu bar.
    @Published var showOnScroll = true

    /// The offset to apply to the menu bar item spacing and padding.
    @Published var itemSpacingOffset: Double = 0

    /// A Boolean value that indicates whether the hidden section
    /// should automatically rehide.
    @Published var autoRehide = true

    /// A strategy that determines how the auto-rehide feature works.
    @Published var rehideStrategy: RehideStrategy = .smart

    /// A time interval for the auto-rehide feature when its rule
    /// is ``RehideStrategy/timed``.
    @Published var rehideInterval: TimeInterval = 15

    /// Encoder for properties.
    private let encoder = JSONEncoder()

    /// Decoder for properties.
    private let decoder = JSONDecoder()

    /// Storage for internal observers.
    private var cancellables = Set<AnyCancellable>()

    /// The shared app state.
    private(set) weak var appState: AppState?

    init(appState: AppState) {
        self.appState = appState
    }

    func performSetup() {
        loadInitialState()
        configureCancellables()
    }

    private func loadInitialState() {
        Defaults.ifPresent(key: .showOpenMenuIcon, assign: &showOpenMenuIcon)
        Defaults.ifPresent(key: .customOpenMenuIconIsTemplate, assign: &customOpenMenuIconIsTemplate)
        Defaults.ifPresent(key: .useOpenMenuBar, assign: &useOpenMenuBar)
        Defaults.ifPresent(key: .showOnClick, assign: &showOnClick)
        Defaults.ifPresent(key: .showOnHover, assign: &showOnHover)
        Defaults.ifPresent(key: .showOnScroll, assign: &showOnScroll)
        Defaults.ifPresent(key: .itemSpacingOffset, assign: &itemSpacingOffset)
        Defaults.ifPresent(key: .autoRehide, assign: &autoRehide)
        Defaults.ifPresent(key: .rehideInterval, assign: &rehideInterval)

        Defaults.ifPresent(key: .openMenuBarLocation) { rawValue in
            if let location = OpenMenuBarLocation(rawValue: rawValue) {
                openMenuBarLocation = location
            }
        }
        Defaults.ifPresent(key: .rehideStrategy) { rawValue in
            if let strategy = RehideStrategy(rawValue: rawValue) {
                rehideStrategy = strategy
            }
        }

        if let data = Defaults.data(forKey: .openMenuIcon) {
            do {
                openMenuIcon = try decoder.decode(ControlItemImageSet.self, from: data)
            } catch {
                Logger.generalSettingsManager.error("Error decoding OpenMenu icon: \(error)")
            }
            if case .custom = openMenuIcon.name {
                lastCustomOpenMenuIcon = openMenuIcon
            }
        }
    }

    private func configureCancellables() {
        var c = Set<AnyCancellable>()

        $showOpenMenuIcon
            .receive(on: DispatchQueue.main)
            .sink { showOpenMenuIcon in
                Defaults.set(showOpenMenuIcon, forKey: .showOpenMenuIcon)
            }
            .store(in: &c)

        $openMenuIcon
            .receive(on: DispatchQueue.main)
            .sink { [weak self] openMenuIcon in
                guard let self else {
                    return
                }
                if case .custom = openMenuIcon.name {
                    lastCustomOpenMenuIcon = openMenuIcon
                }
                do {
                    let data = try encoder.encode(openMenuIcon)
                    Defaults.set(data, forKey: .openMenuIcon)
                } catch {
                    Logger.generalSettingsManager.error("Error encoding OpenMenu icon: \(error)")
                }
            }
            .store(in: &c)

        $customOpenMenuIconIsTemplate
            .receive(on: DispatchQueue.main)
            .sink { isTemplate in
                Defaults.set(isTemplate, forKey: .customOpenMenuIconIsTemplate)
            }
            .store(in: &c)

        $useOpenMenuBar
            .receive(on: DispatchQueue.main)
            .sink { useOpenMenuBar in
                Defaults.set(useOpenMenuBar, forKey: .useOpenMenuBar)
            }
            .store(in: &c)

        $openMenuBarLocation
            .receive(on: DispatchQueue.main)
            .sink { location in
                Defaults.set(location.rawValue, forKey: .openMenuBarLocation)
            }
            .store(in: &c)

        $showOnClick
            .receive(on: DispatchQueue.main)
            .sink { showOnClick in
                Defaults.set(showOnClick, forKey: .showOnClick)
            }
            .store(in: &c)

        $showOnHover
            .receive(on: DispatchQueue.main)
            .sink { showOnHover in
                Defaults.set(showOnHover, forKey: .showOnHover)
            }
            .store(in: &c)

        $showOnScroll
            .receive(on: DispatchQueue.main)
            .sink { showOnScroll in
                Defaults.set(showOnScroll, forKey: .showOnScroll)
            }
            .store(in: &c)

        $itemSpacingOffset
            .receive(on: DispatchQueue.main)
            .sink { [weak appState] offset in
                Defaults.set(offset, forKey: .itemSpacingOffset)
                appState?.spacingManager.offset = Int(offset)
            }
            .store(in: &c)

        $autoRehide
            .receive(on: DispatchQueue.main)
            .sink { autoRehide in
                Defaults.set(autoRehide, forKey: .autoRehide)
            }
            .store(in: &c)

        $rehideStrategy
            .receive(on: DispatchQueue.main)
            .sink { strategy in
                Defaults.set(strategy.rawValue, forKey: .rehideStrategy)
            }
            .store(in: &c)

        $rehideInterval
            .receive(on: DispatchQueue.main)
            .sink { interval in
                Defaults.set(interval, forKey: .rehideInterval)
            }
            .store(in: &c)

        cancellables = c
    }
}

// MARK: GeneralSettingsManager: BindingExposable
extension GeneralSettingsManager: BindingExposable { }

// MARK: - Logger
private extension Logger {
    static let generalSettingsManager = Logger(category: "GeneralSettingsManager")
}
