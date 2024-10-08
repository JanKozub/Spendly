import SwiftUI

struct TableBottomBar: View {
    @Binding var payments: [Payment]
    @State var currency: CurrencyName = .pln
    @Binding var incomeSum: Double
    @Binding var yearName: String
    @Binding var monthName: MonthName
    @Binding var expensesForType: [PaymentType: Double]
    
    var addMonth: (CurrencyName) async throws -> Void
    
    @State private var isPresentingConfirmCancel: Bool = false
    @State private var isPresentingConfirmSubmit: Bool = false
    
    var body: some View {
        HStack {
            CurrencyText(title: "Income", value: $incomeSum, currency: currency)
            Divider()
            CurrencyText(title: "Personal", value: .constant(expensesForType[.personal, default: 0.0]), currency: currency)
            Divider()
            CurrencyText(title: "Refunded", value: .constant(expensesForType[.refunded, default: 0.0]), currency: currency)
            Divider()
            
            Button("Cancel", role: .destructive) {
                isPresentingConfirmCancel = true
            }.confirmationDialog("Are you sure?", isPresented: $isPresentingConfirmCancel) {
                Button("Discard month") {
                    payments = []
                }
            }.dialogIcon(Image(systemName: "x.circle.fill"))
            
            DropdownMenu(
                selectedCategory: String(YearName.currentYear), elements: YearName.allYearsNames,
                onChange: Binding(
                    get: {{newValue in yearName = newValue}},
                    set: {_ in}
                )
            ).frame(maxWidth: 100)
            
            DropdownMenu(
                selectedCategory: MonthName.january.name, elements: MonthName.allCasesNames,
                onChange: Binding(
                    get: {{newValue in monthName = MonthName.nameToType(name: newValue)}},
                    set: {_ in}
                )
            ).frame(maxWidth: 100)
            
            Button("Add month", role: .destructive) {
                isPresentingConfirmSubmit = true
            }.confirmationDialog("Are you sure?", isPresented: $isPresentingConfirmSubmit) {
                Button("Add/Edit Month") {
                    Task {
                        do {
                            try await addMonth(currency)
                        } catch {
                            //TODO Handle error
                        }
                    }
                }
            }.dialogIcon(Image(systemName: "pencil.circle.fill"))
            
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: 30, alignment: .center).padding(3)
    }
}
