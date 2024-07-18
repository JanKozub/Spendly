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
    @State private var payments: [Payment] = [Payment]()
    @State private var importing: Bool = false
    @State private var displayMonth: String = MonthName.currentMonth.name
    @State private var displayYear: String = "Month"
    @State private var currency: Currency = .pln
    
    @State private var top10Payments = ["1.test", "2.test", "3.test", "4.test", "5.test", "6.test", "7.test", "8.test", "9.test", "10.test"]
    @State private var chartEntries: [ChartEntry] = []
    
    @Query private var years: [Year]
    @State private var currentYear: Year?;
    @State private var isShowingSettingsWindow = false
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        if (payments.isEmpty) {
            GeometryReader { reader in
                VStack {
                    HStack {
                        switch displayYear {
                        case "Year":
                            Chart(chartEntries) { entry in
                                ForEach(PaymentCategory.allCases) { category in
                                    BarMark(
                                        x: .value("Shape Type", entry.monthName.name),
                                        y: .value("Total Count", entry.sums[category] ?? 0.0)
                                    ).foregroundStyle(by: .value("Shape Color", category.name))
                                }
                            }
                            .chartForegroundStyleScale(["Food": .red, "Entertainment": .yellow, "Other": .blue])
                        case "Month":
                            HStack {
                                ForEach(PaymentType.allCases) { type in
                                    Chart(chartEntries) { entry in
                                        if entry.paymentType == type {
                                            ForEach(PaymentCategory.allCases) { category in
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
                                        payments = Payment.loadSantanderPaymentsFromCSV(file: fileURL)
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
                    DropdownMenu(selectedCategory: displayMonth, elements: MonthName.allCasesNames, onChange: { newValue in
                        displayMonth = newValue
                        prepareChartEntries()
                    }).frame(width: 150)
                    
                    DropdownMenu(selectedCategory: displayYear, elements: ["Year", "Month"], onChange: { newValue in
                        displayYear = newValue
                        prepareChartEntries()
                    }).frame(width: 150)
                    
                    DropdownMenu(selectedCategory: currency.name, elements: Currency.allCasesNames, onChange: { newValue in
                        currency = Currency.nameToType(name: newValue)
                        prepareChartEntries()
                    }).frame(width: 150)
                }
            }.onAppear(perform: {
                prepareChartEntries()
            })
            .padding(.all)
        } else {
            TableView(payments: $payments, years: .constant(years))
        }
    }
    
    private func prepareChartEntries() {
        chartEntries = []
        if let year = years.first(where: {$0.number == YearName.currentYear}) {
            if displayYear == "Year" {
                for monthName in MonthName.allCases {
                    var chartEntry = ChartEntry(monthName: monthName)
                    
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
                        var chartEntry = ChartEntry(monthName: MonthName.nameToType(name: displayMonth), paymentType: type)
                        
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
    
    private func addSumsToEntry(entry: inout ChartEntry, sums: Dictionary<PaymentCategory, Double>, currency: Currency) {
        for category in PaymentCategory.allCases {
            entry.sums[category]! += exchangeValue(value: sums[category], fromCur: currency)
        }
    }
    
    struct SettingsWindow: View {
        @Environment(\.presentationMode) var presentationMode
        var context: ModelContext
        var prepareChartEntries: () -> Void
        
        var body: some View {
            VStack(spacing: 20) {
                Button("Delete data") {
                    try? context.delete(model: Year.self)
                    prepareChartEntries()
                    presentationMode.wrappedValue.dismiss()
                }
                
                Button("Save data to json") {
                    do {
                        try DataExporter.exportToJSON(context: context)
                    } catch {
                        print("Failed to save data in file")
                    }
                }
                
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
        }
    }
}

#Preview {
    SpendingsView().padding()
}
