//
//  ZHWaveformView.swift
//  ZHWaveform_Example
//
//  Created by wow250250 on 2018/1/2.
//  Copyright © 2018年 wow250250. All rights reserved.
//

import UIKit
import AVFoundation

@objc public class ZHWaveformView: UIView {
    
    /** waves color */
    @objc public var wavesColor: UIColor = .red {
        didSet {
            DispatchQueue.main.async {
                _ = self.trackLayer.map({ [unowned self] in
                    $0.strokeColor = self.wavesColor.cgColor
                })
            }
        }
    }
    
    /** Cut off the beginning part color */
    @objc public var beginningPartColor: UIColor = .gray
    
    /** Cut out the end part color */
    @objc public var endPartColor: UIColor = .gray
    
    /** Track Scale normal 0.5, max 1*/
    @objc public var trackScale: CGFloat = 0.5 {
        didSet {
            if let `assetMutableData` = assetMutableData {
                croppedViewZero()
                trackProcessingCut = ZHTrackProcessing.cutAudioData(size: self.frame.size, recorder: assetMutableData, scale: trackScale)
                drawTrack(
                    with: CGRect(x: (startCroppedView?.bounds.width ?? 0),
                                 y: 0,
                                 width: self.frame.width - (startCroppedView?.bounds.width ?? 0) - (endCroppedView?.bounds.width ?? 0),
                                 height: self.frame.height),
                    filerSamples: trackProcessingCut ?? []
                )
            }
        }
    }
    
    @objc public weak var croppedDelegate: ZHCroppedDelegate? {
        didSet { layoutIfNeeded() }
    }
    
    @objc public weak var waveformDelegate: ZHWaveformViewDelegate?
    
    private var fileURL: URL?
    
    private var asset: AVAsset?
    
    private var track: AVAssetTrack?
    
    private var trackLayer: [CAShapeLayer] = []
    
    private var startCroppedView: UIView?
    
    private var endCroppedView: UIView?
    
    private var leftCroppedCurrentX: CGFloat = 0
    
    private var rightCroppedCurrentX: CGFloat = 0
    
    private var trackWidth: CGFloat = 0
    
    private var startCroppedIndex: Int = 0
    
    private var endCroppedIndex: Int = 0
    
    private var trackProcessingCut: [CGFloat]?
    
    private var assetMutableData: NSMutableData?
    
    override init(frame: CGRect) {
        self.fileURL = nil
        super.init(frame: frame)
    }
    
    @objc public init(frame: CGRect, fileURL: URL) {
        super.init(frame: frame)
        configure(frame: frame, fileURL: fileURL)
    }

    @objc public func configure(frame: CGRect, fileURL: URL) {
        waveformDelegate?.waveformViewStartDrawing?(waveformView: self)
        self.fileURL = fileURL
        self.frame = frame
        asset = AVAsset(url: fileURL)
        track = asset?.tracks(withMediaType: .audio).first
        
        ZHAudioProcessing.bufferRef(asset: asset!, track: track!, success: { [unowned self] (data) in
            self.assetMutableData = data
            if (frame != .zero) {
                self.trackProcessingCut = ZHTrackProcessing.cutAudioData(size: frame.size, recorder: data, scale: self.trackScale)
                self.drawTrack(with: CGRect(origin: .zero, size: frame.size), filerSamples: self.trackProcessingCut ?? [])
                self.waveformDelegate?.waveformViewDrawComplete?(waveformView: self)
            }
        }) { (error) in
            assert(true, error?.localizedDescription ?? "Error, AudioProcessing.bufferRef")
        }
    }
    
    @objc public func resetView() {
        asset = nil
        track = nil
        trackLayer.forEach { $0.removeFromSuperlayer() }
        trackLayer.removeAll()
        startCroppedView?.removeFromSuperview()
        endCroppedView?.removeFromSuperview()
        assetMutableData = nil
        trackProcessingCut = nil
        leftCroppedCurrentX = 0
        rightCroppedCurrentX = 0
        startCroppedIndex = 0
        endCroppedIndex = 0
        trackWidth = 0
    }
    
    override public func layoutIfNeeded() {
        super.layoutIfNeeded()
        if let samples = trackProcessingCut {
            creatCroppedView()
            drawTrack(
                with: CGRect(x: startCroppedView?.bounds.width ?? 0,
                             y: 0,
                             width: frame.width - (startCroppedView?.bounds.width ?? 0) - (endCroppedView?.bounds.width ?? 0),
                             height: frame.height),
                filerSamples: samples
            )
        }
    }
    
    private func drawTrack(with rect: CGRect, filerSamples: [CGFloat]) {
        _ = trackLayer.map{ $0.removeFromSuperlayer() }
        trackLayer.removeAll()
        startCroppedView?.removeFromSuperview()
        endCroppedView?.removeFromSuperview()
        // bezier width
        trackWidth = rect.width / (CGFloat(filerSamples.count - 1) + CGFloat(filerSamples.count))
        endCroppedIndex = filerSamples.count
        for t in 0..<filerSamples.count {
            let layer = CAShapeLayer()
            layer.frame = CGRect(
                x: CGFloat(t) * trackWidth * 2 + (startCroppedView?.bounds.width ?? 0),
                y: 0,
                width: trackWidth,
                height: rect.height
            )
            layer.lineCap = CAShapeLayerLineCap.butt
            layer.lineJoin = CAShapeLayerLineJoin.round
            layer.lineWidth = trackWidth
            layer.strokeColor = wavesColor.cgColor
            self.layer.addSublayer(layer)
            self.trackLayer.append(layer)
        }
        
        for i in 0..<filerSamples.count {
            let itemLinePath = UIBezierPath()
            let y: CGFloat = (rect.height - filerSamples[i]) / 2
            let height: CGFloat = filerSamples[i] + y
            itemLinePath.move(to: CGPoint(x: 0, y: y))
            itemLinePath.addLine(to: CGPoint(x: 0, y: height))
            itemLinePath.close()
            itemLinePath.lineWidth = trackWidth
            let itemLayer = trackLayer[i]
            itemLayer.path = itemLinePath.cgPath
        }
        if let l = startCroppedView {
            addSubview(l)
        }
        if let r = endCroppedView {
            addSubview(r)
        }
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ZHWaveformView {
    
    private func croppedViewZero() {
        if let leftCropped = startCroppedView {
            leftCropped.frame = CGRect(x: 0, y: leftCropped.frame.origin.y, width: leftCropped.bounds.width, height: leftCropped.bounds.height)
        }
        if let rightCropped = endCroppedView {
            rightCropped.frame = CGRect(x: bounds.width - rightCropped.bounds.width, y: rightCropped.frame.origin.y, width: rightCropped.bounds.width, height: rightCropped.bounds.height)
        }
        
    }
    
    private func creatCroppedView() {
        if let leftCropped = croppedDelegate?.waveformView(startCropped: self) {
            leftCropped.frame = CGRect(x: 0, y: bounds.height/2 - leftCropped.frame.size.height/2, width: leftCropped.bounds.width, height: leftCropped.bounds.height)
            leftCroppedCurrentX = leftCropped.center.x
            let leftPanRecognizer = ImmediatePanGestureRecognizer(target: self, action: #selector(self.leftCroppedPanRecognizer(sender:)))
            leftCropped.addGestureRecognizer(leftPanRecognizer)
            leftCropped.isUserInteractionEnabled = true
            startCroppedView = leftCropped
        }
        
        if let rightCropped = croppedDelegate?.waveformView(endCropped: self) {
            rightCropped.frame = CGRect(x: bounds.width - rightCropped.bounds.width, y: bounds.height/2 - rightCropped.frame.size.height/2, width: rightCropped.bounds.width, height: rightCropped.bounds.height)
            rightCroppedCurrentX = rightCropped.center.x
            let rightPanRecognizer = ImmediatePanGestureRecognizer(target: self, action: #selector(self.rightCroppedPanRecognizer(sender:)))
            rightCropped.addGestureRecognizer(rightPanRecognizer)
            rightCropped.isUserInteractionEnabled = true
            endCroppedView = rightCropped
        }
    }
    
    @objc private func leftCroppedPanRecognizer(sender: UIPanGestureRecognizer) {
        let limitMinX: CGFloat = 0
        let limitMaxX: CGFloat = endCroppedView?.frame.minX ?? bounds.width
        if sender.state == .began {
            croppedDelegate?.waveformView?(croppedDragIn: startCroppedView ?? UIView())
        } else if sender.state == .changed {
            croppedDelegate?.waveformView?(croppedDragIn: startCroppedView ?? UIView())
            let newPoint = sender.translation(in: self)
            var center = startCroppedView?.center
            center?.x = leftCroppedCurrentX + newPoint.x
            guard (center?.x ?? 0) > limitMinX && (center?.x ?? 0) < limitMaxX else { return }
            startCroppedView?.center = center ?? .zero
        } else if sender.state == .ended || sender.state == .failed {
            croppedDelegate?.waveformView?(croppedDragFinish: startCroppedView ?? UIView())
            leftCroppedCurrentX = startCroppedView?.center.x ?? 0
        }
        if (startCroppedView?.frame.minX ?? 0) < limitMinX {
            var leftFrame = startCroppedView?.frame
            leftFrame?.origin.x = 0
            startCroppedView?.frame = leftFrame ?? .zero
        }
        if (startCroppedView?.frame.maxX ?? 0) > limitMaxX {
            var leftFrame = startCroppedView?.frame
            leftFrame?.origin.x = limitMaxX - (startCroppedView?.frame.width ?? 0)
            startCroppedView?.frame = leftFrame ?? .zero
        }
        let lenght = ceilf(Float((((startCroppedView?.frame.maxX ?? 0) - (startCroppedView?.bounds.width ?? 0)) / trackWidth)))
        let bzrLenght = ceilf(lenght/2)
        startCroppedIndex = Int(bzrLenght) > trackLayer.count ? trackLayer.count : Int(bzrLenght)
        self.croppedWaveform(start: startCroppedIndex, end: endCroppedIndex)
        let bezierWidth = self.frame.width - (startCroppedView?.frame.width ?? 0) - (endCroppedView?.frame.width ?? 0)
        croppedDelegate?.waveformView(startCropped: startCroppedView ?? UIView(), progress: ((startCroppedView?.frame.maxX ?? 0) - (startCroppedView?.frame.width ?? 0))/bezierWidth)
    }
    
    @objc private func rightCroppedPanRecognizer(sender: UIPanGestureRecognizer) {
        let limitMinX: CGFloat = startCroppedView?.frame.maxX ?? 0
        let limitMaxX: CGFloat = bounds.width
        if sender.state == .began {
            croppedDelegate?.waveformView?(croppedStartDragging: endCroppedView ?? UIView())
        } else if sender.state == .changed {
            croppedDelegate?.waveformView?(croppedDragIn: endCroppedView ?? UIView())
            let newPoint = sender.translation(in: self)
            var center = endCroppedView?.center
            center?.x = rightCroppedCurrentX + newPoint.x
            guard (center?.x ?? 0) > limitMinX && (center?.x ?? 0) < limitMaxX else { return }
            endCroppedView?.center = center ?? .zero
        } else if sender.state == .ended || sender.state == .failed {
            croppedDelegate?.waveformView?(croppedDragFinish: endCroppedView ?? UIView())
            rightCroppedCurrentX = endCroppedView?.center.x ?? (bounds.width - (endCroppedView?.bounds.width ?? 0))
        }
        if (endCroppedView?.frame.minX ?? 0) < limitMinX {
            var rightFrame = endCroppedView?.frame
            rightFrame?.origin.x = limitMinX
            endCroppedView?.frame = rightFrame ?? .zero
        }
        if (endCroppedView?.frame.maxX ?? 0) > limitMaxX {
            var rightFrame = endCroppedView?.frame
            rightFrame?.origin.x = limitMaxX - (endCroppedView?.frame.width ?? 0)
            endCroppedView?.frame = rightFrame ?? .zero
        }
        let lenght = ceilf(Float(((endCroppedView?.frame.minX ?? 0) - (startCroppedView?.bounds.width ?? 0)) / trackWidth))
        let bzrLenght = floorf(lenght/2) < 0 ? 0 : ceilf(lenght/2)
        endCroppedIndex = Int(bzrLenght)
        self.croppedWaveform(start: startCroppedIndex, end: endCroppedIndex)
        let bezierWidth = self.frame.width - (startCroppedView?.frame.width ?? 0) - (endCroppedView?.frame.width ?? 0)
        croppedDelegate?.waveformView(endCropped: endCroppedView ?? UIView(), progress: ((endCroppedView?.frame.minX ?? 0) - (startCroppedView?.frame.width ?? 0))/bezierWidth)
    }
    
    @objc public func setStartCroppedIndex(index: Float) {
        guard index >= 0 && index <= 1 else { return }
        let startIndex = Int(index * Float(trackLayer.count))
        guard startIndex <= endCroppedIndex else {return }
        startCroppedIndex = startIndex
        self.croppedWaveform(start: startCroppedIndex, end: endCroppedIndex)
    }
    
    @objc public func setEndCroppedIndex(index: Float) {
        guard index >= 0 && index <= 1 else { return }
        let endIndex = Int(index * Float(trackLayer.count))
        guard endIndex >= startCroppedIndex else {return }
        endCroppedIndex = endIndex
        self.croppedWaveform(start: startCroppedIndex, end: endCroppedIndex)
    }
    
    func croppedWaveform(
        start: Int,
        end: Int
        ) {
        let beginLayers = trackLayer[0..<start]
        let wavesLayers = trackLayer[start..<end]
        let endLayers = trackLayer[end..<trackLayer.count]
        DispatchQueue.main.async {
            _ = beginLayers.map({ [unowned self] in
                $0.strokeColor = self.beginningPartColor.cgColor
            })
            _ = wavesLayers.map({ [unowned self] in
                $0.strokeColor = self.wavesColor.cgColor
            })
            _ = endLayers.map({ [unowned self] in
                $0.strokeColor = self.endPartColor.cgColor
            })
        }
    }
    
}
