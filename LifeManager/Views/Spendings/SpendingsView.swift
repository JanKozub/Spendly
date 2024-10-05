import SwiftUI
import Foundation
import SwiftData

struct SpendingsView: View {
    @State private var payments: [Payment] = []
    @State private var importing: Bool = false
    
    @Query private var years: [Year]
    @Query private var categories: [PaymentCategory]
    @Query private var allPayments: [Payment]
    
    @State private var currentYear: Year?
    @State var foregroundScale: KeyValuePairs<String, Color> = KeyValuePairs<String, Color>()
    
    @Environment(\.modelContext) private var context
    
    @State private var isShowingSettings:Bool = false
    
    var body: some View {
        if isShowingSettings {
            SpendingsSettingsView(isShowing: $isShowingSettings, context: context, categories: .constant(categories))
        } else if payments.isEmpty {
            SpendingsMainView(payments: $payments, isShowingSettings: $isShowingSettings, years: years, categories: categories, allPayments: allPayments)
        } else {
            TableView(payments: $payments, years: years, categories: PaymentCategory.convertToStringArray(inputArray: categories))
        }
    }
}

#Preview {
    SpendingsView().padding()
}
