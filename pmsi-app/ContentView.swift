//
//  ContentView.swift
//  pmsi-app
//
//  Created by Leonard Pelzer on 10.12.23.
//

import SwiftUI
import CoreHaptics

struct ContentView: View {
    
    @State private var engine: CHHapticEngine?
    @State private var isProgressing = false;
    
    let totalNumOfRounds = 10;
    
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
            .onAppear(perform: prepareHaptics)
            
            ProgressView()
                .padding()
                .progressViewStyle(.circular)
                .opacity(isProgressing ? 1 : 0)
        }
        
    }
    
    func startExperiemnt() {
        //let notifGenerator = UINotificationFeedbackGenerator()
        
        Task {
            isProgressing = true
            
            // Code function
            for round in 1...totalNumOfRounds {
                
                let min = 4.0
                let max = 4.0
                let timing = Double.random(in: min...max)
                
                print("Wait for \(timing) seconds...")
                
                try await Task.sleep(nanoseconds: UInt64(timing * Double(NSEC_PER_SEC)))
                
                //await notifGenerator.notificationOccurred(.success)
                runHaptic()
                
                print("\(round): Run at \(Date())")
            }
            
            isProgressing = false
        }
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            
            engine = try CHHapticEngine()
            try engine?.start()
        } catch let error {
            fatalError("Engine Creation Error: \(error.localizedDescription)")
        }
    }
    
    func runHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        for i in stride(from: 0, to: 1, by: 0.1) {
            let intensity = CHHapticEventParameter(
                parameterID: .hapticIntensity,
                value: Float(i) // <= einstellbar
            )
            let sharpness = CHHapticEventParameter(
                parameterID: .hapticSharpness,
                value: Float(i) // <= einstellbar
            )
            let event = CHHapticEvent(
                eventType: .hapticTransient, // <= einstellbar
                parameters: [intensity, sharpness],
                relativeTime: i
                //duration: 1
            )
            
            events.append(event)
        }
        
        for i in stride(from: 0, to: 1, by: 0.1) {
            let intensity = CHHapticEventParameter(
                parameterID: .hapticIntensity,
                value: Float(1 - i) // <= einstellbar
            )
            let sharpness = CHHapticEventParameter(
                parameterID: .hapticSharpness,
                value: Float(1 - i) // <= einstellbar
            )
            let event = CHHapticEvent(
                eventType: .hapticTransient, // <= einstellbar
                parameters: [intensity, sharpness],
                relativeTime: 1 + i
                //duration: 1
            )
            
            events.append(event)
        }
        
        
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern with \(error.localizedDescription)")
        }
    }

}

#Preview {
    ContentView()
}
