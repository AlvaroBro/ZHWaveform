//
//  ZHTrackProcessing.swift
//  ZHWaveform_Example
//
//  Created by wow250250 on 2018/1/2.
//  Copyright © 2018年 wow250250. All rights reserved.
//

import UIKit
import AVFoundation

struct ZHTrackProcessing {
    public static func cutAudioData(size: CGSize, recorder data: NSData, scale: CGFloat) -> [CGFloat] {
        var filteredSamplesMA: [CGFloat] = []
        let sampleCount = data.length / MemoryLayout<Int16>.size
        let binSize = Int(CGFloat(sampleCount) / (size.width * scale))
        var i = 0
        while i < sampleCount {
            let binEnd = min(i + binSize, sampleCount)
            var sum: Int = 0
            var count: Int = 0
            while i < binEnd {
                let byteIndex = i * MemoryLayout<Int16>.size
                if byteIndex + MemoryLayout<Int16>.size <= data.length {
                    let rangeData = data.subdata(with: NSRange(location: byteIndex, length: MemoryLayout<Int16>.size))
                    let item: Int16 = rangeData.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> Int16 in
                        guard let address = pointer.baseAddress else { return 0 }
                        return address.assumingMemoryBound(to: Int16.self).pointee
                    }
                    sum += Int(item) * Int(item)
                    count += 1
                }
                i += 1
            }
            let averageEnergy = count > 0 ? sqrt(CGFloat(sum) / CGFloat(count)) : 0
            filteredSamplesMA.append(averageEnergy)
        }
        return trackScale(size: size, source: filteredSamplesMA)
    }
    
    private static func trackScale(size: CGSize, source: [CGFloat]) -> [CGFloat] {
        let lowerThreshold: CGFloat = 200
        let upperThreshold: CGFloat = 1000
        let filteredSamples = source.map { $0 > lowerThreshold ? $0 : 0 }
        let max = filteredSamples.max() ?? 0
        let allBelowUpperThreshold = filteredSamples.allSatisfy { $0 < upperThreshold }
        let k: CGFloat
        if allBelowUpperThreshold {
            k = size.height / upperThreshold
        } else {
            k = max != 0 ? size.height / max : 0
        }
        return filteredSamples.map { $0 * k }
    }
}
