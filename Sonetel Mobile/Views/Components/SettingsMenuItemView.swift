//
//  SettingsMenuItemView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct SettingsMenuItemView: View {
    let title: String
    let value: String?
    let hasChevron: Bool
    let isDestructive: Bool
    let icon: String?
    let action: () -> Void

    @State private var isPressed = false

    init(title: String, value: String? = nil, hasChevron: Bool = true, isDestructive: Bool = false, icon: String? = nil, action: @escaping () -> Void = {}) {
        self.title = title
        self.value = value
        self.hasChevron = hasChevron
        self.isDestructive = isDestructive
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Left content
                HStack(spacing: 12) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
                            .frame(width: 20)
                    }

                    Text(title)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isDestructive ? .red : Color(red: 0.067, green: 0.067, blue: 0.067))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)

                    Spacer()
                }

                // Right content
                HStack(spacing: 12) {
                    if let value = value {
                        Text(value)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
                            .lineLimit(1)
                    }

                    if hasChevron {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(minHeight: 56)
            .frame(maxWidth: .infinity) // Fill width
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            Rectangle()
                .fill(isPressed ? Color.black.opacity(0.05) : Color.clear)
        )
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct SettingsShowMoreItemView: View {
    let title: String
    let isExpanded: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
                    .multilineTextAlignment(.leading)

                Spacer()

                // Show more/less button
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.08))
                        .frame(width: 36, height: 28)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
            .background(
                Rectangle()
                    .fill(isPressed ? Color.black.opacity(0.05) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}



// MARK: - Enhanced Menu Item Types

struct SettingsToggleItemView: View {
    let title: String
    @Binding var isOn: Bool
    let action: ((Bool) -> Void)?

    @State private var isPressed = false

    init(title: String, isOn: Binding<Bool>, action: ((Bool) -> Void)? = nil) {
        self.title = title
        self._isOn = isOn
        self.action = action
    }

    var body: some View {
        HStack(spacing: 12) {
            // Left content
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
                .multilineTextAlignment(.leading)

            Spacer()

            // Right content - Toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .scaleEffect(0.8)
                .onChange(of: isOn) { _, newValue in
                    action?(newValue)
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(minHeight: 56)
        .frame(maxWidth: .infinity) // Fill width
        .contentShape(Rectangle())
        .background(
            Rectangle()
                .fill(isPressed ? Color.black.opacity(0.05) : Color.clear)
        )
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct SettingsSelectableItemView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Left content
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
                    .multilineTextAlignment(.leading)

                Spacer()

                // Right content - Checkmark
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(minHeight: 44)
            .frame(maxWidth: .infinity) // Fill width
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            Rectangle()
                .fill(isPressed ? Color.black.opacity(0.05) : Color.clear)
        )
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    VStack(spacing: 0) {
        // Navigation type (normal state)
        SettingsMenuItemView(title: "Label", value: "Value") {
            print("Navigation item tapped")
        }

        // Navigation type (simulated pressed state)
        SettingsMenuItemView(title: "Label", value: "Value") {
            print("Pressed item tapped")
        }
        .background(Color.black.opacity(0.05))

        // Toggle type
        SettingsToggleItemView(title: "Label", isOn: .constant(true)) { isOn in
            print("Toggle changed to: \(isOn)")
        }

        // Select type (unselected)
        SettingsSelectableItemView(title: "Label", isSelected: false) {
            print("Select item tapped")
        }

        // Select type (selected)
        SettingsSelectableItemView(title: "Label", isSelected: true) {
            print("Selected item tapped")
        }

        // Show more type
        SettingsShowMoreItemView(title: "Label", isExpanded: false) {
            print("Show more tapped")
        }

        // Show more type (expanded)
        SettingsShowMoreItemView(title: "Label", isExpanded: true) {
            print("Show less tapped")
        }
    }
    .background(Color.white)
    .cornerRadius(20)
    .padding()
    .background(Color(red: 0.961, green: 0.961, blue: 0.961))
}
