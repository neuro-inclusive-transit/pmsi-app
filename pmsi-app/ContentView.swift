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
    
    let intensities = [0.25, 0.6, 1.0];
    
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
            
            let currentIntensities = intensities.shuffled()
            
            print(currentIntensities)
            
            // Code function
            for round in 0...(currentIntensities.count - 1) {
                
                let min = 4.0
                let max = 15.0
                let timing = Double.random(in: min...max)
                
                print("Wait for \(timing) seconds...")
                
                try await Task.sleep(nanoseconds: UInt64(timing * Double(NSEC_PER_SEC)))
                
                runHaptic(
                    intesity: Float(currentIntensities[round])
                );
                
                print("\(round): Run intensity \(currentIntensities[round]) at \(Date())")
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
    
    func runHaptic(intesity: Float) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(
            parameterID: .hapticIntensity,
            value: intesity // <= einstellbar
        )
        let sharpness = CHHapticEventParameter(
            parameterID: .hapticSharpness,
            value: intesity // <= einstellbar
        )
        let event = CHHapticEvent(
            eventType: .hapticContinuous, // <= einstellbar
            parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: 2
        )
        
        events.append(event)
        
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
