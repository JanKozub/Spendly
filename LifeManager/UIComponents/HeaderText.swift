//
//  HeaderText.swift
//  LifeManager
//
//  Created by Jan Kozub on 03/07/2024.
//

import SwiftUI

struct HeaderText: View {
    @State var text: String;
    @State var percentage: Double;
    @State var size: CGSize;
    
    var body: some View {
        Text(text).frame(maxWidth: size.width * percentage, alignment: .center)
    }
}

#Preview {
    HeaderText(text: "", percentage: 0.0, size: CGSize.zero)
}
