import SwiftUI

struct TableBottomBar: View {
    @Binding var payments: [Payment]
    @Binding var incomeSum: Double
    @Binding var monthName: MonthName
    @Binding var yearNum: Int
    @Binding var expenseGroups: [TypeAndCurrencyGroup: Double]
    
    var addMonth: () async throws -> Void
    
    @State private var isPresentingConfirmCancel: Bool = false
    @State private var isPresentingConfirmSubmit: Bool = false
    
    var body: some View {
        HStack {
            //CurrencyText(text: "Income", value: $incomeSum, currency: currency)
            Divider()
            CurrencyText(type: .personal, expenseGroups: $expenseGroups)
            Divider()
            CurrencyText(type: .refunded, expenseGroups: $expenseGroups)
            Divider()
            
            Button("Cancel", role: .destructive) {
                isPresentingConfirmCancel = true
            }.confirmationDialog("Are you sure?", isPresented: $isPresentingConfirmCancel) {
                Button("Discard month") {
                    payments = []
                }
            }.dialogIcon(Image(systemName: "x.circle.fill"))
            
            DropdownMenu(
                selectedCategory: String(YearType.currentYear), elements: YearType.allYearsNames,
                onChange: Binding(
                    get: {{newValue in yearNum = Int(newValue)!}},
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
                            try await addMonth()
                        } catch {
                            //TODO Handle error
                        }
                    }
                }
            }.dialogIcon(Image(systemName: "pencil.circle.fill"))
            
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: 80, alignment: .center).padding(3)
    }
}
