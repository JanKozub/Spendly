//
//  TableView.swift
//  LifeManager
//
//  Created by Jan Kozub on 02/07/2024.
//

import SwiftUI
import SwiftData

struct TableView: View {
    @Binding var payments: [Payment];
    @Binding var years: [Year]
    @State private var incomeSum: Double = 0
    @State private var spendings: Dictionary<PaymentType, Spending> = [:]
    @State private var yearName: String = String(Year.currentYear())
    @State private var monthName: MonthName = MonthName.january;
    
    @Environment(\.modelContext) private var context
    
    @State private var isPresentingConfirm: Bool = false
    
    var body: some View {
        let currency = payments.count > 0 ? payments[0].currency : ""
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
                    ForEach($payments, id: \.self) {$payment in
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
                    CurrencyText(title: "Other", value: .constant(spendings[.other]?.overallSum() ?? 0.0), currency: currency)
                    
                    Divider()
                    
                    DropdownMenu(selectedCategory: String(Year.currentYear()), elements: Year.allYears(), onChange: { newValue in
                        yearName = newValue
                    }).frame(maxWidth: 100)
                    
                    DropdownMenu(selectedCategory: MonthName.january.name, elements: MonthName.allCasesNames, onChange: { newValue in
                        monthName = MonthName.nameToType(name: newValue)
                    }).frame(maxWidth: 100)
                    
                    Button("Add month", role: .destructive) {
                        isPresentingConfirm = true
                    }.confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                        let month = Month(monthName: monthName, currency: currency, payments: payments, spendings: spendings, income: incomeSum)
                        
                        if let yearIdx = years.firstIndex(where: {$0.number == Int(yearName) ?? 0}) {
                            if let monthIdx = years[yearIdx].months.firstIndex(where: {$0.monthName == monthName && $0.currency == currency}) {
                                Button("Edit existing month?") {
                                    years[yearIdx].months[monthIdx] = month
                                    try? context.save()
                                    payments = []
                                }
                            } else {
                                Button("Add new month?") {
                                    years[yearIdx].months.append(month)
                                    try? context.save()
                                    payments = []
                                }
                            }
                        } else {
                            Button("Add new year with this month?") {
                                context.insert(Year(number: Int(yearName) ?? 0, months: [month]))
                                payments = []
                            }
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
                Text("Currency: " + currency)
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
    
    private func initSpendings() -> Dictionary<PaymentType, Spending>{ //TODO optimize
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
}

#Preview {
    TableView(payments: .constant([]), years: .constant([]))
}
