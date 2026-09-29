import SwiftUI
import Combine
import CoreHaptics

class PlaybackManager: ObservableObject {
    let engine: AudioEngine
    let haptics: HapticManager
    let controller: RenderEngine
    
    init(engine: AudioEngine, haptics: HapticManager, controller: RenderEngine) {
        self.engine = engine
        self.haptics = haptics
        self.controller = controller
    }
    
    //For when user manually pauses or app goes to background while track is playing
    func togglePause(paused: Bool, currScreen: Screen) {
        if paused {
            engine.pause()
            controller.stopLoop()
            haptics.stopContinuous()
            haptics.engine?.stop(completionHandler: nil)

        } else {
            guard currScreen == .main  || currScreen == .tutorial else { return }
            
            engine.play()
            controller.startLoop()
            haptics.startPlayer()

        }
    }
    
    //For when app goes to background or is interrupted
    func handleScenePhaseChange(newPhase: ScenePhase, screen: Screen, isFinished: Bool) {
        if newPhase == .inactive || newPhase == .background {
            haptics.isAppActive = false

            if (screen == .main || screen == .tutorial) && !controller.paused && !isFinished {
                controller.paused = true
            }
        }
        else if newPhase == .active {

            haptics.isAppActive = true
            
            if screen == .tutorial && !isFinished {
                controller.paused = false
            } else {
                self.haptics.startPlayer()

            }
        }
    }
    
    //For when screen changes.
    func handleScreenChange(to screen: Screen, song: String?) {
        
        switch screen {
            
        case .tutorial:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                self.play(song: "tutorial")
            }
            
        case .main:
            if let currSong = song {
                play(song: currSong)
            }

        default:
            stop()
        }
    }
    
    //Plays a given song
    func play(song: String) {
        engine.load(songName: song)
        haptics.startPlayer()

        Task {
            while engine.getCurrentPlaybackTime() == nil {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
            if let song  = engine.currentSong {
                controller.configure(for: song)
            }
            controller.startLoop()
        }
    }
    
    //Stops current song
    func stop() {
        haptics.stopContinuous()
        controller.reset()
        engine.stop()
    }
}
