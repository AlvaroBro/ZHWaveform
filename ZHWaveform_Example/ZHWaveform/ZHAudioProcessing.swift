//
//  ZHAudioProcessing.swift
//  ZHWaveform_Example
//
//  Created by wow250250 on 2018/1/2.
//  Copyright © 2018年 wow250250. All rights reserved.
//

import UIKit
import AVFoundation

struct ZHAudioProcessing {
    
    typealias BufferRefSuccessHandler = (NSMutableData) -> Swift.Void
    typealias BufferRefFailureHandler = (Error?) -> Swift.Void
    
    public static func bufferRef(
        asset: AVAsset,
        success: BufferRefSuccessHandler?,
        failure: BufferRefFailureHandler?
        ) {
        let data = NSMutableData()
        let dict: [String: Any] = [AVFormatIDKey: kAudioFormatLinearPCM,
                                   AVLinearPCMIsBigEndianKey: false,
                                   AVLinearPCMIsFloatKey: false,
                                   AVLinearPCMBitDepthKey: 16]
        do {
            guard let track = asset.tracks(withMediaType: .audio).first else {
                failure?(nil)
                return
            }
            let reader: AVAssetReader = try AVAssetReader(asset: asset)
            let output: AVAssetReaderTrackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: dict)
            reader.add(output)
            reader.startReading()
            while reader.status == .reading {
                if let sampleBuffer: CMSampleBuffer = output.copyNextSampleBuffer() {
                    if let blockBuffer: CMBlockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) {
                        let length: Int = CMBlockBufferGetDataLength(blockBuffer)
                        var sampleBytes = [Int16](repeating: Int16(), count: length)
                        CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: &sampleBytes)
                        data.append(&sampleBytes, length: length)
                        CMSampleBufferInvalidate(sampleBuffer)
                    }
                }
            }
            if reader.status == .completed {
                success?(data)
            } else {
                failure?(nil)
            }
        } catch let err {
            failure?(err)
        }
    }
}
