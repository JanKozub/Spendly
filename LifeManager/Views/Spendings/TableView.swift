//
//  TableView.swift
//  LifeManager
//
//  Created by Jan Kozub on 02/07/2024.
//

import SwiftUI
import SwiftData

struct TableView: View {
    @Binding var payments: [Payment]
    @Binding var years: [Year]
    @State private var incomeSum: Double = 0
    @State private var spendings: Dictionary<PaymentType, Spending> = [:]
    @State private var yearName: String = String(YearName.currentYear)
    @State private var monthName: MonthName = MonthName.january
    
    @State private var isPresentingConfirm: Bool = false
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        let currency: Currency = payments.count > 0 ? payments[0].currency : .pln
        GeometryReader { reader in
            VStack {
                HStack {
                    HeaderText(text: "Issued(D)", percentage: 0.08, size: reader.size)
                    HeaderText(text: "Transaction(D)", percentage: 0.08, size: reader.size)
                    HeaderText(text: "Title", percentage: 0.36, size: reader.size)
                    HeaderText(text: "Message", percentage: 0.18, size: reader.size)
                    HeaderText(text: "Amount", percentage: 0.07, size: reader.size)
                    HeaderText(text: "Balance", percentage: 0.07, size: reader.size)
                    HeaderText(text: "Category", percentage: 0.08, size: reader.size)
                    HeaderText(text: "Type", percentage: 0.08, size: reader.size)
                }
                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .center).padding(3)
                
                List {
                    ForEach($payments, id: \.self) { $payment in
                        PaymentView(payment: $payment, width: .constant(reader.size.width), onPaymentChanged: { newPayment in calculateSums() })
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .listStyle(PlainListStyle())
                .frame(maxWidth: .infinity, maxHeight: abs(reader.size.height - 60))
                
                HStack {
                    CurrencyText(title: "Income", value: $incomeSum, currency: currency)
                    
                    Divider()
                    
                    CurrencyText(title: "Personal", value: .constant(spendings[.personal]?.overallSum() ?? 0.0), currency: currency)
                    CurrencyText(title: "Refunded", value: .constant(spendings[.refunded]?.overallSum() ?? 0.0), currency: currency)
                    
                    Divider()
                    
                    DropdownMenu(selectedCategory: String(YearName.currentYear), elements: YearName.allYearsNames, onChange: Binding(
                        get: {{newValue in yearName = newValue}},
                        set: {_ in}
                    )).frame(maxWidth: 100)
                    
                    DropdownMenu(selectedCategory: MonthName.january.name, elements: MonthName.allCasesNames, onChange: Binding(
                        get: {{newValue in monthName = MonthName.nameToType(name: newValue)}},
                        set: {_ in}
                    )).frame(maxWidth: 100)
                    
                    Button("Add month", role: .destructive) {
                        isPresentingConfirm = true
                    }.confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                        Button("Add/Edit Month") {
                            addMonth(currency: currency)
                        }
                    }.dialogIcon(Image(systemName: "pencil.circle.fill"))
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .center).padding(3)
            }
            .frame(maxWidth: .infinity, maxHeight: reader.size.height)
        }
        .toolbar {
            ToolbarItemGroup {
                Text("Currency: " + currency.name)
            }
        }
        .onAppear(perform: {
            calculateSums()
        })
        .padding(.top, 1)
    }
    
    private func calculateSums() {
        incomeSum = 0
        spendings = initSpendings()
        
        for(_, payment) in payments.enumerated() {
            if payment.amount < 0 {
                spendings[payment.type]?.sums[payment.category]? += abs(payment.amount)
            } else if payment.amount > 0 {
                incomeSum += abs(payment.amount)
            }
        }
    }
    
    private func initSpendings() -> Dictionary<PaymentType, Spending> {
        var output: Dictionary<PaymentType, Spending> = [:]
        
        for paymentType in PaymentType.allCases {
            var temp: Dictionary<PaymentCategory, Double> = [:]
            for paymentCategory in PaymentCategory.allCases {
                temp[paymentCategory] = 0.0
            }
            
            output[paymentType] = Spending(sums: temp)
        }
        
        return output
    }
    
    private func addMonth(currency: Currency) {
        let month = Month(monthName: monthName, currency: currency, payments: [], spendings: spendings, income: incomeSum)
        context.insert(month)
        for payment in payments {
            if payment.modelContext != context {
                context.insert(payment)
            }
            month.payments.append(payment)
        }
        
        if let yearIdx = years.firstIndex(where: {$0.number == Int(yearName) ?? 0}) {
            if let monthIdx = years[yearIdx].months.firstIndex(where: {$0.monthName == monthName && $0.currency == currency}) {
                years[yearIdx].months[monthIdx] = month
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

#Preview {
    TableView(payments: .constant([]), years: .constant([]))
}
