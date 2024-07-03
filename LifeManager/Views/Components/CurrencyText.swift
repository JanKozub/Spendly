//
//  CurrencyText.swift
//  LifeManager
//
//  Created by Jan Kozub on 03/07/2024.
//

import SwiftUI

struct CurrencyText: View {
    @State var title: String;
    @Binding var value: Double;
    @State var currency: String;
    
    var body: some View {
        Text(title + ": " + String(format: "%.2f", value) + " " + currency).frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    CurrencyText(title: "", value: .constant(0.0), currency: "")
}
