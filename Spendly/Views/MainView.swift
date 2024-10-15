import Charts
import UniformTypeIdentifiers
import SwiftUI

struct MainView: View {
    @Binding var payments: [Payment]
    @Binding var tabSwitch: TabSwitch
    
    @State private var displayMonth: MonthName = MonthName.currentMonth
    @State private var chartType: String = "Year"
    @State private var currency: CurrencyName = .pln
    @State private var top10Payments: [Payment] = []
    
    @State private var genericErrorShown: Bool = false
    @State private var genericErrorMessage: String = ""
    
    @State var years: [Year]
    @State var categories: [PaymentCategory]
    @State var savedPayments: [Payment]
    @State private var chartEntries: [ChartEntry] = []
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                HStack {
                    switch chartType {
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
                        
                        Button(action: {tabSwitch = .settings})
                        {Text("Settings").frame(maxWidth: .infinity, minHeight: reader.size.height * 0.15)}
                    }
                    .frame(maxWidth: .infinity, maxHeight: reader.size.height * 0.5, alignment: .top)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                DropdownMenu(selected: displayMonth.name, elements: MonthName.allCasesNames, onChange: { newValue in
                    displayMonth = MonthName.nameToType(name: newValue)
                    refreshChart()
                }).frame(width: 150)
                
                DropdownMenu(selected: chartType, elements: ["Year", "Month"], onChange: { newValue in
                    chartType = newValue
                    refreshChart()
                }).frame(width: 150)
                
                DropdownMenu(selected: currency.name, elements: CurrencyName.allCasesNames, onChange: { newValue in
                    currency = CurrencyName.nameToType(name: newValue)
                    refreshChart()
                }).frame(width: 150)
            }
        }.onAppear {
            refreshChart()
        }.alert(isPresented: $genericErrorShown) {
            Alert(title: Text(genericErrorMessage))
        }.padding(.all)
    }
    
    private func refreshChart() {
        top10Payments = getTopPayments()
        
        chartEntries = []
        let year = years.first(where: {$0.number == YearType.currentYear})
        if year == nil {
            return
        }
        
        if chartType == "Year" {
            for monthName in MonthName.allCases {
                var chartEntry = ChartEntry(monthName: monthName, categories: categories)
                
                for month in year!.months.filter({$0.monthName == monthName}) {
                    for type in PaymentType.allCases {
                        chartEntry.paymentType = type
                        
                        do {
                            try addSumsToEntry(entry: &chartEntry, month: month, type: type)
                        } catch {
                            genericErrorMessage = error.localizedDescription
                            genericErrorShown = true
                        }
                    }
                }
                chartEntries.append(chartEntry)
            }
        } else if chartType == "Month" {
            let month = year!.months.first(where: {$0.monthName == displayMonth})
            if month == nil {
                return
            }
            
            for type in PaymentType.allCases {
                var chartEntry = ChartEntry(monthName: displayMonth, paymentType: type, categories: categories)
                
                do {
                    try addSumsToEntry(entry: &chartEntry, month: month!, type: type)
                } catch {
                    genericErrorMessage = error.localizedDescription
                    genericErrorShown = true
                }
                
                chartEntries.append(chartEntry)
            }
        }
    }
    
    private func getTopPayments() -> [Payment] {
        savedPayments.sort(by: { $0.amount < $1.amount} ) //TODO filter only payments / not income and take top
        return Array(savedPayments.prefix(15))
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
            if result != .OK {
                return
            }
            
            do {
                payments = try DataParseService.loadDataFromBank(files: panel.urls)
                tabSwitch = .table
            } catch {
                genericErrorMessage = error.localizedDescription
                genericErrorShown = true
            }
        }
    }
    
    private func addSumsToEntry(entry: inout ChartEntry, month: Month, type: PaymentType) throws {
        for category in categories {
            entry.sums[category, default: 0.0] += try month.getExpensesForGroup(type: type, category: category, currency: currency)
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
