import SwiftUI

struct TopBarMenu: View {
    @Binding var displayMonth: MonthName
    @Binding var chartType: String
    @Binding var currency: CurrencyName
    
    var body: some View {
        Menu {
            Picker("Select Month", selection: $displayMonth) {
                ForEach(MonthName.allCasesNames, id: \.self) { monthName in
                    Text(monthName).tag(MonthName.nameToType(name: monthName))
                }
            }
            
            Picker("Select Chart Type", selection: $chartType) {
                Text("Year").tag("Year")
                Text("Month").tag("Month")
            }
            
            Picker("Select Currency", selection: $currency) {
                ForEach(CurrencyName.allCasesNames, id: \.self) { currencyName in
                    Text(currencyName).tag(CurrencyName.nameToType(name: currencyName))
                }
            }
        } label: { Label("Options", systemImage: "slider.horizontal.3") }
    }
}
