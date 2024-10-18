import SwiftUI
import SwiftData

struct TableView: View {
    @Environment(\.modelContext) private var context
    @Binding var payments: [Payment]
    @Binding var tabSwitch: TabSwitch
    
    @State var years: [Year]
    @State var categories: [PaymentCategory]
    @State var expenseGroups: [TypeAndCurrencyGroup: Double] = [:]
    @State private var month: Month = Month(monthName: .january, yearNum: YearType.currentYear)
    
    @State private var isEditPaymentNamesShown = false
    @State private var isAddPaymentShown = false
    @State private var genericErrorShown: Bool = false
    @State private var genericErrorMessage: String = ""
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                List {
                    ForEach($payments, id: \.self) { $payment in
                        PaymentRow(
                            payment: $payment,
                            width: .constant(reader.size.width),
                            categories: $categories,
                            onPaymentChanged: { o, n in updateExpenses(oldPayment: o, newPayment: n) },
                            onDelete: { deletePayment(payment: payment) }
                        )
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .listStyle(PlainListStyle())
                .frame(maxWidth: .infinity, maxHeight: abs(reader.size.height - 60))
                
                TableBottomBar(payments: $payments, month: $month, expenseGroups: $expenseGroups, tabSwitch: $tabSwitch, errorShown: $genericErrorShown, errorMessage: $genericErrorMessage, addMonth: addMonth)
            }.frame(maxWidth: .infinity, maxHeight: reader.size.height)
        }.toolbar {
            ToolbarItemGroup {
                Button("Edit Messages") { isEditPaymentNamesShown = true }
                Button("Add Payment") { isAddPaymentShown = true }
            }
        }.sheet(isPresented: $isEditPaymentNamesShown) {
            EditPaymentNames(isShown: $isEditPaymentNamesShown, payments: $payments)
        }.sheet(isPresented: $isAddPaymentShown) {
            NewPaymentPopup(payments: $payments, categories: $categories, isShown: $isAddPaymentShown, expenseGroups: $expenseGroups, month: $month)
        }.onAppear(perform: {
            Task {
                do {
                    try await month.setPayments(newPayments: payments)
                } catch {
                    genericErrorMessage = error.localizedDescription
                    genericErrorShown.toggle()
                }
            }
        })
        .padding(.top, 1)
        .onChange(of: month.currenciesInTheMonth, {
            initExpenses()
        })
        .alert(isPresented: $genericErrorShown) {
            Alert(title: Text(genericErrorMessage))
        }.dialogIcon(Image(systemName: "x.circle.fill"))
    }
    
    private func initExpenses() {
        for type in PaymentType.allCases {
            for currency in month.currenciesInTheMonth {
                let group = TypeAndCurrencyGroup(type: type, currency: currency)
                if !expenseGroups.keys.contains(group) {
                    expenseGroups[group, default: 0.0] = 0.0
                }
            }
        }
    }
    
    private func updateExpenses(oldPayment: Payment, newPayment: Payment) {
        if (newPayment.amount > 0) {
            return
        }
        
        let group = newPayment.getTypeAndCurrencyGroup()
        if (oldPayment.type != newPayment.type) {
            let oldGroup = oldPayment.getTypeAndCurrencyGroup()
            expenseGroups[oldGroup, default: 0] -= abs(oldPayment.amount)
            expenseGroups[group, default: 0] += abs(newPayment.amount)
        } else if oldPayment.category == nil {
            expenseGroups[group, default: 0] += abs(newPayment.amount)
        }
    }
    
    private func deletePayment(payment: Payment) {
        if payment.amount < 0 {
            if payment.category != nil {
                expenseGroups[payment.getTypeAndCurrencyGroup(), default: 0] -= abs(payment.amount)
            }
        }
        
        month.removePayment(payment: payment)
        payments.remove(at: payments.firstIndex(of: payment)!)
    }
    
    private func addMonth() async throws {
        if (ExistsEmptyCategoryField()) {
            throw NSError(domain: "Every category field must be filled", code: 0)
        }
        
        context.insert(month)
        addPaymentsToContext()
        
        let yearIdx = getIndexOfYear(yearNum: month.yearNum)
        if yearIdx == nil {
            addNewYear(newYear: Year(number: month.yearNum, months: [month]))
            saveAndReturnToMain()
            return
        }
        
        let monthIdx = getIndexOfMonth(yearIdx: yearIdx!, monthName: month.monthName)
        if monthIdx == nil {
            years[yearIdx!].months.append(month)
            saveAndReturnToMain()
            return
        }
        
        let alert = getOverwriteDialog()
        if alert.runModal() == .alertFirstButtonReturn {
            years[yearIdx!].months[monthIdx!] = month
            saveAndReturnToMain()
        }
    }
    
    private func addNewYear(newYear: Year) {
        context.insert(newYear)
        years.append(newYear)
    }
    
    private func addPaymentsToContext() {
        for payment in payments {
            if payment.modelContext != context {
                context.insert(payment)
            }
            month.payments.append(payment)
        }
    }
    
    private func saveAndReturnToMain() {
        try? context.save()
        payments = []
        tabSwitch = .main
    }
    
    private func ExistsEmptyCategoryField() -> Bool {
        return payments.contains(where: { $0.category == nil })
    }
    
    private func getIndexOfYear(yearNum: Int) -> Int? {
        return years.firstIndex(where: { $0.number == yearNum}) ?? nil
    }
    
    private func getIndexOfMonth(yearIdx: Int, monthName: MonthName) -> Int? {
        return years[yearIdx].months.firstIndex(where: { $0.monthName == month.monthName }) ?? nil
    }
    
    private func getOverwriteDialog() -> NSAlert {
        let alert = NSAlert()
        alert.messageText = "Overwrite Month?"
        alert.informativeText = "This month already exists in the database. Do you want to overwrite it?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Overwrite")
        alert.addButton(withTitle: "Cancel")
        alert.icon = NSImage(systemSymbolName: "x.circle.fill", accessibilityDescription: "")
        return alert
    }
}
