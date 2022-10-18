//
//  ContentView.swift
//  TestProject
//
//  Created by Tunde Adegoroye on 29/01/2022.
//

import SwiftUI

struct ContentView: View {
    let test = cityClass()
    
    //@ObservedObject var input = NumbersOnly()
    struct Input{
        var zip: String = ""
    }
    
    @State private var input: Input = .init()
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack {
            inputTxtVw
            submitBtn
        }
        .padding()
        .textFieldStyle(.roundedBorder)
        .disableAutocorrection(true)
        .textInputAutocapitalization(.never)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button(action: resignKeyboard) {
                    Text("Done")
                }
            }
        }
        .onSubmit(of: .text, submit)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

private extension ContentView {
    
    var inputTxtVw: some View {
        TextField("Zip Code",
                  text: $input.zip,
                  prompt: Text("Zip Code"))
            .focused($inputFocused)
            .keyboardType(.decimalPad)
    }
    

    
    var submitBtn: some View {
        Button(action: submit) {
            Text("Submit")
            
        }
    }
}

private extension ContentView {
    
    func submit() {//what happens when you submit
        print("The city/county/zip inputted: \(input)")
        print("help:", input.zip)
        //.onAppear {
        let stringStats = test.getStats(input: input.zip)
        //}
        print(stringStats)
        resignKeyboard()
    }
    
    func resignKeyboard() {
        if #available(iOS 15, *) {
            inputFocused = false
        } else {
            dismissKeyboard()
        }
    }
}

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
class NumbersOnly: ObservableObject {
    @Published var value = "" {
        didSet {
            let filtered = value.filter { $0.isNumber }
            
            if value != filtered {
                value = filtered
            }
        }
    }
}
