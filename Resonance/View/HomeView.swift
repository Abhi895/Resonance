//
//  HomeView.swift
//  Resonance
//
//  Created by Abhi Reddy on 24/02/2026.
//

import SwiftUI

struct HomeView: View {
    
    @Binding var currScreen: Screen
    @Binding var currSong: String?

    @EnvironmentObject var haptics: HapticManager
    @EnvironmentObject var engine: AudioEngine
    @EnvironmentObject var controller: RenderEngine
    
    @AppStorage("tutorialFinished") var hasFinished: Bool = false
    @AppStorage("firstTime") var firstTime: Bool = true
    

    @State private var showMain = false
    @State private var showInfoModal = false
    
    var body: some View {
        
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()
            GeometryReader { geometry in
                                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    VStack {
                        //Header
                        VStack(alignment: .leading) {
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Resonance")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                                    .padding(.top, 20)
                                
                                Text("Music beyond sound.")
                                    .foregroundStyle(.white.opacity(0.3))
                                    .font(.system(size: 18, weight: .light, design: .rounded))
                                
                            }
                            .padding(.bottom)
                            
                            //PlayTutorialButton (if user hasn't finished tutorial)
                            if !hasFinished {
                                PlayTutorialView(currScreen: $currScreen)
                            }
                            
                            
                            HStack {
                                Text("CHOOSE YOUR EXPERIENCE")
                                    .foregroundStyle(.white.opacity(0.6))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                                                
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        showInfoModal = true
                                    }
                                } label: {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 17))
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                                
                                Spacer()

                            }
                            .padding(.vertical)
                            
                            //Available tracks
                            VStack(spacing: 34) {
                                TrackView(trackName: "Acoustic", subtitle: "Gentle beat • Calm vocals", trackColours: [.calmColour], rhythmSize: 17, vocalSize: 25, instSize: 18, time: "2:59", currScreen: $currScreen, currSong: $currSong, showMain: $showMain)
                                TrackView(trackName: "EDM", subtitle: "Strong vocals • Changing energy", trackColours: [.calmColour, .vocalInner, .red], rhythmSize: 20, vocalSize: 31, instSize: 24, time: "3:51", currScreen: $currScreen, currSong: $currSong, showMain: $showMain)
                                TrackView(trackName: "Rock", subtitle: "Steady beat • Bold melody", trackColours: [.red], rhythmSize: 23, vocalSize: 26, instSize: 31, time: "2:11", currScreen: $currScreen, currSong: $currSong, showMain: $showMain)
                            }
                            
                        }
                     
                        Spacer()
                        
                        //Replay button (if user has finished tutorial)
                        if hasFinished {
                            if #available(iOS 26.0, *) {
                                Button {
                                    haptics.playTransient(intensity: 0.7, sharpness: 0.5)
                                    controller.reset()
                                    withAnimation(.easeInOut(duration: 0.6)) {
                                        currScreen = .tutorial
                                    }
                                    
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.system(size: 15, weight: .bold))
                                        Text("Replay tutorial")
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    }
                                    
                                    .foregroundStyle(.white.opacity(0.9))
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    
                                }
                                .glassEffect(.clear)
                                .buttonStyle(SpringButtonStyle())
                            } else {
                                Button {
                                    haptics.playTransient(intensity: 0.7, sharpness: 0.5)
                                    controller.reset()
                                    withAnimation(.easeInOut(duration: 0.6)) {
                                        currScreen = .tutorial
                                    }
                                    
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.system(size: 15, weight: .bold))
                                        Text("Replay tutorial")
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    }
                                    
                                    .foregroundStyle(.white.opacity(0.9))
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    
                                }
                                .buttonStyle(SpringButtonStyle())
                            }
                        }
                       
                        
                    }
                    .padding(.horizontal, 30)
                    .frame(minHeight: geometry.size.height)
                    .blur(radius: showMain || showInfoModal ? 6 : 0)
                    .opacity(showMain ? 0.0 : 1.0)
                    
                    
                }
            }
            
            //Gradient mask for clean scrolling
            LinearGradient(
                colors: [.black, .black.opacity(0.8), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 100)
            .ignoresSafeArea(edges: .top)
            .allowsHitTesting(false)

            //Popup guide
            ZStack {
                Color.black.opacity(showInfoModal ? 0.8 : 0.0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showInfoModal = false
                        }
                    }
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Visual Guide")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showInfoModal = false
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(8)
                                .background(Circle().fill(Color.white.opacity(0.1)))
                        }
                    }
                    
                    //Legend
                    VStack(alignment: .leading, spacing: 16) {
                        LegendRow(dotColour: .white, title: "Rhythm (Beat)", hasStroke: false)
                        LegendRow(dotColour: .vocalOuter, title: "Vocals (Voice)", hasStroke: true, strokeColor: .vocalStroke)
                        LegendRow(dotColour: .instOuter, title: "Melody (Instruments)", hasStroke: true, strokeColor: .instStroke)
                        
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    Text("The dot sizes show the energy of each part.\n\nThe card's **glowing border** reflects the overall mood (e.g., Calm, Aggressive, or Mixed).")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .lineSpacing(4)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color(red: 0.1, green: 0.1, blue: 0.11))
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        .shadow(color: .black.opacity(0.8), radius: 30, y: 15)
                )
                .padding(30)
                .opacity(showInfoModal ? 1.0 : 0.0)
                .scaleEffect(showInfoModal ? 1.0 : 0.95)
            }
            .allowsHitTesting(showInfoModal)
            .zIndex(100)
 
        }
        .onAppear { 
            firstTime = false
        }
        .onTapGesture(count: 3, perform: {
            firstTime = true
            hasFinished = false
            withAnimation {
                currScreen = .launch
            }
        })
            
    }
}

struct TrackView: View {
    
    @State var trackName: String
    @State var subtitle: String
    @State var trackColours: [Color]
    @State var rhythmSize: CGFloat
    @State var vocalSize: CGFloat
    @State var instSize: CGFloat
    @State var time: String
    
    @Binding var currScreen: Screen
    @Binding var currSong: String?
    @Binding var showMain: Bool
    
    @EnvironmentObject var engine: AudioEngine
    @EnvironmentObject var controller: RenderEngine
    
    var body: some View {
        
        Button {
            
            currSong = trackName

            withAnimation(.linear(duration: 1)) {
                showMain = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                currScreen = .main
            }
            
        } label: {
            ZStack {
                
                RoundedRectangle(cornerRadius: 25)
                    .fill(LinearGradient(colors: trackColours, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .blur(radius: 5)
                RoundedRectangle(cornerRadius: 25)
                    .fill(.black)

                
                RoundedRectangle(cornerRadius: 25)
                    .stroke(LinearGradient(colors: trackColours, startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)

                    .opacity(0.5)
                
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(trackName)
                            .foregroundStyle(.white)
                            .font(.system(size: 25, weight: .heavy, design: .rounded))
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white.opacity(0.5))
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                        
                    }
                    Text(subtitle)
                        .foregroundStyle(.white.opacity(0.5))
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                    
                    HStack(alignment: .bottom) {
                        BubblesView(rhythmSize: rhythmSize, vocalSize: vocalSize, instSize: instSize)
                            .padding(.top)
                            .padding(.bottom, 5)
                        
                        Spacer()
                        Text(time)
                            .foregroundStyle(.white.opacity(0.5))
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .padding(.bottom, 5)
                        
                    }
                    
                }
                .padding(20)
            }
            
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(trackName) track")
        .accessibilityValue(subtitle)
        .accessibilityHint("Tap to play this track.")
        .accessibilityAddTraits(.isButton)
        .frame(height: 140)
    }
}

struct BubblesView: View {
    @State var rhythmSize: CGFloat
    @State var vocalSize: CGFloat
    @State var instSize: CGFloat
    
    var body: some View {
        
        HStack(spacing: 15) {
            Circle()
                .foregroundStyle(.white)
                .frame(width:  rhythmSize, height: rhythmSize)
                .shadow(color:  .white, radius: 3)
            
            Circle()
            
                .foregroundStyle(.vocalOuter)
            
                .shadow(color:  .vocalStroke, radius: 5)
                .overlay(
                    Circle()
                        .stroke(.vocalStroke, lineWidth: 2)
                        .shadow(color:  .vocalStroke, radius: 5)
                )
                .frame(width: vocalSize, height: vocalSize)
            
            
            Circle()
            
                .foregroundStyle(.instOuter)
            
                .shadow(color:  .instStroke, radius: 4)
                .overlay(
                    Circle()
                        .stroke(.instStroke, lineWidth: 2)
                        .shadow(color:  .instStroke, radius: 4)
                )
                .frame(width: instSize, height: instSize)
            
            
        }
        .accessibilityHidden(true)
    }
}

struct LegendRow: View {
    var dotColour: Color
    var title: String
    var hasStroke: Bool
    var strokeColor: Color = .clear
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(dotColour)
                .frame(width: 18, height: 18)
                .shadow(color: hasStroke ? strokeColor : .white.opacity(0.5), radius: 4)
                .overlay(
                    Group {
                        if hasStroke {
                            Circle().stroke(strokeColor, lineWidth: 1.5)
                        }
                    }
                )
            
            Text(title)
                .foregroundStyle(.white.opacity(0.9))
                .font(.system(size: 16, weight: .medium, design: .rounded))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Legend colour for: \(title)")
    }
}



struct PlayTutorialView: View {
    
    @EnvironmentObject var engine: AudioEngine
    @EnvironmentObject var controller: RenderEngine
    
    @Binding var currScreen: Screen
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.66, green: 0.33, blue: 0.97),
                        Color(red: 0.23, green: 0.51, blue: 0.96),
                        Color(red: 0.02, green: 0.71, blue: 0.83)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            
            HStack {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("TUTORIAL")
                        .foregroundStyle(.white.opacity(0.6))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    
                    Text("Learn to experience music.")
                        .foregroundStyle(.white)
                        .font(.system(size: 32, weight: .heavy, design: .default))
                        .multilineTextAlignment(.leading)
                    if #available(iOS 26.0, *) {
                        Button {
                            engine.stop()
                            controller.reset()
                            withAnimation(.easeInOut(duration: 0.5)) {
                                currScreen = .tutorial
                            }
                        } label: {
                            HStack(alignment: .center, spacing: 5) {
                                Text("Start")
                                    .font(.system(size: 15, weight: .semibold))
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                        }
                        .glassEffect(.clear)
                        .buttonStyle(SpringButtonStyle())
                        .foregroundStyle(.white)
                        
                        .padding(.top, 4)
                    } else {
                        Button {
                            engine.stop()
                            controller.reset()
                            withAnimation(.easeInOut(duration: 0.5)) {
                                currScreen = .tutorial
                            }
                        } label: {
                            HStack(alignment: .center, spacing: 5) {
                                Text("Start")
                                    .font(.system(size: 15, weight: .semibold))
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(SpringButtonStyle())
                        .foregroundStyle(.white)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 25)
        }
        .frame(height: 190)
        .padding(.vertical)
        .shadow(color: .black.opacity(0.4), radius: 12)
        
    }
}
