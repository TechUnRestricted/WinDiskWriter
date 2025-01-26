//
//  PickerView.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.12.2024.
//

import SwiftUI

private enum Constants {
    static let spacing: CGFloat = 8
}

protocol PickerItemProtocol: Identifiable {
    var text: String? { get }
    var image: Image? { get }
}

struct PickerView<Item: PickerItemProtocol>: View {
    @Binding private var selectedItem: Item
    private let orientation: Axis.Set
    private let items: [Item]
    
    init(orientation: Axis.Set, items: [Item], selectedItem: Binding<Item>) {
        self.orientation = orientation
        self.items = items
        self._selectedItem = selectedItem
    }

    var body: some View {
        groupView
    }

    @ViewBuilder
    private var groupView: some View {
        switch orientation {
        case .vertical:
            VStack(alignment: .leading, spacing: Constants.spacing) {
                itemsBuilderView
            }
        case .horizontal:
            HStack(alignment: .center, spacing: Constants.spacing) {
                itemsBuilderView
            }
        default:
            fatalError("Unsupported orientation")
        }
    }
    
    @ViewBuilder
    private var itemsBuilderView: some View {
        ForEach(items) { item in
            createButtonView(for: item)
        }
    }
    
    @ViewBuilder
    private func createButtonView(for item: Item) -> some View {
        Button(action: {
            selectedItem = item
        }) {
            createUI(for: item)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func createUI(for item: Item) -> some View {
        let isSelected = (item.id == selectedItem.id)
        
        var borderColor: Color {
            guard isSelected else { return .clear }
            
            return .gray
        }
        
        var backgroundColor: Color {
            guard isSelected else { return Color.gray.opacity(0.2) }
            
            return Color.gray.opacity(0.15)
        }
        
        HStack {
            if let image = item.image {
                image
            }
            
            if let text = item.text {
                Text(text)
            }
        }
        .padding(Constants.spacing)
        .padding(.horizontal, Constants.spacing * 2)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .bordered(cornerRadius: 8, color: borderColor, lineWidth: 2, clipsToShape: true)
        .animation(.snappy.speed(2), value: isSelected)
    }
}

// Sample Item for Preview
private struct SampleItem: PickerItemProtocol {
    let id: UUID = UUID()
    let text: String?
    let image: Image?
}

// Preview
private struct PickerView_Previews: PreviewProvider {
    static let previewItems: [SampleItem] = [
        SampleItem(text: "Item 1", image: Image(systemName: "star")),
        SampleItem(text: "Item 2", image: Image(systemName: "heart")),
        SampleItem(text: "Item 3", image: Image(systemName: "circle"))
    ]
    
    static var previews: some View {
        StatefulPreviewWrapper(initialValue: previewItems.first.unsafelyUnwrapped) { selectedItem in
            PickerView(
                orientation: .horizontal,
                items: previewItems,
                selectedItem: selectedItem
            )
            .padding()
        }
    }
}

private struct StatefulPreviewWrapper<Value: Identifiable, Content: View>: View {
    @State private var value: Value

    private let content: (Binding<Value>) -> Content

    init(initialValue: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}

