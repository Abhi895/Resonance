//
//  AudioEngine.swift
//  Resonance
//
//  Created by Abhi Reddy on 18/02/2026.
//

//TODO: finetune for all tracks

import AVFoundation
import Combine

class AudioEngine: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    
    private let engine = AVAudioEngine()
    private let mixer = AVAudioMixerNode()
    private let player = AVAudioPlayerNode()
    private var file: AVAudioFile?
    var currentSong: Song?
    private var jsonSampleRate: Double = 0.0
    
        
    private(set) var songStartTime: AVAudioTime?
    
    init() {
        engine.attach(player)
        engine.attach(mixer)
        engine.connect(player, to: mixer, format: nil)
        engine.connect(mixer, to: engine.outputNode, format: nil)
    }
    
    func load(songName: String) {
        currentSong = getSong(songName: songName.lowercased())
        
        guard let url = Bundle.main.url(forResource: songName.lowercased(), withExtension: "wav") else {
            print("File not found in bundle")
            return
        }
        
        do {
            let audioFile = try AVAudioFile(forReading: url)
            self.file = audioFile
            player.stop()

            engine.disconnectNodeOutput(player)
            engine.connect(player, to: mixer, format: audioFile.processingFormat)

            player.scheduleFile(audioFile, at: nil, completionHandler: nil)

            if !engine.isRunning {
                engine.prepare()
                try engine.start()
            }

            player.play()
                   
            songStartTime = AVAudioTime(sampleTime: 0, atRate: audioFile.processingFormat.sampleRate)
            
        } catch {
            print("Failed to load audio file: \(error)")
        }
    }
    
    func pause() {
        player.pause()
    }
    
    func play() {
        player.play()
    }
    
    func stop() {
        player.stop()
    }
    
    func getCurrentPlaybackTime() -> TimeInterval? {
        guard let lastRenderTime = player.lastRenderTime,
              let playerTime = player.playerTime(forNodeTime: lastRenderTime) else {
            return nil
        }
        
        guard let startTime = songStartTime else { return nil }
        return Double(playerTime.sampleTime) / startTime.sampleRate
    }
    
    
    func getSong(songName: String) -> Song? {
        guard let url = Bundle.main.url(forResource: songName, withExtension: "json") else {
            print("Could not find JSON")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            var song = try decoder.decode(Song.self, from: data)
            song.name = songName
            switch songName {
            case "edm":
                song.base = ["kick": 0.215, "vocal": 0.27, "inst": 0.23]
                song.mult = ["kick": 0.25, "vocal": 1.1, "inst": 0.9]
            case "rock":
                song.base = ["kick": 0.24, "vocal": 0.25, "inst": 0.25]
                song.mult = ["kick": 0.6, "vocal": 1.1, "inst": 1.7]
            case "acoustic":
                song.base = ["kick": 0.22, "vocal": 0.24, "inst": 0.26]
                song.mult = ["kick": 0.2, "vocal": 0.9, "inst": 1]
            default:
                song.base = ["kick": 0.25, "vocal": 0.29, "inst": 0.27]
                song.mult = ["kick": 0.3, "vocal": 0.6, "inst": 2]
            }
            
            if let lastPoint = song.data.last, song.data.count > 1 {
                let timePerFrame = lastPoint.t / Double(song.data.count - 1)
                
                self.jsonSampleRate = 1.0 / timePerFrame
            }
            
            return song
        } catch {
            print("Error decoding JSON: \(error)")
        }
        
        
        return nil
    }
    
    func closest(to time: TimeInterval) -> DataPoint? {
        guard let data = currentSong?.data, !data.isEmpty, jsonSampleRate > 0 else {
            return nil
        }
        
        let rawIndex = Int(time * jsonSampleRate)
        let safeIndex = max(0, min(rawIndex, data.count - 1))
        return data[safeIndex]
    }
    
    
    
}
