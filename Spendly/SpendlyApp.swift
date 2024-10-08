import SwiftUI
import SwiftData

@main
struct SpendlyApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Year.self, Month.self, Payment.self, PaymentCategory.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().frame(minWidth: 1300, minHeight: 600)
        }
        .modelContainer(container)
    }
}
