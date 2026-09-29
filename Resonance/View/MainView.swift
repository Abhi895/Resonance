//
//  MainView.swift
//  Resonance
//
//  Created by Abhi Reddy on 25/02/2026.
//

import SwiftUI

struct MainView: View {
    
    @Binding var currScreen: Screen
    @Binding var currSong: String?
    
    @EnvironmentObject var haptics: HapticManager
    @EnvironmentObject var controller: RenderEngine
    @EnvironmentObject var engine: AudioEngine
    
    @State var showHeader: Bool = false
    @State var showVisuals: Bool = false
        
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if controller.finished {
                FinishedView(currScreen: $currScreen)
            } else {
                
                if (controller.vibeColour != .clear) {
                    RoundedRectangle(cornerRadius: 80)
                        .stroke(controller.vibeColour, lineWidth: controller.isDrop ? 19 : 16)
                        .blur(radius: controller.isDrop ? 18 : 15)
                        .opacity(controller.isDrop ? 0.1 + controller.edgeGlow * 2 : 0.2 + controller.edgeGlow * 10)
                        .ignoresSafeArea()
                }
                VStack {
                    
                    //Header
                    ZStack {
                        
                        Text(currSong ?? "")
                            .font(.system(size: 21, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.mix(with: controller.vibeColour, by: 0.5).opacity(0.2))
                        
                        HStack {
                            ZStack {
                                Circle()
                                    .stroke(.white.mix(with: controller.vibeColour, by: 0.5).opacity(0.15), lineWidth: 2.5)
                                    .frame(width: 27, height: 27)
                                
                                Circle()
                                    .trim(from: 0, to: controller.progress)
                                    .stroke(.white.mix(with: controller.vibeColour, by: 0.5).opacity(0.6), lineWidth: 2.5)
                                    .frame(width: 27, height: 27)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear, value: controller.progress)
                                
                                Button {
                                    engine.stop()
                                    controller.reset()
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        currScreen = .home
                                    }
                                    
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white.mix(with: controller.vibeColour, by: 0.5).opacity(0.2))
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 18)
                                    
                                    
                                }
                            }
                            
                            Spacer()
                            
                            
                        }
                        .padding(.horizontal, 30)
                    }
                    .opacity(controller.finishing || !showHeader ? 0.0 : 1.0)
                    .blur(radius: controller.finishing || !showHeader ? 10 : 0)
                    
                    Spacer()
                    
                    //Visualiser
                    VisualiserView()
                        .padding()
                        .blur(radius: controller.paused || !showVisuals ? 5 : 0)
                        .opacity(showVisuals ? 1.0 : 0.0)

                    
                    Spacer()
                    
                    //Cue text
                    Text(controller.cue)
                        .font(.system(size: 27, weight: .light, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(height: 50)
                        .opacity(controller.cueOpacity)
                        .padding()
                        .blur(radius: controller.paused ? 5 : 0)
                }
                
                //Play button
                Image(systemName: "play.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white.opacity(0.6))
                    .opacity(controller.paused ? 1 : 0)
            }
        }
        .statusBarHidden()
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true

            withAnimation(.linear(duration: 0.8)) {
                showHeader = true
            }
            withAnimation(.linear(duration: 2)) {
                showVisuals = true
            }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onTapGesture {
            if !controller.finished {
                withAnimation {
                    controller.paused.toggle()
                }
            }
        }
            
    }
}

struct FinishedView: View {
    @State private var animateIn = false
    @State private var showButton = false
    
    @Binding var currScreen: Screen
    @EnvironmentObject var haptics: HapticManager
    @AppStorage("tutorialFinished") var hasFinished: Bool!
    
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 3) {
                    Text("The music ends.")
                        .foregroundStyle(.white)
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .opacity(animateIn ? 1.0 : 0.0)
                        .blur(radius: animateIn ? 0 : 10)
                    
                    Text("but the feeling stays.")
                        .foregroundStyle(.white.opacity(0.5))
                        .font(.system(size: 18, weight: .light, design: .rounded))
                        .opacity(animateIn ? 1.0 : 0.0)
                        .blur(radius: animateIn ? 0 : 10)
                        .animation(.easeIn(duration: 1.0).delay(1.5), value: animateIn)
                    
                    Text("That is resonance.")
                        .foregroundStyle(.white.opacity(1))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .shadow(color: .white, radius: 20)
                        .padding(.top, 30)
                        .opacity(animateIn ? 1.0 : 0.0)
                        .blur(radius: animateIn ? 0 : 10)
                        .animation(.easeIn(duration: 1.0).delay(4), value: animateIn)
                    
                    
                }
    
                Spacer()
            }
            Spacer()
            
            
            Button {
                haptics.playTransient(intensity: 0.7, sharpness: 0.5)
                hasFinished = true
                withAnimation(.easeInOut(duration: 0.6)) {
                    currScreen = .home
                }
                
            } label: {
                Text("Return home")
                    .foregroundStyle(.black)
                    .font(.system(size: 22, weight: .semibold))
                    .frame(width: 300, height: 60)
                    .background(.white, in: RoundedRectangle(cornerRadius: 34))
            }
            .buttonStyle(SpringButtonStyle())
            .padding(.bottom, 40)
            .shadow(color: .white, radius: 9)
            .opacity(animateIn ? 1.0 : 0.0)
            .offset(y: animateIn ? 0 : 40)
            .animation(.easeIn(duration: 1.0).delay(6), value: animateIn)
        }
        .background(.black)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateIn = true
            }

        }
    }
}
