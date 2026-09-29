//
//  FrameProvider.swift
//  Resonance
//
//  Created by Abhi Reddy on 26/02/2026.
//
import SwiftUI

class SongRuntimeState {
    var song: Song?
    var base: [String: Double] = [:]
    var mult: [String: Double] = [:]
    
    var vibeIndex = 0
    var cueIndex = 0
    
    var lastKickValue: CGFloat = 0
    var isDescending = true
    
    var lastVocalTime: TimeInterval = -1
    var lastInstTime: TimeInterval = -1
    let silenceThreshold = 0.01
        
    static let shared = SongRuntimeState()

    func process(data: DataPoint, time: TimeInterval) -> FrameState {
        let currentKick = CGFloat(data.k)
        var isKickActive = data.k > 0.05
        var shouldFireKickHaptic = false
        
        if data.v > silenceThreshold { lastVocalTime = time }
        if data.i > silenceThreshold { lastInstTime = time }
        
        var isVocalActive = (time - lastVocalTime) < 0.4
        var isInstActive = (time - lastInstTime) < 0.3

        if isKickActive && currentKick > lastKickValue && isDescending {
            shouldFireKickHaptic = true
            isDescending = false
        }
        
        if currentKick < lastKickValue { isDescending = true }
        
        if song?.name == "acoustic" && data.t > 170 {
            print("\(isVocalActive) and \(data.v)")
        }
        
        lastKickValue = currentKick
        
        if song?.name == "edm" && ((time > 90 && time < 108.75) || (time > 173 && time < 189)) { isVocalActive = false}
        if song?.name == "edm" && (time > 84.9 && time < 85.5) {
            isVocalActive = false
            isKickActive = false
            isInstActive = false
        }
        
        let hapticIntensity = getHapticIntensity(data: data, isVocalActive: isVocalActive, isKickActive: isKickActive, isInstActive: isInstActive)
        
        return FrameState(isKickActive: isKickActive, isVocalActive: isVocalActive, isInstActive: isInstActive, shouldFireKickHaptic: shouldFireKickHaptic, hapticIntensity: hapticIntensity)
    }
    
    
    
    func getHapticIntensity(data: DataPoint, isVocalActive: Bool, isKickActive: Bool, isInstActive: Bool) -> Float {
        let duckingMultiplier: Float = isKickActive ? 0.5 : 1.0
        let vIntensity = isVocalActive ? min(Float(data.v) * Float(mult["vocal"] ?? 1.0) * duckingMultiplier, 1.0) : 0
        let iIntensity = isInstActive ? min(Float(data.i) * Float(mult["inst"] ?? 1.0) * duckingMultiplier, 1.0) : 0
        var intensity: Float = 0.0
        
        if isVocalActive && isInstActive {
            intensity = (vIntensity + iIntensity) * 1.5
        } else {
            intensity = (vIntensity + iIntensity) * 3
        }
        
        return min(1.0, song?.name == "tutorial" ? intensity * 2: intensity * 1.5)
    }
    
    func getCurrentCue(time: TimeInterval) -> String {
            if let cues = song?.cues, cueIndex < cues.count {
                if time > cues[cueIndex].start && time <= cues[cueIndex].end {
                    return cues[cueIndex].text
                } else if time > cues[cueIndex].end {
                    cueIndex += 1
                    return ""
                }
            }
            return ""
        }
    
    func shouldUpdateVibe(time: TimeInterval) -> Bool {
        if let vibes = song?.vibe {
            if time > vibes[vibeIndex].end && vibeIndex < vibes.count - 1 {
                vibeIndex += 1
                return true
            }
        }
        return false
    }
    
    
    func isChorusOrDrop(at time: TimeInterval) -> Bool {
        if let name = song?.name?.lowercased() {
            switch name {
            case "edm":
                if ((time > 85 && time < 112) || (time > 168 && time < 190)) { return true }
            case "acoustic":
                if (time > 67.5 && time < 91) || (time > 151 && time < 176) { return true }
            case "rock":
                if (time > 17.5 && time < 30) || (time > 54 && time < 69) || (time > 101 && time < 128) { return true }
            default:
                return false
            }
        }
        
        return false
    }
    
    func reset() {
        song = nil
        base = [:]
        mult = [:]
        
        vibeIndex = 0
        cueIndex = 0
        
        lastKickValue = 0
        isDescending = true
        
        lastVocalTime = -1
        lastInstTime = -1
    }
    
    
}

struct FrameState {
    let isKickActive: Bool
    let isVocalActive: Bool
    let isInstActive: Bool
    let shouldFireKickHaptic: Bool
    let hapticIntensity: Float
}
