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
                let rangeData = data.subdata(with: NSRange(location: i * MemoryLayout<Int16>.size, length: MemoryLayout<Int16>.size))
                let item: Int16 = rangeData.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> Int16 in
                    guard let address = pointer.baseAddress else { return 0 }
                    return address.assumingMemoryBound(to: Int16.self).pointee
                }
                sum += Int(item)
                count += 1
                i += 1
            }
            let average = count > 0 ? CGFloat(sum) / CGFloat(count) : 0
            filteredSamplesMA.append(average)
        }
        return trackScale(size: size, source: filteredSamplesMA)
    }
    
    private static func trackScale(size: CGSize, source: [CGFloat]) -> [CGFloat] {
        let max = source.max() ?? 0
        let k = max != 0 ? size.height / max : 0
        return source.map { $0 * k }
    }
}
