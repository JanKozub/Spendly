import SwiftUI

struct TopBarMenu: View {
    @Binding var displayMonth: MonthName
    @Binding var chartType: String
    @Binding var currency: CurrencyName
    
    var refreshChart: () async -> Void
    
    var body: some View {
        Menu {
            Picker("Select Month", selection: $displayMonth) {
                ForEach(MonthName.allCasesNames, id: \.self) { monthName in
                    Text(monthName).tag(MonthName.nameToType(name: monthName))
                }
            }.onChange(of: displayMonth) {
                Task { await refreshChart() }
            }
            
            Picker("Select Chart Type", selection: $chartType) {
                Text("Year").tag("Year")
                Text("Month").tag("Month")
            }.onChange(of: chartType) {
                Task { await refreshChart() }
            }
            
            Picker("Select Currency", selection: $currency) {
                ForEach(CurrencyName.allCasesNames, id: \.self) { currencyName in
                    Text(currencyName).tag(CurrencyName.nameToType(name: currencyName))
                }
            }.onChange(of: currency) {
                Task { await refreshChart() }
            }
        } label: {
            Label("Options", systemImage: "slider.horizontal.3")
        }
    }
}
