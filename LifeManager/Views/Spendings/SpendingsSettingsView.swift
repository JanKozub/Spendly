import Foundation
import SwiftUI
import SwiftData

struct SpendingsSettingsView: View {
    @Binding var isShowing: Bool
    @State private var userInput: String = ""
    @State var context: ModelContext
    
    @Binding var categories: [PaymentCategory]
    
    var body: some View {
        HStack {
            VStack {
                Button(action: {
                    isShowing = false
                }) 
                {Text("Go Back").font(Font.system(size: 20)).frame(maxWidth: .infinity, minHeight: 100)}
                
                Button(action: {
                    try? context.delete(model: Year.self)
                }) 
                {Text("Delete Data").font(Font.system(size: 20)).frame(maxWidth: .infinity, minHeight: 100)}
                
                Button(action: {
                    try? context.delete(model: PaymentCategory.self)
                    for cat in SpendingsSettingsView.getDefaultCategories() {
                        context.insert(cat)
                    }
                    try? context.save()
                })
                {Text("Clear And Load Default Categories").font(Font.system(size: 20)).frame(maxWidth: .infinity, minHeight: 100)}
                
                Button(action: {
                    DataExportService.exportToJSON(context: context)
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
        }
    }
    
    static func getDefaultCategories() -> [PaymentCategory] {
        return [
            PaymentCategory(name: "Entertainment", graphColor: .red),
            PaymentCategory(name: "Groceries", graphColor: .blue),
            PaymentCategory(name: "For Parents", graphColor: .green),
            PaymentCategory(name: "Fuel", graphColor: .red),
            PaymentCategory(name: "Gift", graphColor: .red),
            PaymentCategory(name: "New Things", graphColor: .red),
            PaymentCategory(name: "Going out", graphColor: .red),
            PaymentCategory(name: "Subscriptions", graphColor: .red),
            PaymentCategory(name: "Transport", graphColor: .red),
            PaymentCategory(name: "Other", graphColor: .red),
        ]
    }
}
