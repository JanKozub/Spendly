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
            PaymentCategory(name: "Entertainment", graphColor:
                                NSColor(red: 240.0/255, green: 68.0/255, blue: 0, alpha: 1.0)),
            PaymentCategory(name: "Groceries", graphColor:
                                NSColor(red: 240.0/255, green: 26.0/255, blue: 0, alpha: 1.0)),
            PaymentCategory(name: "For Parents", graphColor:
                                NSColor(red: 112.0/255, green: 91.0/255, blue: 56.0/255, alpha: 1.0)),
            PaymentCategory(name: "Fuel", graphColor:
                                NSColor(red: 112.0/255, green: 56.0/255, blue: 69.0/255, alpha: 1.0)),
            PaymentCategory(name: "Gift", graphColor:
                                NSColor(red: 112.0/255, green: 82.0/255, blue: 56.0/255, alpha: 1.0)),
            PaymentCategory(name: "New Things", graphColor:
                                NSColor(red: 112.0/255, green: 62.0/255, blue: 56.0/255, alpha: 1.0)),
            PaymentCategory(name: "Going out", graphColor:
                                NSColor(red: 240.0/255, green: 125.0/255, blue: 80.0/255, alpha: 1.0)),
            PaymentCategory(name: "Subscriptions", graphColor:
                                NSColor(red: 240.0/255, green: 110.0/255, blue: 0, alpha: 1.0)),
            PaymentCategory(name: "Transport", graphColor:
                                NSColor(red: 240.0/255, green: 0, blue: 55.0/255, alpha: 1.0)),
            PaymentCategory(name: "Other", graphColor:
                                NSColor(red: 245.0/255, green: 164.0/255, blue: 34.0/255, alpha: 1.0)),
        ]
    }
}
