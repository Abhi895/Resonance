//
//  ResonanceApp.swift
//  Resonance
//
//  Created by Abhi Reddy on 21/01/2026.
//

import SwiftUI

@main
struct ResonanceApp: App {
    
    @StateObject var engine = AudioEngine()
    @StateObject var haptics = HapticManager()
    
    @StateObject private var controller: RenderEngine
        
    @StateObject private var manager: PlaybackManager
    
    init() {
            let audio = AudioEngine()
            let haptic = HapticManager()
            let render = RenderEngine(engine: audio, haptics: haptic)
            
            _engine = StateObject(wrappedValue: audio)
            _haptics = StateObject(wrappedValue: haptic)
            _controller = StateObject(wrappedValue: render)
            _manager = StateObject(wrappedValue: PlaybackManager(engine: audio, haptics: haptic, controller: render))
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(engine)
                .environmentObject(haptics)
                .environmentObject(controller)
                .environmentObject(manager)
            
        }
    }
}
