//
//  ImmediatePanG.swift
//  ZHWaveform_Example
//
//  Created by Alvaro Marcos on 23/1/24.
//  Copyright © 2024 wow250250. All rights reserved.
//

import UIKit // (nothing extra needed to import with Swift5)

public class ImmediatePanGestureRecognizer: UIPanGestureRecognizer {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = .began
    }
}
