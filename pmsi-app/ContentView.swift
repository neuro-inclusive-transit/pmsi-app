//
//  ContentView.swift
//  pmsi-app
//
//  Created by Leonard Pelzer on 10.12.23.
//

import SwiftUI
import CoreHaptics

struct Log: Identifiable {
    let id = UUID()
    let timeAfterStart: String
    let intensity: String
}

struct ContentView: View {
    
    @State private var engine: CHHapticEngine?
    @State private var isProgressing = false;
    @State private var logs: [Log] = []
    
    let intensities = [0.25, 0.6, 1.0];
    
    var body: some View {
        
        VStack {
        
            Spacer(minLength: 150)
            
            HStack {
                Image(systemName: "hand.tap")
                    .imageScale(.large)
                Text("Haptic Psychophysics")
                    .font(.title2)
            }
            .padding(.bottom)
            
            Button(action: startExperiemnt) {
                Text("Begin")
            }
            .disabled(isProgressing)
            .onAppear(perform: prepareHaptics)
            
            ProgressView()
                .padding()
                .progressViewStyle(.circular)
                .opacity(isProgressing ? 1 : 0)
            
            List(logs) {
                Text("After \($0.timeAfterStart)s with \($0.intensity) intensity")
            }
            //.frame(height: 300.0)
            
        }
    }
    
    func startExperiemnt() {
        isProgressing = true
        logs.removeAll()
        
        let currentIntensities = intensities.shuffled()
        print(currentIntensities)
        
        Task {
            
            let startDate = Date();
            // Code function
            for index in 0...(currentIntensities.count - 1) {
                
                let min = 5.0
                let max = 15.0
                let timing = Double.random(in: min...max)
                
                print("Wait for \(timing) seconds...")
                
                try await Task.sleep(nanoseconds: UInt64(timing * Double(NSEC_PER_SEC)))
                
                runHaptic(
                    intesity: Float(currentIntensities[index])
                );
                
                print("\(index): Run intensity \(currentIntensities[index]) at \(Date())")
                
                let diffTime = Date().timeIntervalSince(startDate).rounded()
                let diffTimeRounded = round(diffTime * 100) / 100
                
                logs.append(
                    Log(
                        timeAfterStart: "\(diffTimeRounded)",
                        intensity: "\(currentIntensities[index] * 100) %"
                    )
                )
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
