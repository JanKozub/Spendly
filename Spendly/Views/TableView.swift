import SwiftUI
import SwiftData

struct TableView: View {
    @Environment(\.modelContext) private var context
    @Binding var payments: [Payment]
  
    @State var years: [Year]
    @State var categories: [PaymentCategory]
    @State var expenseGroups: [TypeAndCurrencyGroup: Double] = [:]
    @State private var incomeSum: Double = 0
    @State private var month: Month = Month(monthName: .january, yearNum: YearType.currentYear)
    
    @State private var isMonthCompleteAlert = false
    @State private var isEditPaymentNamesShown = false
    @State private var isAddPaymentShown = false
    
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
                
                TableBottomBar(payments: $payments, incomeSum: $incomeSum, monthName: $month.monthName,
                               yearNum: $month.yearNum, expenseGroups: $expenseGroups, addMonth: addMonth)
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
        }.onAppear(perform: {
            Task {
                do {
                    try await month.setPayments(newPayments: payments)
                } catch {
                    // TODO Handling
                }
            }
            
            calculateIncome()
        })
        .padding(.top, 1)
        .alert("Every category has to be filled", isPresented: $isMonthCompleteAlert) {
            Button("OK", role: .cancel) { }
        }.dialogIcon(Image(systemName: "x.circle.fill"))
    }
    
    private func calculateIncome() {
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
    
    private func addMonth() async throws { //TODO finish cleaning this method
        if (hasAnyPaymentEmptyCategory()) {
            isMonthCompleteAlert = true
            return
        }
        
        context.insert(month)
        addPaymentsToContext()
        
        if let yearIdx = years.firstIndex(where: {$0.number == month.yearNum}) {
            if let monthIdx = years[yearIdx].months.firstIndex(where: { $0.monthName == month.monthName }) {
                years[yearIdx].months[monthIdx] = month //TODO Popup about overwriting month
            } else {
                years[yearIdx].months.append(month)
            }
        } else {
            let newYear = Year(number: month.yearNum, months: [])
            context.insert(newYear)
            newYear.months.append(month)
            years.append(newYear)
        }
        
        try? context.save()
        payments = []
    }
    
    private func hasAnyPaymentEmptyCategory() -> Bool {
        return payments.first(where: { $0.category.name.isEmpty }) == nil
    }
    
    private func addPaymentsToContext() {
        for payment in payments {
            if payment.modelContext != context {
                context.insert(payment)
            }
            month.payments.append(payment)
        }
    }
}
