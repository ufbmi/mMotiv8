//
//  FFTHelper.swift
//  mMotiv8
//
//  Created by UF on 20/12/18.
//  Copyright © 2018 UF. All rights reserved.
//

import Accelerate

protocol FFTHelperDelegate: AnyObject {
    func didMeasureFrequency(frequency : Int)
}

class FFTHelper {
    
    weak var delegate:FFTHelperDelegate?
    
    private let sampleRate = SmokerlyzerAPIConstants().sampleRate
    private let frameSize = SmokerlyzerAPIConstants().frameSize

    var nyquistFrequency: Float {
        get {
            return Float(sampleRate) / 2.0
        }
    }
    
    //Accumulator Variables
    private let accumulatorDataLength : Int = SmokerlyzerAPIConstants().fftHelperAccumulatorDataLength
    private var accumulatorFillIndex : Int = 0
    private var dataAccumulator: [Float] = []
    
    init(withDelegate delegate : FFTHelperDelegate!) {
        
        if delegate != nil {
            
            self.delegate = delegate
        }
    }
    
    //Accumulator Functions
    func initializeAccumulator(){
        
        dataAccumulator = [Float](repeating: 0, count: accumulatorDataLength)
        accumulatorFillIndex = 0
    }
    
    func emptyAccumulator(){
        
        accumulatorFillIndex = 0
        dataAccumulator = [Float](repeating: 0, count: accumulatorDataLength)
    }
    
    func accumulateFrames(frames : [Float])->Bool{
        
        if accumulatorFillIndex >= accumulatorDataLength {
            
            return true
        }
        else
        {
            let length = frames.count
            let low = accumulatorFillIndex
            let high = accumulatorFillIndex + length
            
            if high > accumulatorDataLength {
                return true
            }
            
            dataAccumulator.replaceSubrange(low...high-1, with: frames)
            
            accumulatorFillIndex = accumulatorFillIndex + length
            
            if accumulatorFillIndex >= accumulatorDataLength {
                
                return true
            }
        }
        
        return false
    }
    
    func receiveFrames(frames : [Float]){
        
        if accumulateFrames(frames: frames) == true {
            
            let maxHz = strongestFrequency()
            
            if delegate != nil{
                delegate!.didMeasureFrequency(frequency: Int(maxHz))
            }
            
            emptyAccumulator()
        }
    }
    
    func strongestFrequency() -> Float{
        
        //ComputeFFT
        var outFFTData = computeFFT()
        
        outFFTData[0] = 0.0
        let length = vDSP_Length(accumulatorDataLength/2)
        var max : Float = 0
        var maxIndex : vDSP_Length = 0
        
        vDSP_maxvi(outFFTData, 1, &max, &maxIndex, length);
        
        let HZ = (Float32(maxIndex)/Float32(length)) * Float32(nyquistFrequency)
        
        return HZ
    }
    
    func computeFFT() -> [Float]{
        
        let nOver2 = CLong(accumulatorDataLength/2)
        let log2n = vDSP_Length(log2f(Float(accumulatorDataLength)))
        
        var mFFTNormFactor : Float = 1.0/Float(2*accumulatorDataLength)
        let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))
        
        var outFFTData  : [Float] = [Float](repeating: 0, count: nOver2)
        
        var windowBuffer : [Float] = [Float](repeating: 0, count: accumulatorDataLength)
        
        vDSP_blkman_window(&windowBuffer, vDSP_Length(accumulatorDataLength), 0)
        vDSP_vmul(dataAccumulator, 1, windowBuffer, 1, &dataAccumulator, 1, vDSP_Length(accumulatorDataLength));
        
        var realp = [Float]()
        var imagp = [Float]()
        
        for (index, element) in dataAccumulator.enumerated() {
            if index % 2 == 0 {
                realp.append(element)
            } else {
                imagp.append(element)
            }
        }
        
        var splitComplex = DSPSplitComplex(realp: UnsafeMutablePointer(mutating: realp), imagp: UnsafeMutablePointer(mutating: imagp))
        
        vDSP_fft_zrip(fftSetup!, &splitComplex, 1, log2n, FFTDirection(kFFTDirection_Forward))
        
        //Take the fft and scale appropriately
        vDSP_vsmul(splitComplex.realp, 1, &mFFTNormFactor, splitComplex.realp, 1, vDSP_Length(nOver2))
        vDSP_vsmul(splitComplex.imagp, 1, &mFFTNormFactor, splitComplex.imagp, 1, vDSP_Length(nOver2))
        
        vDSP_zvmags(&splitComplex, 1, &outFFTData, 1, vDSP_Length(nOver2))
        
        return outFFTData
    }
}
