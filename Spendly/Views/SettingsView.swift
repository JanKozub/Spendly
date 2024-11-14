import Foundation
import SwiftUI
import SwiftData

struct SettingsView: View {
    @Binding var tabSwitch: TabSwitch
    @State private var userInput: String = ""
    @State var context: ModelContext
    
    @Binding var categories: [PaymentCategory]
    
    @State private var genericErrorShown: Bool = false
    @State private var genericErrorMessage: String = ""
    
    var body: some View {
        HStack {
            VStack {
                Button(action: { tabSwitch = .main })
                {Text("Go Back").font(Font.system(size: 20)).frame(maxWidth: .infinity, minHeight: 100)}
                
                Button(action: {
                    try? context.delete(model: Year.self)
                    try? context.delete(model: Month.self)
                    try? context.delete(model: Payment.self)
                    try? context.delete(model: PaymentCategory.self)
                    try? context.save()
                })
                {Text("Delete Data").font(Font.system(size: 20)).frame(maxWidth: .infinity, minHeight: 100)}
                
                Button(action: {
                    try? context.delete(model: PaymentCategory.self)
                    for cat in SettingsView.getDefaultCategories() {
                        context.insert(cat)
                    }
                    try? context.save()
                })
                {Text("Clear And Load Default Categories").font(Font.system(size: 20)).frame(maxWidth: .infinity, minHeight: 100)}
                
                Button(action: {
                    do {
                        try DataExportService.exportToJSON(context: context)
                    } catch {
                        genericErrorMessage = error.localizedDescription
                        genericErrorShown.toggle()
                    }
                })
                {Text("Save Data To Json").font(Font.system(size: 20)).frame(maxWidth: .infinity, minHeight: 100)}
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).padding()
            
            Divider()
            
            VStack {
                HStack {
                    TextField("Enter text here", text: $userInput).textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        context.insert(PaymentCategory(name: userInput,
                            graphColor: NSColor(
                                red: CGFloat.random(in: 0...1),
                                green: CGFloat.random(in: 0...1),
                                blue: CGFloat.random(in: 0...1),
                                alpha: 1.0
                            )))
                        try? context.save()
                        userInput = ""
                    }) {
                        Text("Submit")
                    }
                }.frame(alignment: .top).padding()
                List {
                    ForEach($categories, id: \.self) { $category in
                            HStack {
                                Text(category.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button("Delete") {
                                    if let index = categories.firstIndex(where: { $0 == category }) {
                                        context.delete(categories[index])
                                        categories.remove(at: index)
                                    }
                                }
                            }
                        }
                }.frame(alignment: .top)
            }
        }.alert(isPresented: $genericErrorShown) {
            Alert(title: Text(genericErrorMessage))
        }
    }
    
    static func getDefaultCategories() -> [PaymentCategory] {
        return [
            PaymentCategory(name: "Entertainment", r: 240.0/255, g: 68.0/255, b: 0),
            PaymentCategory(name: "Groceries", r: 240.0/255, g: 26.0/255, b: 0),
            PaymentCategory(name: "For Parents", r: 112.0/255, g: 91.0/255, b: 56.0/255),
            PaymentCategory(name: "Fuel", r: 112.0/255, g: 56.0/255, b: 69.0/255),
            PaymentCategory(name: "Gift", r: 112.0/255, g: 82.0/255, b: 56.0/255),
            PaymentCategory(name: "New Things", r: 112.0/255, g: 62.0/255, b: 56.0/255),
            PaymentCategory(name: "Going out", r: 240.0/255, g: 125.0/255, b: 80.0/255),
            PaymentCategory(name: "Subscriptions", r: 240.0/255, g: 110.0/255, b: 0.0/255),
            PaymentCategory(name: "Transport", r: 240.0/255, g: 0.0/255, b: 55.0/255),
            PaymentCategory(name: "Other", r: 240.0/255, g: 164.0/255, b: 34.0/255),
        ]
    }
}
