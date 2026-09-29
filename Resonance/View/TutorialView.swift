//
//  TutorialView.swift
//  Resonance
//
//  Created by Abhi Reddy on 23/02/2026.
//

import SwiftUI

struct TutorialView: View {
    
    @Binding var currScreen: Screen
    
    @EnvironmentObject var haptics: HapticManager
    @EnvironmentObject var engine: AudioEngine
    @EnvironmentObject var controller: RenderEngine
    
    @State private var showText = false
    @State private var showSkip = false

    var body: some View {
        
        if controller.tutFinished {
            TutorialFinishedView(currScreen: $currScreen)
        } else {
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        haptics.playTransient(intensity: 0.7, sharpness: 0.5)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currScreen = .home
                        }
                        
                    } label: {
                        
                        HStack {
                            Text("Skip")
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(.white.opacity(0.2))
                        .opacity(showSkip && !controller.tutFinishing ? 1.0 : 0.0)
                        .blur(radius: showSkip ? 0 : 10)
                    }
                }
                .padding(.trailing)
                
                ProgressView()
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(showText ? 1.0 : 0.0)
                    .blur(radius: showText ? 0 : 10)
                 
                VisualiserView()
                    .padding(.vertical, 30)
                
                Spacer()
                
                Text(controller.cue)
                    .font(.system(size: 27, weight: .light, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .opacity(controller.cueOpacity)
                    .blur(radius: controller.cueBlur)
                    .padding()
            }
            .background(.black)
            .statusBarHidden()
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
                
                withAnimation(.easeOut(duration: 1.5).delay(0.8)) {
                    showText = true
                }
                
                withAnimation(.easeOut(duration: 1.5).delay(3)) {
                    showSkip = true
                }
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false

            }
        }
    }
    
}

struct TutorialFinishedView: View {
    
    @State private var showText = false
    @State private var showButton = false
    
    @Binding var currScreen: Screen
    @EnvironmentObject var haptics: HapticManager
    @AppStorage("tutorialFinished") var hasFinished: Bool!
    
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 6) {
                    Text("You're ready.")
                        .foregroundStyle(.white)
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                    
                    Text("Time to explore new music")
                        .foregroundStyle(.white.opacity(0.5))
                        .font(.system(size: 18, weight: .light, design: .rounded))
                    
                }
                .opacity(showText ? 1.0 : 0.0)
                .blur(radius: showText ? 0 : 10)
                Spacer()
            }
            Spacer()
            
            
            Button {
                haptics.playTransient(intensity: 0.7, sharpness: 0.5)
                hasFinished = true
                withAnimation(.easeInOut(duration: 0.5)) {
                    currScreen = .home
                }
                
            } label: {
                Text("Explore")
                    .foregroundStyle(.black)
                    .font(.system(size: 22, weight: .semibold))
                    .frame(width: 300, height: 60)
                    .background(.white, in: RoundedRectangle(cornerRadius: 34))
            }
            .buttonStyle(SpringButtonStyle())
            .padding(.bottom, 40)
            .shadow(color: .white, radius: 9)
            .opacity(showButton ? 1.0 : 0.0)
            .offset(y: showButton ? 0 : 40)
            
            
        }
        .background(.black)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                showText = true
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                showButton = true
            }
        }
    }
}

//#Preview {
//    TutorialView(currScreen: $)
//}
