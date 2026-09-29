//
//  VisualiserView.swift
//  Resonance
//
//  Created by Abhi Reddy on 23/02/2026.
//

import SwiftUI

struct VisualiserView: View {
    
    @EnvironmentObject var engine: AudioEngine
    @EnvironmentObject var controller: RenderEngine
    
    let width: Double = 5
    let tintFactor = 0.1
    
    var body: some View {
        
        ZStack {
            //Kick bubble
            Circle()
                .foregroundStyle(Color.white.mix(with: controller.vibeColour, by: tintFactor))
                .opacity(controller.kickOpacity)
                .scaleEffect(controller.kickScale, anchor: .center)
                .offset(controller.rhythmOffset)
                .shadow(color:  .white, radius: 10)
                .blur(radius: (1.0 - controller.kickOpacity) * 12)
            
            
            //Vocal bubble
            Circle()
            
                .foregroundStyle(RadialGradient(colors: [.vocalInner, .vocalOuter], center: .center, startRadius: 100, endRadius: 320)
                )
                .opacity(controller.vocalOpacity)
                .scaleEffect(controller.vocalScale, anchor: .center)
                .shadow(color:  Color(red: 0.5, green: 0.235, blue: 0.7), radius: 20)
                .overlay(
                    Circle()
                        .fill(controller.vibeColour.opacity(tintFactor))
                        .stroke(.vocalStroke.mix(with: controller.vibeColour, by: tintFactor),
                                lineWidth: controller.vocalScale * 32)
                        .opacity(controller.vocalOpacity)
                        .scaleEffect(controller.vocalScale, anchor: .center)
                        .shadow(color:  .vocalStroke.mix(with: controller.vibeColour, by: tintFactor), radius: 32 * controller.vocalScale)
                    
                    
                )
                .blur(radius: (1.0 - controller.vocalOpacity) * 20)
                .offset(controller.vocalOffset)

            
            //Instrument bubble
            Circle()
                .foregroundStyle(RadialGradient(colors: [.instInner, .instOuter], center: .center, startRadius: 100, endRadius: 320))
                .opacity(controller.instOpacity)
                .scaleEffect(controller.instScale, anchor: .center)
                .shadow(color:  Color(red: 0.66, green: 0.6, blue: 0.2), radius: 20)
            
                .overlay(
                    Circle()
                        .fill(controller.vibeColour.opacity(tintFactor))
                        .stroke(.instStroke.mix(with: controller.vibeColour, by: 0.2),lineWidth: controller.instScale * 32)
                        .opacity(controller.instOpacity)
                        .scaleEffect(controller.instScale, anchor: .center)
                        .shadow(color:  .instStroke.mix(with: controller.vibeColour, by: tintFactor), radius: 27 * controller.instScale)
                    
                )
                .blur(radius: (1.0 - controller.instOpacity) * 20)

                .offset(controller.instOffset)
            
            
        }
        .blendMode(controller.instOffset == .zero ? .screen : .normal)

        
    }
}

#Preview {
    VisualiserView()
}
