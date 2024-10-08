import SwiftUI

struct EditPaymentNames: View {
    @Binding var isShown: Bool
    @Binding var payments: [Payment]
    @State var inputedText: String = ""
    
    var body: some View {
        VStack {
            Text("Edit Payment Titles")
                .font(.headline)
            TextField("Enter new text", text: $inputedText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button("Cancel") {
                    isShown = false
                }
                Spacer()
                Button("Submit") {
                    updateMessages()
                    isShown = false
                }
            }.padding()
        }.padding()
    }
    
    private func updateMessages() {
        for index in payments.indices {
            payments[index].message = payments[index].message.replacingOccurrences(of: inputedText, with: "")
        }
    }
}
