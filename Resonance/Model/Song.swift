//
//  Song.swift
//  Resonance
//
//  Created by Abhi Reddy on 18/02/2026.
//

import Foundation

struct Song: Codable {
    var name: String?
    let vibe: [VibeSegment]?
    let data: [DataPoint]
    var base: [String: Double]?
    var mult: [String: Double]?
    var cues: [TextCue]?
    var duration: CGFloat?
}
