import SwiftUI

struct CurrencyText: View {
    @State var type: PaymentType
    @Binding var expenseGroups: [TypeAndCurrencyGroup: Double]
    
    var body: some View {
        VStack {
            Text(type.name + ":\n").frame(maxWidth: .infinity, alignment: .center)
            ForEach(expenseGroups.filter { $0.key.type == type }, id: \.key) { key, value in
                Text(String(format: "%.2f", value) + " " + key.currency.name)
            }
        }
    }
}
