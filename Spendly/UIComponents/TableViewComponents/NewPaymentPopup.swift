import SwiftUI

struct NewPaymentPopup: View {
    @Binding var payments: [Payment]
    @Binding var categories: [PaymentCategory]
    @Binding var isShown: Bool
    @Binding var expensesForType: [PaymentType: Double]
    
    @State private var newPaymentDate: String = ""
    @State private var newPaymentMessage: String = ""
    @State private var newPaymentAmount: String = ""
    @State private var newPaymentCategory: PaymentCategory = PaymentCategory(name: "", graphColor: .red)
    @State private var newPaymentType: PaymentType = .personal
    @State private var newPaymentCurrency: CurrencyName = .pln
    
    var body: some View {
        VStack {
            Text("Add New Payment").font(.headline).padding(.bottom, 20)
            
            TextField("Transaction Date (dd-MM-yyyy)", text: $newPaymentDate)
                .textFieldStyle(RoundedBorderTextFieldStyle()).padding()
            
            TextField("Message", text: $newPaymentMessage).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
            
            TextField("Amount", text: $newPaymentAmount).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
            
            Picker("Category", selection: $newPaymentCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category.name)
                }
            }.padding()
            
            Picker("Type", selection: $newPaymentType) {
                ForEach(PaymentType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized)
                }
            }.padding()
            
            Picker("Currency", selection: $newPaymentCurrency) {
                ForEach(CurrencyName.allCases, id: \.self) { currency in
                    Text(currency.name)
                }
            }.padding()
            
            HStack {
                Button("Cancel") { isShown = false }
                Spacer()
                Button("Add Payment") {
                    addNewPayment()
                    isShown = false
                }
            }.padding()
        }.padding()
    }
    
    private func addNewPayment() {
        guard let amount = Double(newPaymentAmount) else { return }
        
        let newPayment = Payment(
            date: Payment.dateFromString(newPaymentDate) ?? Date(),
            message: newPaymentMessage,
            amount: amount,
            currency: newPaymentCurrency,
            category: newPaymentCategory,
            type: newPaymentType
        )
        
        payments.append(newPayment)
        expensesForType[newPayment.type, default: 0] += abs(newPayment.amount)
    }
}
