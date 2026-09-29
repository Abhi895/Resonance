//
//  TextCue.swift
//  Resonance
//
//  Created by Abhi Reddy on 22/02/2026.
//

import Foundation

struct TextCue: Codable {
    let start: TimeInterval
    let end: TimeInterval
    let text: String
}
