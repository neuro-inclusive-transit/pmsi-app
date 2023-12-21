//
//  LogView.swift
//  pmsi-app
//
//  Created by Finn Nils Gedrath on 21.12.23.
//

import SwiftUI

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
