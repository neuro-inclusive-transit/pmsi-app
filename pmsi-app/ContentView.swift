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
            }) {
                Text("Begin")
            }
        }
        
        
    }
}

#Preview {
    ContentView()
}
