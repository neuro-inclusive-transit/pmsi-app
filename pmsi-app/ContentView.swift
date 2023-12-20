//
//  ContentView.swift
//  pmsi-app
//
//  Created by Leonard Pelzer on 10.12.23.
//

import SwiftUI
import CoreHaptics
import AudioToolbox

struct Log: Identifiable {
    let id = UUID()
    let timeAfterStart: String
    let intensity: String
}

struct LogRowView: View {
    var log: Log
    
    @Binding var isDisabled: Bool
    @State var isChecked = false;

    var body: some View {
        HStack(spacing: 3) {
            Text("**After \(log.timeAfterStart)s:** \(log.intensity) intensity")
            Spacer()
            Toggle(isOn: $isChecked) {
                Image(systemName: isChecked ? "iphone.gen3.radiowaves.left.and.right.circle" : "iphone.gen3.slash.circle")
            }
            .toggleStyle(.button)
            .accentColor(isChecked ? .blue : .gray)
            .disabled(isDisabled)
        }
    }
}

enum PhonePlacement: String, CaseIterable, Identifiable {
    case worst, worstWith, mid, midWith, best, bestWith
    var id: Self { self }
}


struct ContentView: View {
    
    @State private var engine: CHHapticEngine?
    @State private var isProgressing = false;
    @State private var logs: [Log] = []
    @State private var selectedPlacement: PhonePlacement = .best
    @State private var numberOfFalsPositives: Int = 0

    let intensities = [0.25, 0.6, 1.0];
    
    var body: some View {
        
        VStack {
        
            Spacer(minLength: 130)
            
            HStack {
                Image(systemName: "hand.tap")
                    .imageScale(.large)
                Text("Haptic Psychophysics")
                    .font(.title2)
            }
            
            HStack {
                Text("Placement Variant:")
                Spacer()
                Picker("Placement", selection: $selectedPlacement) {
                    Text("Worst Case").tag(PhonePlacement.worst)
                    Text("Worst Case \\w Div.").tag(PhonePlacement.worstWith)
                    Text("Mid Case").tag(PhonePlacement.mid)
                    Text("Mid Case \\w Div.").tag(PhonePlacement.midWith)
                    Text("Best Case").tag(PhonePlacement.best)
                    Text("Best Case \\w Div.").tag(PhonePlacement.bestWith)
                }
                .disabled(isProgressing)
            }
            .padding(.horizontal)
            
            Stepper {
                Text("False Positives: \(numberOfFalsPositives)")
            } onIncrement: {
                numberOfFalsPositives += 1
            } onDecrement: {
                numberOfFalsPositives -= 1
                if (numberOfFalsPositives < 0) {
                    numberOfFalsPositives = 0
                }
            }
            .disabled(isProgressing)
            .padding(.horizontal)
            
            Button(action: startExperiment) {
                Text("Begin")
            }
            .disabled(isProgressing)
            .onAppear(perform: prepareHaptics)
            .buttonStyle(.borderedProminent)
            .padding(.top)
            
            ProgressView()
                .padding()
                .progressViewStyle(.circular)
                .opacity(isProgressing ? 1 : 0)
            
            List {
                //Text("After \($0.timeAfterStart)s with \($0.intensity) intensity")
                ForEach (logs) { log in
                    LogRowView(log: log, isDisabled: $isProgressing)
                }
            }
            
        }
    }
    
    func startExperiment() {
        isProgressing = true
        logs.removeAll()
        numberOfFalsPositives = 0
        
        let currentIntensities = intensities.shuffled()
        print(currentIntensities)
        
        Task {
            
            var lastDate = Date();
            let minTiming = 5.0
            let maxTiming = 15.0
            
            runHaptic(
                intesity: Float(1.0)
            );
            
            // Initial Wait
            try await Task.sleep(nanoseconds: UInt64(15 * Double(NSEC_PER_SEC)))
            
            
            // Code function
            for index in 0...(currentIntensities.count - 1) {

                let timing = Double.random(in: minTiming...maxTiming)
                
                print("Wait for \(timing) seconds...")
                
                try await Task.sleep(nanoseconds: UInt64(timing * Double(NSEC_PER_SEC)))
                
                runHaptic(
                    intesity: Float(currentIntensities[index])
                );
                
                print("\(index): Run intensity \(currentIntensities[index]) at \(Date())")
                
                let diffTime = Date().timeIntervalSince(lastDate)
                lastDate = Date()
                let diffTimeRounded = round(diffTime * 100) / 100.0
                
                logs.append(
                    Log(
                        timeAfterStart: "\(diffTimeRounded)",
                        intensity: "\(Int(currentIntensities[index] * 100)) %"
                    )
                )
                
                
            }
            
            try await Task.sleep(nanoseconds: UInt64(minTiming * Double(NSEC_PER_SEC)))
            
            AudioServicesPlaySystemSound(
                1007
            )
            
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
