import SwiftUI

struct CurrencyText: View {
    @State var title: String;
    @Binding var value: Double;
    @State var currency: Currency;
    
    var body: some View {
        Text(title + ": " + String(format: "%.2f", value) + " " + currency.name).frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    CurrencyText(title: "", value: .constant(0.0), currency: .pln)
}
