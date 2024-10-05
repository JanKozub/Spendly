import SwiftUI

struct ContentView: View {
    @State private var selection: TabSection? = TabSection.spendings;
    
    var body: some View {
        NavigationSplitView {
            SidebarComponent(selection: $selection)
        } detail: {
            switch selection {
            case .spendings:
                SpendingsView();
            case .meals:
                MealsView();
            default:
                Text("Tab value not found");
            }
        }
    }
}
