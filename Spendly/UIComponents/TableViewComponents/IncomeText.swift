import SwiftUI

struct IncomeText: View {
    @Binding var month: Month
    @State private var values: [CurrencyName: Double] = [:]
    
    var body: some View {
        VStack {
            Text("Income:").frame(maxWidth: .infinity, alignment: .center).padding(1)
            
            HStack {
                ForEach(Array(values.sorted(by: { $0.key.name < $1.key.name} )), id: \.key) { key, value in
                    Text(String(format: "%.2f", value) + " " + key.name)
                }
            }
        }.onChange(of: month.currenciesInTheMonth, {
            updateValues()
        }).onChange(of: month.getIncomePayments(), {
            updateValues()
        })
    }
    
    private func updateValues() {
        values = [:]
        for currency in month.currenciesInTheMonth {
            for payment in month.getIncomePayments() where payment.currency == currency {
                values[currency, default: 0.0] += payment.amount
            }
        }
        
        for cur in month.currenciesInTheMonth {
            if !values.keys.contains(cur) {
                values[cur, default: 0.0] = 0.0
            }
        }
    }
}
