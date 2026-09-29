//
//  AudioAnalyser.swift
//  Resonance
//
//  Created by Abhi Reddy on 21/01/2026.
//
//
//import AVFoundation
//import Accelerate
//import CoreHaptics
//internal import Combine
//
//class AudioAnalyser: ObservableObject {
//    private var audioEngine = AVAudioEngine()
//    private var player = AVAudioPlayerNode()
//    private var mixer = AVAudioMixerNode()
//    private var bufferSize: AVAudioFrameCount = 2048
//    private var file: AVAudioFile?
//    private var fftSetup: FFTSetup?
//    private var log2n: vDSP_Length = 0
//
//    var paused: Bool = false
//    
//    private var previousBass: Float = 0
//    private var previousHigh: Float = 0
//    private var lastKickTime: TimeInterval = 0
//    private let minTimeBetweenKicks: TimeInterval = 0.15
//    @Published var lastMidRangeTime: TimeInterval = -9999
//    @Publ let maxTimeBetweenMidRange: TimeInterval = 3
//    
//    private var continuousPlayer: CHHapticAdvancedPatternPlayer?
//    private var isPurring = false
//    
//    private var engine: CHHapticEngine?
//    // Output values
//    
//    @Published var rhythm: Float = 0
//    @Published var harmony: Float = 0
//    @Published var energy: Float = 1.0
//
//    static let shared = AudioAnalyser()
//    
//    func load() {
//        do {
//            let session = AVAudioSession.sharedInstance()
//            
//            try session.setCategory(.playback, mode: .default)
//            try session.setActive(true)
//        } catch {
//            print("Session Error: \(error)")
//        }
//        
//        prepareHaptics()
//        
//        if let url = Bundle.main.url(forResource: "testSong4", withExtension: "mp3") {
//            do {
//                try file = AVAudioFile(forReading: url)
//                
////                let sampleRate = Float(file!.processingFormat.sampleRate)
//                
//                audioEngine.attach(player)
//                audioEngine.attach(mixer)
//                
//                audioEngine.connect(player, to: mixer, format: file?.processingFormat)
//                audioEngine.connect(mixer, to: audioEngine.outputNode, format: nil)
//                
//                log2n = vDSP_Length(log2(Float(self.bufferSize)))
//                
//                fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))
//                
//                let mixerFormat = mixer.outputFormat(forBus: 0)
//                
//                mixer.installTap(onBus: 0, bufferSize: bufferSize, format: mixerFormat) { buff, time in
//                    self.processBuffer(buff)
//                }
//                //                audioEngine.mainMixerNode.outputVolume = 0
//                player.scheduleFile(file!, at: nil, completionHandler: nil)
//                
//                try audioEngine.start()
//                player.play()
//                
//            } catch {
//                print("NO FILE")
//            }
//        } else {
//            print("File not found in bundle")
//        }
//    }
//    
//    func replay() {
//        
//        if let url = Bundle.main.url(forResource: "testSong4", withExtension: "mp3") {
//            do {
//                try file = AVAudioFile(forReading: url)
//                player.stop() // Stop and clear queue
//                player.scheduleFile(file!, at: nil, completionHandler: nil) // Reschedule from start
//                player.play()
//            } catch {
//                print("error")
//            }
//
//        }
//
//    }
//    private func processBuffer(_ buffer: AVAudioPCMBuffer) {
//        guard let fftSetup = fftSetup,
//              let channelData = buffer.floatChannelData?[0] else { return }
//        
//        let halfSize = Int(bufferSize) / 2
//        var real = [Float](repeating: 0, count: halfSize)
//        var imag = [Float](repeating: 0, count: halfSize)
//        var magnitudes = [Float](repeating: 0, count: halfSize)
//        
//        real.withUnsafeMutableBufferPointer { realPtr in
//            imag.withUnsafeMutableBufferPointer { imagPtr in
//                magnitudes.withUnsafeMutableBufferPointer { magPtr in
//                    var splitComplex = DSPSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
//                    
//                    let length = vDSP_Length(halfSize)
//                    channelData.withMemoryRebound(to: DSPComplex.self, capacity: halfSize) { typeConvertedTransferBuffer in
//                        vDSP_ctoz(typeConvertedTransferBuffer, 2, &splitComplex, 1, length)
//                    }
//                    
//                    vDSP_fft_zrip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
//                    vDSP_zvabs(&splitComplex, 1, magPtr.baseAddress!, 1, length)
//                    
//                    var multiplier: Float = 1.0 / Float(bufferSize)
//                    vDSP_vsmul(magPtr.baseAddress!, 1, &multiplier, magPtr.baseAddress!, 1, length)
//                }
//            }
//        }
//        
//        // Frequency bands
//        let bassEnergy = magnitudes[1...20].reduce(0, +)
//        let midEnergy = magnitudes[21...250].reduce(0, +)
//        let highEnergy = magnitudes[251...500].reduce(0, +)
//        //        let totalEnergy = (highEnergy + midEnergy + bassEnergy) / 3
//        
//        let now = Date().timeIntervalSince1970
//        
//        let bassDifference = bassEnergy - self.previousBass
//        
//        
//        let bleedEstimate = bassEnergy * 0.5
//        let cleanMids = max(0, midEnergy - bleedEstimate)
//        
//        let isKick = bassDifference > 0.1  && (now - self.lastKickTime > self.minTimeBetweenKicks)
//        
//        if isKick {
//            self.lastKickTime = now
//            self.playHapticKick()
//        }
//        
//        // SPARK: High-frequency transients
//        //        let highDifference = highEnergy - self.previousHigh
//        //        let rawSpark = highDifference > 0 ? highDifference * 15.0 : 0
//        //        if bassDifference && highDifference >
//        //        if !paused {
//        //            print([bassDifference, highDifference])
//        //        }
//        
//        //        if totalEnergy <= min && totalEnergy > 0 {
//        //            min = totalEnergy
//        //            print("MINIMUM")
//        //        }
//        //
//        //        print(totalEnergy)
//        
//        DispatchQueue.main.async {
//            if isKick {
//                self.rhythm = Swift.min(bassEnergy * 8.0, 1.0)
//            } else {
//                self.rhythm = self.rhythm * 0.9
//            }
//
//            let targetSize = min(sqrt(cleanMids) * 0.2, 0.5)
//            
//            print(targetSize)
//
//            let timeSinceLastVocal = now - self.lastMidRangeTime
//
//            if targetSize > self.harmony {
//                print(self.lerp(start: self.harmony, end: targetSize, factor: 0.2))
//                self.harmony = min(self.lerp(start: self.harmony, end: targetSize, factor: 0.2), 0.22)
//            } else {
//                self.harmony = self.lerp(start: self.harmony, end: targetSize, factor: 0.6)
//            }
//        
//
//            self.previousBass = bassEnergy
//            self.previousHigh = highEnergy
//        }
//    }
//        
//    func prepareHaptics() {
//        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
//        
//        do {
//            self.engine = try CHHapticEngine()
//            try engine?.start()
//            
//            self.engine?.resetHandler = { [weak self] in
//                try? self?.engine?.start()
//            }
//        } catch {
//            print("Failed to create engine: \(error)")
//        }
//    }
//    
//    func playHapticKick() {
//            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
//            guard let engine = engine else { return }
//            
//            // 1. Define the "Hit" (Max Power)
//            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
//            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1) // Low sharpness = Heavy
//            
//            // 2. Stack them extremely close together
//            // This creates a "constructive interference" effect in the motor
//            let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
//            let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.01) // +10ms
//            let event3 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.02) // +20ms
//            
//            do {
//                let pattern = try CHHapticPattern(events: [event1, event2, event3], parameters: [])
//                let player = try engine.makePlayer(with: pattern)
//                try player.start(atTime: 0)
//            } catch {
//                print("Failed to play haptic: \(error)")
//            }
//        }
//    
//    func playHapticHarmony(intensity: Float) {
//            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
//            guard let engine = engine else { return }
//            
//            // 1. Define the "Hit" (Max Power)
//            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
//            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5) // Low sharpness = Heavy
//            
//            // 2. Stack them extremely close together
//            // This creates a "constructive interference" effect in the motor
//            let haptic = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
//            
//            do {
//                let pattern = try CHHapticPattern(events: [haptic], parameters: [])
//                let player = try engine.makePlayer(with: pattern)
//                try player.start(atTime: 0)
//            } catch {
//                print("Failed to play haptic: \(error)")
//            }
//        }
    
//    func startHarmonyHaptic() {
//            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
//            guard let engine = engine else { return }
//            
//            // 1. Create a Continuous Event (The "Hum")
//            // Duration: "Indefinite" (run until we stop it)
//            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.0) // Start Silent
//            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.0) // Soft/Dull
//            
//            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 100)
//            
//            do {
//                let pattern = try CHHapticPattern(events: [event], parameters: [])
//                // "Advanced" player allows real-time updates
//                self.continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
//                try self.continuousPlayer?.start(atTime: 0)
//                self.isPurring = true
//            } catch {
//                print("Failed to start purr: \(error)")
//            }
//        }
//    
//    func updateHarmonyHaptic(energy: Float) {
//            guard let player = continuousPlayer, isPurring else { return }
//            
//            // MAP AUDIO TO HAPTIC
//            // Audio (0.0 - 1.0) -> Haptic Intensity (0.0 - 0.3)
//            // CRITICAL: Max intensity must be LOW (0.3).
//            // If it goes higher, it will overpower the Kick Drum.
//            let targetIntensity = min(energy * 0.3, 0.4)
//            
//            // Create the update parameter
//            let intensityParam = CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: targetIntensity, relativeTime: 0)
//            
//            // Send it to the motor
//            do {
//                try player.sendParameters([intensityParam], atTime: 0)
//            } catch {
//                print("Failed to update haptic: \(error)")
//            }
//        }
//    
//    func lerp(start: Float, end: Float, factor: Float) -> Float {
//        return start + (end - start) * factor
//    }
//}
//
