//
//  PaymentView.swift
//  LifeManager
//
//  Created by Jan Kozub on 02/07/2024.
//

import SwiftUI

struct PaymentView: View {
    @Binding var payment: Payment;
    @Binding var width: CGFloat;
    @State var onPaymentChanged: (Payment) -> Void
    
    private let myRed = Color(red: 238/255, green: 36/255, blue: 0/255).opacity(0.1)
    private let myGreen = Color(red: 36/255, green: 238/255, blue: 0/255).opacity(0.1)
    
    var body: some View {
        let rowColor = payment.amount < 0 ? myRed: myGreen
        
        HStack {
            Text(payment.issuedDate).frame(maxWidth: width * 0.08, alignment: .center)
            Text(payment.transactionDate).frame(maxWidth: width * 0.08, alignment: .center)
            
            Text(payment.title).frame(maxWidth: width * 0.36, alignment: .center)
            Text(payment.message == "" ? "None" : payment.message).frame(maxWidth: width * 0.18, alignment: .center)
            
            Text(String(format: "%.2f", abs(payment.amount))).frame(maxWidth: width * 0.07, alignment: .center)
            Text(String(format: "%.2f", payment.balance)).frame(maxWidth: width * 0.07, alignment: .center)
            
            DropdownMenu(selectedCategory: PaymentCategory.other.name, elements: PaymentCategory.allCasesNames, onChange: Binding(
                get: {{ newValue in
                    payment.category = PaymentCategory.nameToType(name: newValue)
                    onPaymentChanged(payment)
                }},
                set: {_ in}
            )).frame(maxWidth: width * 0.07, alignment: .center)
            
            DropdownMenu(selectedCategory: PaymentType.personal.name, elements: PaymentType.allCasesNames, onChange: Binding(
                get: {{ newValue in
                    payment.type = PaymentType.nameToType(name: newValue)
                    onPaymentChanged(payment)
                }},
                set: {_ in}
            )).frame(maxWidth: width * 0.07, alignment: .center)
            
        }.background(rowColor)
    }
}

#Preview {
    PaymentView(payment: .constant(Payment.example()), width: .constant(CGFloat.infinity), onPaymentChanged: {_ in})
}
