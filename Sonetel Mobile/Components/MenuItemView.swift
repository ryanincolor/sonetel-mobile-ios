//
//  MenuItemView.swift
//  Sonetel Mobile
//
//  Updated menu item component using Figma design tokens
//

import SwiftUI

struct MenuItemView: View {
    let title: String
    let value: String?
    let type: MenuItemType
    let isSelected: Bool
    let hasDivider: Bool
    let leftIcon: AnyView?
    let action: (() -> Void)?

    @State private var isPressed = false
    @State private var isToggleOn = false

    enum MenuItemType {
        case navigation
        case toggle(binding: Binding<Bool>)
        case select
        case showMore
    }

    init(
        title: String,
        value: String? = nil,
        type: MenuItemType = .navigation,
        isSelected: Bool = false,
        hasDivider: Bool = true,
        leftIcon: AnyView? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.value = value
        self.type = type
        self.isSelected = isSelected
        self.hasDivider = hasDivider
        self.leftIcon = leftIcon
        self.action = action
    }

    var body: some View {
        Group {
            if case .toggle(let binding) = type {
                // Toggle type doesn't need button wrapper
                contentView
                    .onTapGesture {
                        binding.wrappedValue.toggle()
                    }
            } else if let action = action {
                Button(action: action) {
                    contentView
                        .background(isPressed ? FigmaColorTokens.adaptiveT2 : Color.clear)
                }
                .buttonStyle(.plain)
                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                    isPressed = pressing
                }, perform: {})
            } else {
                contentView
            }
        }
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            // Main content
            HStack(spacing: 0) {
                // Left Content
                HStack(spacing: 10) {
                    if let leftIcon = leftIcon {
                        leftIcon
                    }

                    Text(title)
                        .font(FigmaTypographyTokens.label_x_large.weight(.medium))
                        .foregroundColor(FigmaColorTokens.textPrimary)
                        .lineLimit(1)
                        .kerning(-0.36)
                }
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Right Content
                HStack(spacing: 12) {
                    rightContent
                }
                .padding(.trailing, 16)
            }
            .padding(.leading, 16)
            .padding(.trailing, 4)
            .frame(height: 56)
            .frame(maxWidth: .infinity)

            // Divider
            if hasDivider {
                Rectangle()
                    .fill(FigmaColorTokens.adaptiveT1)
                    .frame(height: 1)
                    .padding(.leading, 16)
            }
        }
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var rightContent: some View {
        switch type {
        case .navigation:
            if let value = value {
                Text(value)
                    .font(FigmaTypographyTokens.label_x_large.weight(.medium))
                    .foregroundColor(FigmaColorTokens.textPrimary)
                    .lineLimit(1)
                    .kerning(-0.36)
            }

            // Chevron right
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(FigmaColorTokens.textPrimary)

        case .toggle(let binding):
            Toggle("", isOn: binding)
                .toggleStyle(CustomToggleStyle())

        case .select:
            if let value = value {
                Text(value)
                    .font(FigmaTypographyTokens.label_x_large.weight(.medium))
                    .foregroundColor(FigmaColorTokens.textPrimary)
                    .lineLimit(1)
                    .kerning(-0.36)
            }

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(FigmaColorTokens.textPrimary)
            }

        case .showMore:
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(FigmaColorTokens.adaptiveT2)
                    .frame(width: 36, height: 28)

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(FigmaColorTokens.textPrimary)
            }
        }
    }
}

// MARK: - Custom Toggle Style
struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Background track
            RoundedRectangle(cornerRadius: 15.5)
                .fill(FigmaColorTokens.textPrimary)
                .frame(width: 51, height: 31)

            // White circle
            Circle()
                .fill(Color.white)
                .frame(width: 27, height: 27)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 3)
                .shadow(color: .black.opacity(0.06), radius: 0.5, x: 0, y: 3)
                .offset(x: configuration.isOn ? 10 : -10)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isOn)
        }
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }
}

// MARK: - Menu Container
struct MenuView: View {
    let items: [MenuItemView]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<items.count, id: \.self) { index in
                items[index]
                    .background(FigmaColorTokens.adaptiveT1)
            }
        }
        .background(FigmaColorTokens.adaptiveT1)
        .clipShape(RoundedRectangle(cornerRadius: FigmaBorderRadiusTokens.large))
    }
}

// Using Color(figmaHex:) extension from FigmaGeneratedDesignTokens.swift

// MARK: - Previews
#Preview("Navigation Items") {
    VStack(spacing: 20) {
        MenuView(items: [
            MenuItemView(title: "Phone Numbers", type: .navigation),
            MenuItemView(title: "Call Settings", type: .navigation),
            MenuItemView(title: "Language", value: "English", type: .navigation),
            MenuItemView(title: "Appearance", value: "Automatic", type: .navigation, hasDivider: false)
        ])

        MenuView(items: [
            MenuItemView(title: "Notifications", type: .toggle(binding: .constant(true))),
            MenuItemView(title: "Auto-answer", type: .toggle(binding: .constant(false)), hasDivider: false)
        ])

        MenuView(items: [
            MenuItemView(title: "Option 1", type: .select, isSelected: true),
            MenuItemView(title: "Option 2", type: .select),
            MenuItemView(title: "Option 3", type: .select, hasDivider: false)
        ])

        MenuView(items: [
            MenuItemView(title: "Show more options", type: .showMore, hasDivider: false)
        ])
    }
    .padding(20)
}

#Preview("Individual Types") {
    VStack(spacing: 16) {
        MenuItemView(title: "Navigation", value: "Value", type: .navigation)
            .background(FigmaColorTokens.adaptiveT1)
            .clipShape(RoundedRectangle(cornerRadius: FigmaBorderRadiusTokens.large))

        MenuItemView(title: "Toggle", type: .toggle(binding: .constant(true)))
            .background(FigmaColorTokens.adaptiveT1)
            .clipShape(RoundedRectangle(cornerRadius: FigmaBorderRadiusTokens.large))

        MenuItemView(title: "Select", type: .select, isSelected: true)
            .background(FigmaColorTokens.adaptiveT1)
            .clipShape(RoundedRectangle(cornerRadius: FigmaBorderRadiusTokens.large))

        MenuItemView(title: "Show More", type: .showMore)
            .background(FigmaColorTokens.adaptiveT1)
            .clipShape(RoundedRectangle(cornerRadius: FigmaBorderRadiusTokens.large))
    }
    .padding(20)
}
