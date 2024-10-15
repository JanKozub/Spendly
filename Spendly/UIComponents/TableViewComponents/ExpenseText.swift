import SwiftUI

struct ExpenseText: View {
    @State var type: PaymentType
    @Binding var expenseGroups: [TypeAndCurrencyGroup: Double]
    
    var body: some View {
        VStack {
            Text(type.name + ":").frame(maxWidth: .infinity, alignment: .center).padding(1)
            
            HStack {
                ForEach(expenseGroups.filter { $0.key.type == type }, id: \.key) { key, value in
                    Text(String(format: "%.2f", value) + " " + key.currency.name)
                }
            }
        }
    }
}
