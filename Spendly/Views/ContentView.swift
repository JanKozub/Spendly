import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var years: [Year]
    @Query private var categories: [PaymentCategory]
    @Query private var savedPayments: [Payment]
    
    @State private var payments: [Payment] = []
    @State private var tabSwitch: TabSwitch = .main
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        switch tabSwitch {
        case .main:
            MainView(payments: $payments,
                     tabSwitch: $tabSwitch,
                     years: years,
                     categories: categories,
                     savedPayments: savedPayments)
        case .table:
            TableView(payments: $payments,
                      tabSwitch: $tabSwitch,
                      years: years,
                      categories: categories)
        case .settings:
            SettingsView(tabSwitch: $tabSwitch,
                         context: context,
                         categories: .constant(categories))
        }
    }
}
