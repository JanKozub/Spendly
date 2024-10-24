import SwiftUI

struct TableBottomBar: View {
    @Binding var payments: [Payment]
    @Binding var month: Month
    @Binding var expenseGroups: [TypeAndCurrencyGroup: Double]
    @Binding var tabSwitch: TabSwitch
    @Binding var errorShown: Bool
    @Binding var errorMessage: String
    
    var addMonth: () async throws -> Void
    
    @State private var isPresentingConfirmCancel: Bool = false
    @State private var isPresentingConfirmSubmit: Bool = false
    @State private var income: Double = 0.0
    
    var body: some View {
        HStack {
            IncomeText(month: $month)
            Divider()
            ExpenseText(type: .personal, expenseGroups: $expenseGroups)
            Divider()
            ExpenseText(type: .refunded, expenseGroups: $expenseGroups)
            Divider()
            
            Button("Cancel", role: .destructive) {
                isPresentingConfirmCancel = true
            }.confirmationDialog("Are you sure?", isPresented: $isPresentingConfirmCancel) {
                Button("Discard month") {
                    payments = []
                    tabSwitch = .main
                }
            }.dialogIcon(Image(systemName: "x.circle.fill"))
            
            DropdownMenu(selected: String(YearType.currentYear), elements: YearType.allYearsNames,
                         onChange: { newValue in month.yearNum = Int(newValue)!
            }).frame(maxWidth: 100)
            
            DropdownMenu(selected: MonthName.january.name, elements: MonthName.allCasesNames,
                         onChange: { newValue in month.monthName = MonthName.nameToType(name: newValue)
            }).frame(maxWidth: 100)
            
            Button("Add month", role: .destructive) {
                isPresentingConfirmSubmit = true
            }.confirmationDialog("Are you sure?", isPresented: $isPresentingConfirmSubmit) {
                Button("Add month") {
                    Task {
                        do {
                            try await addMonth()
                        } catch {
                            errorMessage = error.localizedDescription
                            errorShown = true
                        }
                    }
                }
            }.dialogIcon(Image(systemName: "pencil.circle.fill")).padding()
        }.frame(maxWidth: .infinity, maxHeight: 50, alignment: .center).padding(3)
    }
}
