//
//  ContentView.swift
//  pmsi-app
//
//  Created by Leonard Pelzer on 10.12.23.
//

import SwiftUI

struct ContentView: View {
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
                // Code function
                for round in 1...10 {
                    // TODO: Timings min und max klären
                    runAfterRandomTime(min: 10.0, max: 40.0, action: {
                        print("\(round): Run at \(Date())")
                    })
                }
            }) {
                Text("Begin")
            }
        }
        
        
    }
    
    func runAfterRandomTime(min: Double, max: Double, action: @escaping () -> Void ) {
        let timing = Double.random(in: min...max)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timing, execute: DispatchWorkItem(block: action))
    }
}

#Preview {
    ContentView()
}
