import SwiftUI
import SwiftData

struct TableView: View {
    @Binding var payments: [Payment]
  
    @State var years: [Year]
    @State var categories: [PaymentCategory]
    @State var expenseGroups: [TypeAndCurrencyGroup: Double] = [:]
    @State private var incomeSum: Double = 0
    @State private var yearName: String = String(YearName.currentYear)
    @State private var monthName: MonthName = MonthName.january
    
    @State private var isMonthCompleteAlert = false
    @State private var isEditPaymentNamesShown = false
    @State private var isAddPaymentShown = false
    
    @Environment(\.modelContext) private var context
    
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
                
                TableBottomBar(payments: $payments, incomeSum: $incomeSum, yearName: $yearName,
                               monthName: $monthName, expenseGroups: $expenseGroups, addMonth: addMonth)
            }.frame(maxWidth: .infinity, maxHeight: reader.size.height)
        }.toolbar {
            ToolbarItemGroup {
                Button("Edit Messages") { isEditPaymentNamesShown = true }
                Button("Add Payment") { isAddPaymentShown = true }
            }
        }.sheet(isPresented: $isEditPaymentNamesShown) {
            EditPaymentNames(isShown: $isEditPaymentNamesShown, payments: $payments)
        }.sheet(isPresented: $isAddPaymentShown) {
            NewPaymentPopup(payments: $payments, categories: $categories, isShown: $isAddPaymentShown, expenseGroups: $expenseGroups)
        }.onAppear(perform: updateIncome)
        .padding(.top, 1)
        .alert("Every category has to be filled", isPresented: $isMonthCompleteAlert) {
            Button("OK", role: .cancel) { }
        }.dialogIcon(Image(systemName: "x.circle.fill"))
    }
    
    private func updateIncome() {
        for payment in payments {
            if payment.amount > 0 {
                incomeSum += payment.amount
            }
        }
    }
    
    private func updateExpenses(oldPayment: Payment, newPayment: Payment) {
        let group = newPayment.getTypeAndCurrencyGroup()
        if (oldPayment.type != newPayment.type) {
            expenseGroups[group, default: 0] -= abs(oldPayment.amount)
            expenseGroups[group, default: 0] += abs(newPayment.amount)
        } else if oldPayment.category.name.isEmpty {
            expenseGroups[group, default: 0] += abs(newPayment.amount)
        }
    }
    
    private func deletePayment(payment: Payment) {
        if payment.amount > 0 {
            incomeSum -= payment.amount
        } else {
            expenseGroups[payment.getTypeAndCurrencyGroup(), default: 0] -= abs(payment.amount)
        }
        
        payments.removeAll(where: { $0.id == payment.id })
    }
    
    private func addMonth(currency: CurrencyName) async throws {
        for payment in payments {
            if payment.category.name == "" {
                isMonthCompleteAlert = true
                return
            }
        }
        
        let month = try await Month(monthName: monthName, year: Int(yearName)!, payments: payments)
        context.insert(month)
        for payment in payments {
            if payment.modelContext != context {
                context.insert(payment)
            }
            month.payments.append(payment)
        }
        
        if let yearIdx = years.firstIndex(where: {$0.number == Int(yearName) ?? 0}) {
            if let monthIdx = years[yearIdx].months.firstIndex(where: { $0.monthName == monthName }) {
                years[yearIdx].months[monthIdx] = month //TODO Popup about overwriting month
            } else {
                years[yearIdx].months.append(month)
            }
        } else {
            let newYear = Year(number: Int(yearName) ?? 0, months: [])
            context.insert(newYear)
            newYear.months.append(month)
            years.append(newYear)
        }
        
        try? context.save()
        payments = []
    }
}
