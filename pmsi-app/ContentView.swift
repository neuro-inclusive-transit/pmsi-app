//
//  ContentView.swift
//  pmsi-app
//
//  Created by Leonard Pelzer on 10.12.23.
//

import SwiftUI
import AudioToolbox

struct ContentView: View {
    @State private var isProgressing = false;
    
    let totalNumOfRounds = 10;
    
    func startExperiemnt() {
        Task {
            isProgressing = true
            
            // Code function
            for round in 1...totalNumOfRounds {
                
                let min = 5.0
                let max = 20.0
                let timing = Double.random(in: min...max)
                
                print("Wait for \(timing) seconds...")
                
                try await Task.sleep(nanoseconds: UInt64(timing * Double(NSEC_PER_SEC)))
                
                print("\(round): Run at \(Date())")
            }
            
            isProgressing = false
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: "hand.tap")
                .imageScale(.large)
            Text("Haptic Psychophysics")
                .font(.title2)
        }
        .padding(.bottom)
        VStack {
            Button(action: startExperiemnt) {
                Text("Begin")
            }
            .disabled(isProgressing)
            
            ProgressView()
                .padding()
                .progressViewStyle(.circular)
                .opacity(isProgressing ? 1 : 0)
        }
    }

}

#Preview {
    ContentView()
}
