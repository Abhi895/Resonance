//
//  LaunchView.swift
//  Resonance
//
//  Created by Abhi Reddy on 23/02/2026.
//

import SwiftUI

struct LaunchView: View {
    
    @State private var showLogo = false
    @State private var showText = false
    @State private var showButton = false
    
    @State private var floatKick = false
    @State private var floatVocal = false
    @State private var floatInst = false
    
    @Binding var currScreen: Screen
    
    @EnvironmentObject var haptics: HapticManager
    
    var body: some View {
        
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                
                ZStack {
                    
                    //Kick bubble (mini)
                    Circle()
                        .foregroundStyle(.white)
                        .shadow(color:  .white, radius: 8)
                        .frame(width: 65, height: 65)
                        .offset(x: -20, y: 30 + (floatKick ? -6 : 0))
                        .scaleEffect(floatKick ? 1.05 : 1.0)
                    
                    //Vocal bubble (mini)
                    Circle()
                        .foregroundStyle(RadialGradient(colors: [.vocalInner, .vocalOuter], center: .center, startRadius: 100, endRadius: 320))
                        .opacity(0.9)
                        .shadow(color: .vocalStroke, radius: 10)
                    
                        .overlay(
                            Circle()
                                .stroke(.vocalStroke,lineWidth: 5)
                                .opacity(0.5)
                                .shadow(color: .vocalStroke, radius: 15)
                            
                        )
                        .frame(width: 90, height: 90)
                        .offset(x: floatVocal ? -5 : 0, y: -20 + (floatVocal ? 5 : 0))
                        .scaleEffect(floatVocal ? 1.02 : 1.0)
                    
                    //Instrument bubble (mini)
                    Circle()
                        .foregroundStyle(RadialGradient(colors: [.instInner, .instOuter], center: .center, startRadius: 100, endRadius: 320))
                        .opacity(0.9)
                        .shadow(color:  .instStroke, radius: 10)
                    
                        .overlay(
                            Circle()
                                .stroke(.instStroke,lineWidth: 5)
                                .opacity(0.5)
                                .shadow(color:  .instStroke, radius: 10)
                            
                        )
                        .frame(width: 75, height: 75)
                        .offset(x: 35 + (floatInst ? 5 : 0), y: 20 + (floatInst ? 5 : 0))
                        .scaleEffect(floatInst ? 1.03 : 1.0)
                    
                }
                .frame(width: 200, height: 200)
                .scaleEffect(showLogo ? 1.0 : 0.5)
                .opacity(showLogo ? 1.0 : 0.0)
                .padding(.top, 30)
                
                
                //Main text
                VStack(spacing: 2) {
                    Text("Resonance")
                        .foregroundStyle(.white)
                        .font(.system(size: 50, weight: .heavy, design: .rounded))
                    
                    Text("Music beyond sound.")
                        .foregroundStyle(.white.opacity(0.5))
                        .font(.system(size: 18, weight: .light, design: .rounded))
                }
                .opacity(showText ? 1.0 : 0.0)
                .blur(radius: showText ? 0 : 10)
                
                Spacer()
                
                
                //CTA for tutorial
                Button {
                    haptics.playTransient(intensity: 0.7, sharpness: 0.5)
                    withAnimation(.easeInOut(duration: 0.8)) {
                        currScreen = .tutorial
                    }
                    
                } label: {
                    Text("Begin")
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
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0)) {
                showLogo = true
            }
            
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                floatKick = true
            }
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                floatVocal = true
            }
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                floatInst = true
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                showText = true
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                showButton = true
            }
        }
    }
}

struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}



//#Preview {
//    LaunchView()
//}
