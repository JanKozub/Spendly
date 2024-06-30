//
//  SpendingsView.swift
//  LifeManager
//
//  Created by Jan Kozub on 15/06/2024.
//

import SwiftUI
import Foundation

struct Payment: Identifiable {
    var id = UUID();
    var issuedDate: String;
    var transactionDate: String;
    var title: String;
    var message: String;
    var accountNumber: Int;
    var amount: Double;
    var balance: Double;
}

struct SpendingsView: View {
    @State private var payments = [Payment]()
    @State private var importing = false
    
    var body: some View {
        VStack {
            if (payments.isEmpty) {
                Button("Import") {
                    let panel = NSOpenPanel()
                    panel.begin { result in
                        if result == .OK, let fileURL = panel.url {
                            loadSantanderCSV(file: fileURL)
                        }
                    }
                }
            } else {
                List(payments) { payment in
                    HStack {
                        Text("Issued Date: \(payment.issuedDate)").frame(maxWidth: .infinity, alignment: .center)
                        Text("Transaction Date: \(payment.transactionDate)").frame(maxWidth: .infinity, alignment: .center)
                        Text("Title: \(payment.title)").frame(maxWidth: .infinity, alignment: .center)
                        Text("Message: \(payment.message)").frame(maxWidth: .infinity, alignment: .center)
                        Text("Account number: \(payment.accountNumber)").frame(maxWidth: .infinity, alignment: .center)
                        Text("Amount: \(payment.amount)").frame(maxWidth: .infinity, alignment: .center)
                        Text("Balance: \(payment.balance)").frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .background(Color.red)
                .frame( maxWidth: .infinity)
                .edgesIgnoringSafeArea(.all)
                .listStyle(PlainListStyle())
            }
        }
    }
    
    private func loadSantanderCSV(file: URL) {
        do {
            let fileContent = try String(contentsOf: file, encoding: .utf8)
            let rows = fileContent.components(separatedBy: "\n")
            rows.dropFirst().forEach { line in
                let columns = line.replacingOccurrences(of: ",", with: ".").components(separatedBy: ";");
                if columns.count == 9 {
                    let payment = Payment(
                        issuedDate: columns[0],
                        transactionDate: columns[1],
                        title: columns[2],
                        message:columns[3],
                        accountNumber: Int(columns[4]) ?? -1,
                        amount: Double(columns[5]) ?? -1,
                        balance: Double(columns[6]) ?? -1
                    )
                    
                    payments.append(payment);
                }
            }
        } catch {
            print("error: \(error)")
        }
    }
}

#Preview {
    SpendingsView()
}
