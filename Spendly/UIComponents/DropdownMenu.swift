import SwiftUI

struct DropdownMenu: View {
    @State var selected: String
    @State var elements: [String]
    var onChange: ((String) -> Void)?
    
    var body: some View {
        Menu {
            ForEach(elements, id: \.self) { category in
                Button(action: {
                    selected = category
                }) {
                    Text(category)
                }
            }
        } label: {
            HStack {
                Text(selected)
            }
            .frame(maxWidth: .infinity)
            .padding(5)
            .background(Color.white.opacity(0.2))
            .cornerRadius(5)
        }
        .onChange(of: selected) { oldValue, newValue in
            onChange?(newValue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
