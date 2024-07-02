//
//  CurrencyText.swift
//  LifeManager
//
//  Created by Jan Kozub on 03/07/2024.
//

import SwiftUI

struct CurrencyText: View {
    @State var title: String;
    @State var value: Double;
    @State var currency: String;
    
    var body: some View {
        Text(title + ": " + String(format: "%.2f", 123.222) + " " + currency).frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    CurrencyText(title: "", value: 0.0, currency: "")
}
