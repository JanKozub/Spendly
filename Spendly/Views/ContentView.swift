import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var years: [Year]
    @Query private var categories: [PaymentCategory]
    @Query private var savedPayments: [Payment]
    
    @State private var payments: [Payment] = []
    @State private var isShowingSettings:Bool = false
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        if isShowingSettings {
            SettingsView(isShowing: $isShowingSettings, context: context, categories: .constant(categories))
        } else if !payments.isEmpty {
            TableView(payments: $payments, years: years, categories: categories)
        } else {
            MainView(payments: $payments, isShowingSettings: $isShowingSettings, years: years, categories: categories, savedPayments: savedPayments)
        }
    }
}
