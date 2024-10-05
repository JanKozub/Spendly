//
//  PaymentView.swift
//  LifeManager
//
//  Created by Jan Kozub on 02/07/2024.
//

import SwiftUI

struct PaymentRow: View {
    @Binding var payment: Payment
    @Binding var width: CGFloat
    @Binding var categories: [String]
    @State private var showDialog = false
    @State var onPaymentChanged: (Payment) -> Void
    
    private let myRed = Color(red: 238/255, green: 36/255, blue: 0/255).opacity(0.1)
    private let myGreen = Color(red: 36/255, green: 238/255, blue: 0/255).opacity(0.1)
    
    var body: some View {
        let rowColor = payment.amount < 0 ? myRed: myGreen
        let otherMsg = "Issued Date: " + payment.issuedDate +
                        "\nMessage: " + (payment.message == "" ? "None" : payment.message) +
                        "\nBalance: " + String(format: "%.2f", payment.balance) + " zł"
        
        HStack {
            Text(payment.transactionDate).frame(maxWidth: width * 0.1, alignment: .center)
            Text(payment.title).frame(maxWidth: width * 0.6, alignment: .center)
            
            Text(String(format: "%.2f", abs(payment.amount)) + " " + payment.currency.name).frame(maxWidth: width * 0.07, alignment: .center)
            
            DropdownMenu(selectedCategory: "", elements: categories, onChange: Binding(
                get: {{ newValue in
                    payment.category = newValue
                    onPaymentChanged(payment)
                }},
                set: {_ in}
            )).frame(maxWidth: width * 0.1, alignment: .center)
            
            DropdownMenu(selectedCategory: PaymentType.personal.name, elements: PaymentType.allCasesNames, onChange: Binding(
                get: {{ newValue in
                    payment.type = PaymentType.nameToType(name: newValue)
                    onPaymentChanged(payment)
                }},
                set: {_ in}
            )).frame(maxWidth: width * 0.08, alignment: .center)
            
            Button(action: {
                showDialog.toggle()
            }) {
                Image(systemName: "info.circle")
            }.alert(
                Text("Other Information"),
                isPresented: $showDialog
            ) {} message: {
                Text(otherMsg)
            }.frame(maxWidth: width * 0.05, alignment: .center)
        }
        .background(rowColor)
    }
}

#Preview {
    PaymentRow(payment: .constant(Payment.example()), width: .constant(CGFloat.infinity), categories: .constant([]), onPaymentChanged: {_ in})
}
