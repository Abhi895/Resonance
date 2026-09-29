//
//  HapticManager.swift
//  Resonance
//
//  Created by Abhi Reddy on 20/02/2026.
//

import CoreHaptics
import Combine

class HapticManager: ObservableObject {
    var engine: CHHapticEngine?
        
    private var melodyPlayer: CHHapticAdvancedPatternPlayer?
    var isAppActive: Bool = true
    
    init() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            setupContinuousPlayer()
            
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
                self?.setupContinuousPlayer()
            }
        } catch {
            print("Haptic Engine Error: \(error)")
        }
    }
    
    //Setup initial continuous player
    private func setupContinuousPlayer() {
        
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0,
            duration: 3600
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            melodyPlayer = try engine?.makeAdvancedPlayer(with: pattern)
            melodyPlayer?.loopEnabled = true
            
            let mute = CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: 0.0, relativeTime: 0)
            try melodyPlayer?.sendParameters([mute], atTime: 0)
            
            try melodyPlayer?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to setup continuous players: \(error)")
        }
    }
    
    //Start continuous player
    func startPlayer() {
        engine?.start(completionHandler: { [weak self] error in            
            if let error = error {
                print("Engine start failed with error: \(error.localizedDescription)")
            } else {
                self?.setupContinuousPlayer()
            }
        })
        
    }
    
    func playTransient(intensity: Float, sharpness: Float) {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play pattern: \(error)")
        }
    }
    
    func updateContinuous(intensity: Float) {
        guard (isAppActive || intensity == 0) else { return }
        
        let int = CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: intensity, relativeTime: 0)
        let sharp = CHHapticDynamicParameter(parameterID: .hapticSharpnessControl, value: 0.5, relativeTime: 0)
        
        do {
            try melodyPlayer?.sendParameters([int, sharp], atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to update dynamic haptics: \(error)")
        }
    }
    
    func stopContinuous() {
        do {
            try melodyPlayer?.pause(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to pause haptic player: \(error)")
        }
        updateContinuous(intensity: 0)
    }
}
