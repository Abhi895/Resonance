//
//  RenderEngine.swift
//  Resonance
//
//  Created by Abhi Reddy on 19/02/2026.
//

import QuartzCore
import Combine
import SwiftUI
import CoreHaptics

class RenderEngine: ObservableObject {
    @Published var vocalScale: CGFloat = 0.3
    @Published var kickScale: CGFloat = 0.3
    @Published var instScale: CGFloat = 0.3
    
    @Published var vocalOpacity: Double = 0.0
    @Published var kickOpacity: Double = 0.0
    @Published var instOpacity: Double = 0.0
    
    @Published var vibeColour: Color = .clear
    @Published var edgeGlow: Double = 0.0
    
    @Published var rhythmWidth: CGFloat = 0
    @Published var vocalsWidth: CGFloat = 0
    @Published var instWidth: CGFloat = 0
    
    @Published var rhythmOffset: CGSize = CGSize(width: -90, height: 150)
    @Published var vocalOffset: CGSize = CGSize(width: 10, height: -125)
    @Published var instOffset: CGSize = CGSize(width: 80, height: 70)
    
    @Published var heading: String = "Feel the beat"
    @Published var headingOpacity: Double = 1.0
    private var targetHeading: String = "Feel the beat"
    
    @Published var tutFinishing: Bool = false
    @Published var tutFinished: Bool = false
    
    @Published var cue: String = ""
    @Published var cueOpacity: Double = 0.0
    @Published var cueBlur: Double = 0.0
    @Published var targetCue: String = ""
    
    @Published var paused: Bool = false
    @Published var progress: CGFloat = 0.0
    
    @Published var finished: Bool = false
    @Published var finishing: Bool = false
    @Published var isDrop: Bool = false

    
    private var runtime = SongRuntimeState.shared
    
    private var displayLink: CADisplayLink?
    private let barWidth: Double = 70
    
    private var engine: AudioEngine
    private var haptics: HapticManager
    
    init(engine: AudioEngine, haptics: HapticManager) {
        self.engine = engine
        self.haptics = haptics
    }
    
    
    func startLoop() {
        stopLoop()
        
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120, preferred: 120)
        
    }
    
    func configure(for song: Song) {
        runtime.song = song
        runtime.base = song.base ?? [:]
        runtime.mult = song.mult ?? [:]
        runtime.vibeIndex = 0
        runtime.cueIndex = 0
        
        if song.name != "tutorial" && vibeColour == .clear {
            vibeColour = song.vibe?.first?.mood == "aggressive" ? .red : .teal
        }
    }
    
    @objc private func update() {
        
        guard let currentTime = engine.getCurrentPlaybackTime() else { return }
        guard let data = engine.closest(to: currentTime) else { return }
        
        let frame = runtime.process(data: data, time: currentTime)
        
        if frame.shouldFireKickHaptic {
            haptics.playTransient(intensity: isDrop ? 1.0 : 0.8, sharpness: 0.3)
        }
        
        haptics.updateContinuous(intensity: isDrop ? frame.hapticIntensity : frame.hapticIntensity * 1.3)
        
        transitionCue(to: runtime.getCurrentCue(time: data.t))
        
        if runtime.shouldUpdateVibe(time: data.t) {
            withAnimation(.linear(duration: 1)) { vibeColour = runtime.song?.vibe![runtime.vibeIndex].mood == "aggressive" ? .red : .teal }
        }
        
        if runtime.song?.name == "tutorial" {
            updateTutorialProgress(time: data.t)
            
        } else {
            updateMainProgress(time: data.t)
        }
        
        var energyMult = (data.k + data.v +  data.i)
        
        if runtime.isChorusOrDrop(at: data.t) {
            if !isDrop {withAnimation {isDrop = true}}
            energyMult *= 2
        } else {
            if isDrop {withAnimation {isDrop = false}}
            energyMult *= 0.2
        }
        
        let targetEdgeGlow = energyMult
        let targetKickOpacity = frame.isKickActive ? 1.0 : 0.0
        let targetVocalOpacity = frame.isVocalActive ? 1.0 : 0.0
        let targetInstOpacity = frame.isInstActive ? 1.0 : 0.0
        
        self.edgeGlow = smooth(self.edgeGlow, target: targetEdgeGlow, factor: isDrop ? 0.1 : 0.02)
        self.kickOpacity = smooth(self.kickOpacity, target: targetKickOpacity, factor: frame.isKickActive ? 0.3 : 0.04)
        self.vocalOpacity = smooth(self.vocalOpacity, target: targetVocalOpacity, factor: frame.isVocalActive ? 0.15 : 0.06)
        self.instOpacity = smooth(self.instOpacity, target: targetInstOpacity, factor: frame.isInstActive ? 0.3 : 0.06)
        
        self.kickScale = smooth(kickScale, target: (runtime.base["kick"] ?? 0.3) + CGFloat(data.k) * ((runtime.mult["kick"] ?? 1.0) + 0.5 * energyMult), factor: 0.4)
        self.vocalScale = smooth(vocalScale, target: (runtime.base["vocal"] ?? 0.3) + CGFloat(data.v) * ((runtime.mult["vocal"] ?? 1.0) + energyMult), factor: 0.15)
        self.instScale = smooth(instScale, target: (runtime.base["inst"] ?? 0.3) + CGFloat(data.i) * ((runtime.mult["inst"] ?? 1.0) + energyMult), factor: 0.15)
//        (runtime.song?.name?.lowercased() == "edm" && data.t < 25) ? 0.02 :
    }
    
    func stopLoop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    private func updateTutorialProgress(time: Double) {
        if time < 14.7 {
            rhythmWidth = (time / 14.7) * barWidth
        } else if time < 29.4 {
            if heading != "Now the voice" { transitionHeading(to:"Now the voice") }
            vocalsWidth = (time - 14.7) / 14.7 * barWidth
        } else if time < 44.1 {
            instWidth = (time - 29.4) / 14.7 * barWidth
            if heading != "Add the melody" { transitionHeading(to: "Add the melody") }
        } else if time < 63 {
            if heading != "Experience music" { transitionHeading(to: "Experience music") }
            if time > 52 && rhythmOffset != .zero {
                withAnimation(.linear(duration: 6)) {
                    rhythmOffset = .zero
                    instOffset = .zero
                    vocalOffset = .zero
                }
            }
        } else if time < 64 {
            transitionHeading(to: "")
            withAnimation { tutFinishing = true }
        } else {
            withAnimation { tutFinished = true }
            engine.stop()
            haptics.engine?.stop(completionHandler: nil)
        }
    }
    
    private func updateMainProgress(time: Double) {
        guard let runtime = runtime.song?.duration else { return }
        
        progress = time / runtime
        
        if progress > 0.985 && !finishing {
            withAnimation(.linear) {
                finishing = true
            }
        } else if progress >= 1.0 {
            withAnimation(.linear) { finished = true }
            engine.stop()
            haptics.engine?.stop(completionHandler: nil)

        }
    }
    
    
    func reset() {
        stopLoop()
        
        runtime.reset()
        
        vocalScale = 0.3
        kickScale = 0.3
        instScale = 0.3
        vocalOpacity = 0.0
        kickOpacity = 0.0
        instOpacity = 0.0
        vibeColour = .clear
        edgeGlow = 0.0
        
        cue = ""
        cueOpacity = 0.0
        targetCue = ""
        paused = false
        
        progress = 0.0
        
        rhythmWidth = 0
        vocalsWidth = 0
        instWidth = 0
        rhythmOffset = CGSize(width: -90, height: 150)
        vocalOffset = CGSize(width: 10, height: -125)
        instOffset = CGSize(width: 80, height: 70)
        heading = "Feel the beat"
        headingOpacity = 1.0
        targetHeading = "Feel the beat"
        tutFinishing = false
        tutFinished = false
        finished = false
        finishing = false
    }
    
//    func blend() {
//        blending.toggle()
//        if blending {
//            withAnimation(.linear(duration: 6)) {
//                rhythmOffset = .zero
//                instOffset = .zero
//                vocalOffset = .zero
//            }
//        } else {
//            withAnimation(.linear(duration: 6)) {
//                rhythmOffset = CGSize(width: -90, height: 150)
//                vocalOffset = CGSize(width: 10, height: -125)
//                instOffset = CGSize(width: 80, height: 70)
//            }
//        }
//    }
    
    func smooth(_ current: CGFloat, target: CGFloat, factor: CGFloat = 0.2) -> CGFloat {
        return current + (target - current) * factor
    }
    
    func transitionHeading(to newHeading: String) {
        guard targetHeading != newHeading else { return }
        targetHeading = newHeading
        
        withAnimation(.easeInOut(duration: 0.5)) {
            self.headingOpacity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.heading = newHeading
            
            withAnimation(.easeInOut(duration: 0.5)) {
                self.headingOpacity = 1.0
            }
        }
    }
    
    
    func transitionCue(to newCue: String) {
        guard targetCue != newCue else { return }
        targetCue = newCue
        let duration = 0.8
        
        withAnimation(.easeInOut(duration: duration)) {
            self.cueOpacity = 0.0
            self.cueBlur = 10.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self = self, self.targetCue == newCue else { return }
        
            self.cue = newCue
            
            withAnimation(.easeInOut(duration: duration)) {
                self.cueBlur = 0.0
                self.cueOpacity = 1.0
            }
        }
    }
}

