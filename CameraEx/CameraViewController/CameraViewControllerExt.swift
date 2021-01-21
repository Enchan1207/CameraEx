//
//  CameraViewControllerExt.swift
//  CameraEx
//
//  Created by EnchantCode on 2021/01/21.
//  Copyright © 2021 EnchantCode. All rights reserved.
//

import AVFoundation
import UIKit

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        self.currentBuffer = sampleBuffer
    }
}
