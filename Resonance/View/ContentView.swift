//
//  ContentView.swift
//  Resonance
//
//  Created by Abhi Reddy on 21/01/2026.
//

import SwiftUI
import CoreHaptics

struct ContentView: View {
    
    @State private var currScreen: Screen = .launch
    @State private var currSong: String?
    
    @EnvironmentObject var manager: PlaybackManager
    @EnvironmentObject var controller: RenderEngine

    
    @AppStorage("tutorialFinished") var hasFinished: Bool = false
    @AppStorage("firstTime") var firstTime: Bool = true

    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        ZStack {
            switch currScreen {
            case .launch: LaunchView(currScreen: $currScreen).transition(.opacity)
            case .tutorial: TutorialView(currScreen: $currScreen)
            case .home: HomeView(currScreen: $currScreen, currSong: $currSong).transition(.opacity)
            case .main: MainView(currScreen: $currScreen, currSong: $currSong).id(currSong)
            }
        }
        .onAppear {
            currScreen = firstTime ? .launch : .home
        }
        .onChange(of: currScreen) { _, newValue in
            manager.handleScreenChange(to: newValue, song: currSong)
        }

        .onChange(of: controller.paused) { _, newValue in
            manager.togglePause(paused: newValue, currScreen: currScreen)
        }
        .onChange(of: scenePhase) { _, newPhase in
            manager.handleScenePhaseChange(newPhase: newPhase, screen: currScreen, isFinished: (controller.finished || controller.tutFinished))
        }
    }
}

enum Screen {
    case launch
    case tutorial
    case home
    case main
}

#Preview {
    ContentView()
}
