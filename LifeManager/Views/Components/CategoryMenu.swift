//
//  CategoryMenu.swift
//  LifeManager
//
//  Created by Jan Kozub on 02/07/2024.
//

import SwiftUI

struct CategoryMenu: View {
    @Binding var elements: [String]
    @State private var selectedCategory: String = "Other"
    
    var body: some View {
        VStack {
            Picker("",selection: $selectedCategory) {
                ForEach(elements, id: \.self) { category in
                    Text(category)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    CategoryMenu(elements: .constant([]))
}
