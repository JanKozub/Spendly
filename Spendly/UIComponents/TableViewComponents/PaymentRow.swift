import SwiftUI

struct PaymentRow: View {
    @Binding var payment: Payment
    @Binding var width: CGFloat
    @Binding var categories: [PaymentCategory]
    @State private var isEditing = false
    @State var onPaymentChanged: (Payment, Payment) -> Void
    var onDelete: () -> Void
    
    private let myRed = Color(red: 238/255, green: 36/255, blue: 0/255).opacity(0.1)
    private let myGreen = Color(red: 36/255, green: 238/255, blue: 0/255).opacity(0.1)
    
    var body: some View {
        HStack {
            Text(PaymentDate.dateToStringDot(date: payment.date)).frame(maxWidth: width * 0.1, alignment: .center)
            
            if isEditing {
                TextField("Edit Message", text: $payment.message, onCommit: {
                    isEditing = false
                    onPaymentChanged(payment, payment)
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: width * 0.5, alignment: .center)
            } else {
                Text(payment.message).frame(maxWidth: width * 0.5, alignment: .center)
            }
            
            Text(String(format: "%.2f", abs(payment.amount)) + " " + payment.currency.name)
                .frame(maxWidth: width * 0.07, alignment: .center)
            
            let category = payment.category != nil ? payment.category!.name : ""
            DropdownMenu(selected: category, elements: PaymentCategory.convertToStringArray(inputArray: categories), onChange: { newValue in
                let old = payment.copy()
                payment.category = categories.first(where: { $0.name == newValue }) ?? PaymentCategory.example()
                onPaymentChanged(old, payment)
            }).frame(maxWidth: width * 0.1, alignment: .center)
            
            DropdownMenu(selected: payment.type.name, elements: PaymentType.allCasesNames, onChange: { newValue in
                let old = payment.copy()
                payment.type = PaymentType.nameToType(name: newValue)
                onPaymentChanged(old, payment)
            }).frame(maxWidth: width * 0.08, alignment: .center)
            
            HStack {
                Button(action: { isEditing.toggle() }) {
                    Image(systemName: isEditing ? "checkmark.circle" : "pencil.circle")
                        .foregroundColor(isEditing ? .green : .blue)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle").foregroundColor(.red)
                }
            }
            .frame(maxWidth: width * 0.1, alignment: .center)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .background(payment.amount < 0 ? myRed : myGreen)
    }
}
