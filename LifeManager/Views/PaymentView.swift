//
//  PaymentView.swift
//  LifeManager
//
//  Created by Jan Kozub on 02/07/2024.
//

import SwiftUI

struct PaymentView: View {
    @Binding var payment: Payment;
    var body: some View {
        HStack {
            Text(payment.issuedDate).frame(maxWidth: 100, alignment: .center).border(.green)
            Text(payment.transactionDate).frame(maxWidth: 150, alignment: .center).border(.red)
            
            Text(payment.title).frame(maxWidth: .infinity, alignment: .center)
            Text(payment.message == "" ? "None" : payment.message).frame(maxWidth: .infinity, alignment: .center)
            
            Text(String(format: "%.2f", payment.amount)).frame(maxWidth: 100, alignment: .center).border(.yellow)
            Text(String(format: "%.2f", payment.balance)).frame(maxWidth: 100, alignment: .center).border(.blue)
        }
    }
}

#Preview {
    PaymentView(payment: .constant(Payment.example()))
}
