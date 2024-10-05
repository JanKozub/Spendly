//
//  CategoryMenu.swift
//  LifeManager
//
//  Created by Jan Kozub on 02/07/2024.
//

import SwiftUI

struct DropdownMenu: View {
    @State var selectedCategory: String
    @State var elements: [String]
    @Binding var onChange: ((String) -> Void)?
    
    var body: some View {
        Menu {
            ForEach(elements, id: \.self) { category in
                Button(action: {
                    selectedCategory = category
                }) {
                    Text(category)
                }
            }
        } label: {
            HStack {
                Text(selectedCategory)
            }
            .frame(maxWidth: .infinity)
            .padding(5)
            .background(Color.white.opacity(0.2))
            .cornerRadius(5)
        }
        .onChange(of: selectedCategory) { oldValue, newValue in
            onChange?(newValue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    @Previewable @State var onChangeHandler: ((String) -> Void)? = nil
    
    return DropdownMenu(selectedCategory: "Other", elements: ["Category 1", "Category 2", "Other"], onChange: $onChangeHandler)
}
