import Charts
import UniformTypeIdentifiers
import SwiftUI

struct MainView: View {
    @Binding var payments: [Payment]
    @Binding var isShowingSettings: Bool
    
    @State private var displayMonth: String = MonthName.currentMonth.name
    @State private var displayYear: String = "Year"
    @State private var currency: CurrencyName = .pln
    @State private var top10Payments: [Payment] = []
    
    @State var years: [Year]
    @State var categories: [PaymentCategory]
    @State var savedPayments: [Payment]
    @State private var chartEntries: [ChartEntry] = []
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                HStack {
                    switch displayYear {
                    case "Year":
                        getYearChart()
                    case "Month":
                        getMonthChart()
                    default: HStack {}
                    }
                }.frame(maxWidth: .infinity, maxHeight: reader.size.height * 0.5, alignment: .top)
                
                HStack {
                    List {
                        ForEach(top10Payments) { el in
                            Text(el.message + "  " + String(format: "%.2f", abs(el.amount)))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: reader.size.height * 0.5, alignment: .top)
                    
                    VStack {
                        Button(action: openFilesExplorer)
                        {Text("Import new month").frame(maxWidth: .infinity, minHeight: reader.size.height * 0.15)}
                        
                        Button(action: {})
                        {Text("Edit this month").frame(maxWidth: .infinity, minHeight: reader.size.height * 0.15)}
                        
                        Button(action: {isShowingSettings = true})
                        {Text("Settings").frame(maxWidth: .infinity, minHeight: reader.size.height * 0.15)}
                    }
                    .frame(maxWidth: .infinity, maxHeight: reader.size.height * 0.5, alignment: .top)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                DropdownMenu(selectedCategory: displayMonth, elements: MonthName.allCasesNames, onChange: Binding(
                    get: {{ newValue in
                        displayMonth = newValue
                        refreshChart()
                    }},
                    set: {_ in}
                )).frame(width: 150)
                
                DropdownMenu(selectedCategory: displayYear, elements: ["Year", "Month"], onChange: Binding(
                    get: {{ newValue in
                        displayYear = newValue
                        refreshChart()
                    }},
                    set: {_ in}
                )).frame(width: 150)
                
                DropdownMenu(selectedCategory: currency.name, elements: CurrencyName.allCasesNames, onChange: Binding(
                    get: {{ newValue in
                        currency = CurrencyName.nameToType(name: newValue)
                        refreshChart()
                    }},
                    set: {_ in}
                )).frame(width: 150)
            }
        }.onAppear(perform: {
            refreshChart()
        })
        .padding(.all)
    }
    
    private func refreshChart() {
        savedPayments.sort(by: { $0.amount < $1.amount} ) // Getting lowest value because expenses have minus sign
        top10Payments = Array(savedPayments.prefix(15))
        
        chartEntries = []
        if let year = years.first(where: {$0.number == YearType.currentYear}) {
            if displayYear == "Year" {
                for monthName in MonthName.allCases {
                    var chartEntry = ChartEntry(monthName: monthName, categories: categories)
                    
                    for month in year.months.filter({$0.monthName == monthName}) {
                        for type in PaymentType.allCases {
                            chartEntry.paymentType = type
                            
                            do {
                                try addSumsToEntry(entry: &chartEntry, month: month, type: type)
                            } catch {
                                // TODO handle error
                            }
                        }
                    }
                    chartEntries.append(chartEntry)
                }
            } else if displayYear == "Month" {
                if let month = year.months.first(where: {$0.monthName.name == displayMonth}) {
                    for type in PaymentType.allCases {
                        var chartEntry = ChartEntry(monthName: MonthName.nameToType(name: displayMonth), paymentType: type, categories: categories)
                        
                        do {
                            try addSumsToEntry(entry: &chartEntry, month: month, type: type)
                        } catch {
                            //TODO handle error
                        }
                        
                        chartEntries.append(chartEntry)
                    }
                }
            }
        }
    }
    
    private func getYearChart() -> some View {
        return Chart(chartEntries) { entry in
            ForEach(categories) { category in
                BarMark(
                    x: .value("Shape Type", entry.monthName.name),
                    y: .value("Total Count", entry.sums[category] ?? 0.0)
                ).foregroundStyle(by: .value("Shape Color", category.name))
            }
        }.chartForegroundStyleScale(range: graphColors(for: categories))
    }
    
    private func getMonthChart() -> some View {
        HStack {
            ForEach(PaymentType.allCases) { type in
                Chart(chartEntries) { entry in
                    if entry.paymentType == type {
                        ForEach(categories) { category in
                            SectorMark(
                                angle: .value(Text(verbatim: category.name), entry.sums[category] ?? 0),
                                angularInset: 3
                            ).foregroundStyle(by: .value(Text(verbatim: category.name), category.name))
                        }
                    }
                }
            }
        }
    }
    
    private func openFilesExplorer() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowedContentTypes = [UTType.commaSeparatedText]
        panel.begin { result in
            if result == .OK {
                do {
                    payments = try DataParseService.loadDataFromBank(files: panel.urls)
                } catch {
                    //TODO handling
                }
            }
        }
    }
    
    private func addSumsToEntry(entry: inout ChartEntry, month: Month, type: PaymentType) throws{
        for category in categories {
            entry.sums[category]! += try month.getExpensesForGroup(paymentType: type, paymentCategory: category, currency: currency)
        }
    }
    
    func graphColors(for input: [PaymentCategory]) -> [Color] {
        var returnColors = [Color]()
        for cat in input {
            returnColors.append(cat.graphColor.color)
        }
        return returnColors
    }
}

#Preview {
    MainView(payments: .constant([]), isShowingSettings: .constant(false), years: [], categories: [], savedPayments: [])
}
