//
//  SpendingsView.swift
//  LifeManager
//
//  Created by Jan Kozub on 15/06/2024.
//

import SwiftUI
import Foundation
import SwiftData
import Charts

struct SpendingsView: View {
    @State private var payments: [Payment] = []
    @State private var importing: Bool = false
    @State private var displayMonth: String = MonthName.currentMonth.name
    @State private var displayYear: String = "Year"
    @State private var currency: Currency = .pln
    
    @State private var top10Payments = ["1.test", "2.test", "3.test", "4.test", "5.test", "6.test", "7.test", "8.test", "9.test", "10.test"]
    @State private var chartEntries: [ChartEntry] = []
    
    @Query private var years: [Year]
    @Query private var categories: [PaymentCategory]
    
    @State private var currentYear: Year?
    @State private var isShowingSettingsWindow = false
    @State var foregroundScale: KeyValuePairs<String, Color> = KeyValuePairs<String, Color>()
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        if (payments.isEmpty) {
            GeometryReader { reader in
                VStack {
                    HStack {
                        switch displayYear {
                        case "Year":
                            Chart(chartEntries) { entry in
                                ForEach(categories) { category in
                                    BarMark(
                                        x: .value("Shape Type", entry.monthName.name),
                                        y: .value("Total Count", entry.sums[category] ?? 0.0)
                                    ).foregroundStyle(by: .value("Shape Color", category.name))
                                }
                            }.chartForegroundStyleScale(range: graphColors(for: categories))
                        case "Month":
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
                        default: HStack {}
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: reader.size.height * 0.5, alignment: .top)
                    
                    Divider()
                    
                    HStack {
                        VStack {
                            List {
                                ForEach(top10Payments, id: \.self) { el in
                                    Text(el)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: reader.size.height * 0.5, alignment: .top)
                        Divider()
                        VStack {
                            Button(action: {
                                let panel = NSOpenPanel()
                                panel.begin { result in
                                    if result == .OK, let fileURL = panel.url {
                                        payments = DataParser.loadSantanderPaymentsFromCSV(file: fileURL)
                                    }
                                }
                            }) {Text("Import new month").frame(maxWidth: .infinity, minHeight: reader.size.height * 0.15)}
                            
                            Button(action: {
                                
                            }) {Text("Edit this month").frame(maxWidth: .infinity, minHeight: reader.size.height * 0.15)}
                            
                            Button(action: {
                                isShowingSettingsWindow = true
                            }) {Text("Settings").frame(maxWidth: .infinity, minHeight: reader.size.height * 0.15)}
                                .sheet(isPresented: $isShowingSettingsWindow) {
                                    SettingsWindow(context: context, prepareChartEntries: prepareChartEntries)
                                }
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
                            prepareChartEntries()
                        }},
                        set: {_ in}
                    )).frame(width: 150)
                    
                    DropdownMenu(selectedCategory: displayYear, elements: ["Year", "Month"], onChange: Binding(
                        get: {{ newValue in
                            displayYear = newValue
                            prepareChartEntries()
                        }},
                        set: {_ in}
                    )).frame(width: 150)
                    
                    DropdownMenu(selectedCategory: currency.name, elements: Currency.allCasesNames, onChange: Binding(
                        get: {{ newValue in
                            currency = Currency.nameToType(name: newValue)
                            prepareChartEntries()
                        }},
                        set: {_ in}
                    )).frame(width: 150)
                }
            }.onAppear(perform: {
                prepareChartEntries()
            })
            .padding(.all)
        } else {
            TableView(payments: $payments,
                      years: .constant(years),
                      categories: .constant(PaymentCategory.convertToStringArray(inputArray: categories))
            )
        }
    }
    
    private func prepareChartEntries() {
        chartEntries = []
        if let year = years.first(where: {$0.number == YearName.currentYear}) {
            if displayYear == "Year" {
                for monthName in MonthName.allCases {
                    var chartEntry = ChartEntry(monthName: monthName, categories: categories)
                    
                    for month in year.months.filter({$0.monthName == monthName}) {
                        for type in PaymentType.allCases {
                            chartEntry.paymentType = type
                            
                            addSumsToEntry(entry: &chartEntry, sums: month.spendings[type]!.sums, currency: month.currency)
                        }
                    }
                    chartEntries.append(chartEntry)
                }
            } else if displayYear == "Month" {
                if let month = year.months.first(where: {$0.monthName.name == displayMonth}) {
                    for type in PaymentType.allCases {
                        var chartEntry = ChartEntry(monthName: MonthName.nameToType(name: displayMonth), paymentType: type, categories: categories)
                        
                        addSumsToEntry(entry: &chartEntry, sums: month.spendings[type]!.sums, currency: month.currency)
                        chartEntries.append(chartEntry)
                    }
                }
            }
        }
    }
    
    private func exchangeValue(value: Optional<Double>, fromCur: Currency) -> Double {
        return (value ?? 0) * Currency.exchangeRate(from: fromCur, to: currency)
    }
    
    private func addSumsToEntry(entry: inout ChartEntry, sums: Dictionary<String, Double>, currency: Currency) {
        for category in categories {
            entry.sums[category]! += exchangeValue(value: sums[category.name], fromCur: currency)
        }
    }
    
    func graphColors(for input: [PaymentCategory]) -> [Color] {
        var returnColors = [Color]()
        for _ in input {
            returnColors.append(Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1)))
        }
        return returnColors
    }
}

#Preview {
    SpendingsView().padding()
}
