//
//  MealsView.swift
//  LifeManager
//
//  Created by Jan Kozub on 22/06/2024.
//

import SwiftUI

struct MealsView: View {
    @State private var importing = false
        
        var body: some View {
            Button("Import") {
                importing = true
            }
            .fileImporter(
                isPresented: $importing,
                allowedContentTypes: [.plainText]
            ) { result in
                switch result {
                case .success(let file):
                    print(file.absoluteString)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
}

#Preview {
    MealsView()
}
