import SwiftUI
import SwiftData

struct TableView: View {
    @Binding var payments: [Payment]
    
    @State private var incomeSum: Double = 0
    @State private var spendings: Dictionary<PaymentType, Spending> = [:]
    @State private var yearName: String = String(YearName.currentYear)
    @State private var monthName: MonthName = MonthName.january
    
    @State private var isPresentingConfirmCancel: Bool = false
    @State private var isPresentingConfirmSubmit: Bool = false
    @State private var isPresentingAlert = false
    @State private var isPresentingTextFieldPopup = false
    @State private var isPresentingAddPaymentPopup = false
    
    @State private var constantTextPart: String = ""
    @State private var newConstantTextPart: String = ""
    
    @State private var newPaymentDate: String = ""
    @State private var newPaymentMessage: String = ""
    @State private var newPaymentAmount: String = ""
    @State private var newPaymentCategory: PaymentCategory = PaymentCategory(name: "", graphColor: .red)
    @State private var newPaymentType: PaymentType = .personal
    @State private var newPaymentCurrency: Currency = .pln
    
    @State var years: [Year]
    @State var categories: [PaymentCategory]
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        let currency: Currency = payments.count > 0 ? payments[0].currency : .pln
        GeometryReader { reader in
            VStack {
                List {
                    ForEach($payments, id: \.self) { $payment in
                        PaymentRow(
                            payment: $payment,
                            width: .constant(reader.size.width),
                            categories: $categories,
                            onPaymentChanged: { newPayment in calculateSums() },
                            onDelete: {
                                deletePayment(payment: payment)
                            }
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .listStyle(PlainListStyle())
                .frame(maxWidth: .infinity, maxHeight: abs(reader.size.height - 60))
                
                HStack {
                    CurrencyText(title: "Income", value: $incomeSum, currency: currency)
                    Divider()
                    CurrencyText(title: "Personal", value: .constant(spendings[.personal]?.overallSum() ?? 0.0), currency: currency)
                    Divider()
                    CurrencyText(title: "Refunded", value: .constant(spendings[.refunded]?.overallSum() ?? 0.0), currency: currency)
                    Divider()
                    
                    Button("Cancel", role: .destructive) {
                        isPresentingConfirmCancel = true
                    }.confirmationDialog("Are you sure?", isPresented: $isPresentingConfirmCancel) {
                        Button("Discard month") {
                            payments = []
                        }
                    }.dialogIcon(Image(systemName: "x.circle.fill"))
                    
                    DropdownMenu(
                        selectedCategory: String(YearName.currentYear),
                        elements: YearName.allYearsNames,
                        onChange: Binding(
                            get: {{newValue in yearName = newValue}},
                            set: {_ in}
                        )
                    ).frame(maxWidth: 100)
                    
                    DropdownMenu(
                        selectedCategory: MonthName.january.name,
                        elements: MonthName.allCasesNames,
                        onChange: Binding(
                            get: {{newValue in monthName = MonthName.nameToType(name: newValue)}},
                            set: {_ in}
                        )
                    ).frame(maxWidth: 100)
                    
                    Button("Add month", role: .destructive) {
                        isPresentingConfirmSubmit = true
                    }.confirmationDialog("Are you sure?", isPresented: $isPresentingConfirmSubmit) {
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
                Button("Edit Messages") {
                    newConstantTextPart = constantTextPart
                    isPresentingTextFieldPopup = true
                }
                
                Button("Add Payment") {
                    isPresentingAddPaymentPopup = true
                }
                
                Text("Currency: " + currency.name)
            }
        }
        .sheet(isPresented: $isPresentingTextFieldPopup) {
                    VStack {
                        Text("Edit Payment Titles")
                            .font(.headline)
                        TextField("Enter new text", text: $newConstantTextPart)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        HStack {
                            Button("Cancel") {
                                isPresentingTextFieldPopup = false
                            }
                            Spacer()
                            Button("Submit") {
                                constantTextPart = newConstantTextPart
                                updateMessages()
                                isPresentingTextFieldPopup = false
                            }
                        }
                        .padding()
                    }
                    .padding()
                }
        .sheet(isPresented: $isPresentingAddPaymentPopup) {
            VStack {
                Text("Add New Payment")
                    .font(.headline)
                    .padding(.bottom, 20)
                
                TextField("Transaction Date (dd-MM-yyyy)", text: $newPaymentDate)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Message", text: $newPaymentMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Amount", text: $newPaymentAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Picker("Category", selection: $newPaymentCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category.name)
                    }
                }
                .padding()
                
                Picker("Type", selection: $newPaymentType) {
                    ForEach(PaymentType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized)
                    }
                }
                .padding()
                
                Picker("Currency", selection: $newPaymentCurrency) {
                    ForEach(Currency.allCases, id: \.self) { currency in
                        Text(currency.name)
                    }
                }
                .padding()
                
                HStack {
                    Button("Cancel") {
                        isPresentingAddPaymentPopup = false
                    }
                    Spacer()
                    Button("Add Payment") {
                        addNewPayment()
                        isPresentingAddPaymentPopup = false
                    }
                }
                .padding()
            }
            .padding()
        }
        .onAppear(perform: {
            calculateSums()
        })
        .padding(.top, 1)
        .alert("Every category has to be filled", isPresented: $isPresentingAlert) {
            Button("OK", role: .cancel) { }
        }
        .dialogIcon(Image(systemName: "x.circle.fill"))
    }
    
    private func addNewPayment() {
        guard let amount = Double(newPaymentAmount) else { return }
        
        let newPayment = Payment(
            date: Payment.dateFromString(newPaymentDate) ?? Date(),
            message: newPaymentMessage,
            amount: amount,
            currency: newPaymentCurrency,
            category: newPaymentCategory,
            type: newPaymentType
        )
        payments.append(newPayment)
        calculateSums()
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
            for paymentCategory in categories {
                temp[paymentCategory] = 0.0
            }
            
            output[paymentType] = Spending(sums: temp)
        }
        
        return output
    }
    
    private func deletePayment(payment: Payment) {
        payments.removeAll(where: { $0.id == payment.id })
        calculateSums()
    }
    
    private func addMonth(currency: Currency) {
        for payment in payments {
            if payment.category.name == "" {
                isPresentingAlert = true
                return
            }
        }
        
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
    
    private func updateMessages() {
        for index in payments.indices {
            payments[index].message = payments[index].message.replacingOccurrences(of: constantTextPart, with: "")
        }
    }
}

#Preview {
    TableView(payments: .constant([]), years: [], categories: [])
}
