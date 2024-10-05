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
    @State private var isEditing = false
    @State var onPaymentChanged: (Payment) -> Void
    var onDelete: () -> Void
    
    private let myRed = Color(red: 238/255, green: 36/255, blue: 0/255).opacity(0.1)
    private let myGreen = Color(red: 36/255, green: 238/255, blue: 0/255).opacity(0.1)
    
    var body: some View {
        let rowColor = payment.amount < 0 ? myRed: myGreen
        let otherMsg = "Issued Date: " + payment.issuedDate +
        "\nMessage: " + (payment.message == "" ? "None" : payment.message) +
        "\nBalance: " + String(format: "%.2f", payment.balance) + " zł"
        
        HStack {
            Text(payment.transactionDate)
                .frame(maxWidth: width * 0.1, alignment: .center)
            
            if isEditing {
                TextField("Edit Title", text: $payment.title, onCommit: {
                    isEditing = false
                    onPaymentChanged(payment)
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: width * 0.5, alignment: .center)
            } else {
                Text(payment.title).frame(maxWidth: width * 0.5, alignment: .center)
            }
            
            Text(String(format: "%.2f", abs(payment.amount)) + " " + payment.currency.name)
                .frame(maxWidth: width * 0.07, alignment: .center)
            
            DropdownMenu(
                selectedCategory: payment.category,
                elements: categories,
                onChange: Binding(
                    get: {{ newValue in
                        payment.category = newValue
                        onPaymentChanged(payment)
                    }},
                    set: {_ in}
                )
            ).frame(maxWidth: width * 0.1, alignment: .center)
            
            DropdownMenu(
                selectedCategory: payment.type.name,
                elements: PaymentType.allCasesNames,
                onChange: Binding(
                    get: {{ newValue in
                        payment.type = PaymentType.nameToType(name: newValue)
                        onPaymentChanged(payment)
                    }},
                    set: {_ in}
                )
            ).frame(maxWidth: width * 0.08, alignment: .center)
            
            HStack {
                Button(action: {isEditing.toggle()}) {
                    Image(systemName: isEditing ? "checkmark.circle" : "pencil.circle")
                        .foregroundColor(isEditing ? .green : .blue)
                }
                
                Button(action: {showDialog.toggle()}) {Image(systemName: "info.circle").foregroundColor(.gray)}
                .alert(
                    Text("Other Information"),
                    isPresented: $showDialog
                ) {} message: {Text(otherMsg)}
                
                Button(action: onDelete) {Image(systemName: "trash.circle").foregroundColor(.red)}
            }
            .frame(maxWidth: width * 0.1, alignment: .center)
        }
        .background(rowColor)
    }
}

#Preview {
    PaymentRow(
        payment: .constant(Payment.example()),
        width: .constant(CGFloat.infinity),
        categories: .constant([]),
        onPaymentChanged: {_ in},
        onDelete: {}
    )
}
