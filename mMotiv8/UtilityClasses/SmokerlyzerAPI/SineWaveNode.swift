//
//  SineWaveNode.swift
//  mMotiv8
//
//  Created by UF on 20/12/18.
//  Copyright © 2018 UF. All rights reserved.
//

import AVFoundation

class SineWaveNode: AVAudioPlayerNode {
    
    let sampleRate = SmokerlyzerAPIConstants().sampleRate
    let frameSize = SmokerlyzerAPIConstants().frameSize

    var frequency = SmokerlyzerAPIConstants().sineWaveFrequency
    var amplitude = SmokerlyzerAPIConstants().sineWaveAmplitude
    
    private var theta: Double = 0.0
    private var audioFormat: AVAudioFormat!
    
    override init() {
        super.init()
        audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)
    }
    
    func prepareBuffer() -> AVAudioPCMBuffer {
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(frameSize))!
        fillBuffer(buffer)
        return buffer
    }
    
    func fillBuffer(_ buffer: AVAudioPCMBuffer) {
        let data = buffer.floatChannelData?[0]
        let numberFrames = buffer.frameCapacity
        var theta = self.theta
        let theta_increment = 2.0 * .pi * self.frequency / self.sampleRate
        
        for frame in 0..<Int(numberFrames) {
            data?[frame] = Float32(sin(theta) * amplitude)
            
            theta += theta_increment
            if theta > 2.0 * .pi {
                theta -= 2.0 * .pi
            }
        }
        buffer.frameLength = numberFrames
        self.theta = theta
    }
    
    func scheduleBuffer() {
        let buffer = prepareBuffer()
        self.scheduleBuffer(buffer) {
            if self.isPlaying {
                self.scheduleBuffer()
            }
        }
    }
    
    func preparePlaying() {
        scheduleBuffer()
    }
}
