//
//  ContentView.swift
//  pmsi-app
//
//  Created by Leonard Pelzer on 10.12.23.
//

import SwiftUI

struct ContentView: View {
    @State var buttonDisabled = false;
    
    var body: some View {
        HStack {
            Image(systemName: "hand.tap")
                .imageScale(.large)
            Text("Haptic Psychophysics")
                .font(.title2)
        }
        .padding()
        VStack {
            Button(action: {
                Task {
                    buttonDisabled = true
                    
                    // Code function
                    for round in 1...10 {
                        let min = 5.0
                        let max = 20.0
                        let timing = Double.random(in: min...max)
                        
                        print("Wait for \(timing) seconds...")
                        
                        try await Task.sleep(nanoseconds: UInt64(timing * Double(NSEC_PER_SEC)))
                        
                        print("\(round): Run at \(Date())")
                    }
                    
                    buttonDisabled = false
                }
            }) {
                Text("Begin")
            }
            .disabled(buttonDisabled)
        }
    }

}

#Preview {
    ContentView()
}
