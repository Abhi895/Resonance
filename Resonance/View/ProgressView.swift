//
//  ProgressView.swift
//  Resonance
//
//  Created by Abhi Reddy on 23/02/2026.
//

import SwiftUI

struct ProgressView: View {
    
    @EnvironmentObject var controller: RenderEngine
    
    var body: some View {
        VStack(spacing: 15) {
            
            if !controller.tutFinishing {
                
                Text(controller.heading)
                    .foregroundStyle(.white)
                    .font(.system(size: 46, weight: .semibold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .opacity(controller.headingOpacity)
                
                HStack(spacing: 10) {
                    ProgressBarView(barWidth: controller.rhythmWidth, barColours: [.white])
                    ProgressBarView(barWidth: controller.vocalsWidth, barColours: [.vocalInner, .vocalOuter, .vocalStroke])
                    ProgressBarView(barWidth: controller.instWidth, barColours: [.instInner, .instOuter, .instStroke])
                }
                .background(.black)
            }
        }
        .frame(height: 100)
    }
}

struct ProgressBarView: View {
    
    let barWidth: CGFloat
    let barColours: [Color]
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(LinearGradient(colors: barColours, startPoint: .leading, endPoint: .trailing))
        
        
            .mask(alignment: .leading) {
                Rectangle()
                    .frame(width: max(0, barWidth))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white, lineWidth: 1)
            }
            .frame(width: 70, height: 9)
    }
}

#Preview {
    ProgressView()
}
