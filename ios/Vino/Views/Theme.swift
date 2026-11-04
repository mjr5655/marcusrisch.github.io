import SwiftUI
import UIKit

/// Dark navy + gold "wine bar" look.
enum Theme {
    // Surfaces
    static let navy = Color(red: 0.043, green: 0.078, blue: 0.149)       // app background
    static let surface = Color(red: 0.078, green: 0.125, blue: 0.231)    // cards / rows
    static let surfaceHigh = Color(red: 0.110, green: 0.165, blue: 0.290) // raised elements
    static let hairline = Color(red: 0.83, green: 0.69, blue: 0.34).opacity(0.18)

    // Accents
    static let gold = Color(red: 0.83, green: 0.69, blue: 0.34)
    static let goldSoft = Color(red: 0.94, green: 0.84, blue: 0.55)
    static let cream = Color(red: 0.95, green: 0.92, blue: 0.86)
    static let wine = Color(red: 0.66, green: 0.19, blue: 0.31)

    static func uiColor(_ c: Color) -> UIColor { UIColor(c) }

    static func uiSerif(size: CGFloat, weight: UIFont.Weight = .semibold) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        if let descriptor = base.fontDescriptor.withDesign(.serif) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return base
    }

    /// Styles UIKit-backed chrome (navigation bar, tab bar, segmented control).
    static func applyAppearance() {
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = UIColor(navy)
        nav.shadowColor = .clear
        nav.titleTextAttributes = [.foregroundColor: UIColor(cream), .font: uiSerif(size: 17)]
        nav.largeTitleTextAttributes = [.foregroundColor: UIColor(gold), .font: uiSerif(size: 34, weight: .bold)]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav

        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = UIColor(surface)
        tab.shadowColor = UIColor(hairline)
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab

        let segmented = UISegmentedControl.appearance()
        segmented.selectedSegmentTintColor = UIColor(gold)
        segmented.backgroundColor = UIColor(surface)
        segmented.setTitleTextAttributes([.foregroundColor: UIColor(navy)], for: .selected)
        segmented.setTitleTextAttributes([.foregroundColor: UIColor(cream)], for: .normal)
    }
}

// MARK: - Fonts

extension Font {
    /// Serif display font used for titles and wine names.
    static func serif(_ style: Font.TextStyle, weight: Font.Weight = .semibold) -> Font {
        .system(style, design: .serif, weight: weight)
    }
}

// MARK: - Wine style colors

extension WineStyle {
    var color: Color {
        switch self {
        case .red: return Color(red: 0.78, green: 0.27, blue: 0.38)
        case .white: return Color(red: 0.92, green: 0.83, blue: 0.50)
        case .rose: return Color(red: 0.93, green: 0.60, blue: 0.67)
        case .sparkling: return Color(red: 0.72, green: 0.85, blue: 0.95)
        case .dessert: return Color(red: 0.90, green: 0.64, blue: 0.33)
        case .orange: return Color(red: 0.89, green: 0.53, blue: 0.24)
        }
    }
}

// MARK: - Modifiers

extension View {
    /// Navy background for List / Form screens.
    func vinoScreen() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Theme.navy.ignoresSafeArea())
    }

    /// Card-colored list rows with gold hairline separators. Apply to a `Section`.
    func vinoRows() -> some View {
        self
            .listRowBackground(Theme.surface)
            .listRowSeparatorTint(Theme.hairline)
    }
}

// MARK: - Buttons

struct GoldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.navy)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Theme.gold.opacity(configuration.isPressed ? 0.8 : 1), in: Capsule())
    }
}

struct OutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.gold)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .overlay(Capsule().strokeBorder(Theme.gold.opacity(configuration.isPressed ? 0.5 : 0.9), lineWidth: 1))
    }
}

/// Small pill showing a wine style, tinted by style color.
struct StyleChip: View {
    let style: WineStyle

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: style.symbol).font(.caption2)
            Text(style.rawValue).font(.caption2.weight(.semibold))
        }
        .foregroundStyle(style.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(style.color.opacity(0.15), in: Capsule())
        .accessibilityElement(children: .combine)
    }
}
