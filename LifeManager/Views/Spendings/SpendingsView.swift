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
    @State private var payments = [Payment]()
    @State private var importing = false
    
    @State private var top10Payments = ["1.test", "2.test", "3.test", "4.test", "5.test", "6.test", "7.test", "8.test", "9.test", "10.test"]
    @State private var chartEntries: [ChartEntry] = []
    
    @Query private var years: [Year]
    @State private var currentYear: Year?;
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        if (payments.isEmpty) {
            GeometryReader { reader in
                VStack {
                    HStack {
                        Chart {
                            ForEach(chartEntries, id: \.self) { entry in
                                BarMark(
                                    x: .value("Shape Type", entry.monthName.name),
                                    y: .value("Total Count", entry.foodSum)
                                ).foregroundStyle(by: .value("Shape Color", "Food"))
                                BarMark(
                                    x: .value("Shape Type", entry.monthName.name),
                                    y: .value("Total Count", entry.entertainmentSum)
                                ).foregroundStyle(by: .value("Shape Color", "Entertainment"))
                                BarMark(
                                    x: .value("Shape Type", entry.monthName.name),
                                    y: .value("Total Count", entry.otherSum)
                                ).foregroundStyle(by: .value("Shape Color", "Other"))
                            }
                        }
                        .chartForegroundStyleScale(["Food": .red, "Entertainment": .yellow, "Other": .blue])
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
                                print("Button tapped!")
                            }) {Text("Edit this month").frame(maxWidth: .infinity, minHeight: reader.size.height * 0.15)}
                            
                            Button(action: {
                                try? context.delete(model: Year.self)
                            }) {Text("Settings").frame(maxWidth: .infinity, minHeight: reader.size.height * 0.15)}
                        }
                        .frame(maxWidth: .infinity, maxHeight: reader.size.height * 0.5, alignment: .top)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup {
                    DropdownMenu(selectedCategory: "Other", elements: ["Other", "test2"]).frame(width: 150)
                }
            }.onAppear(perform: {
                prepareChartEntries()
            })
            .padding(.all)
        } else {
            TableView(payments: $payments, years: .constant(years))
        }
    }
    
    func prepareChartEntries() {
        if let year = years.first(where: {$0.number == Year.currentYear()}) {
            for monthName in MonthName.allCases {
                var chartEntry = ChartEntry(monthName: monthName, foodSum: 0, entertainmentSum: 0, otherSum: 0)
                
                for month in year.months {
                    if month.monthName == monthName {
                        for type in PaymentType.allCases {
                            chartEntry.foodSum += month.spendings[type]?.sums[.food] ?? 0.0
                            chartEntry.entertainmentSum += month.spendings[type]?.sums[.entertainmanet] ?? 0.0
                            chartEntry.otherSum += month.spendings[type]?.sums[.other] ?? 0.0
                        }
                    }
                }
                chartEntries.append(chartEntry)
            }
        }
    }
}

#Preview {
    SpendingsView().padding()
}
