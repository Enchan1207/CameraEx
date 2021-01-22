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
    
    // サンプルバッファの出力をもらっておく
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        self.currentBuffer = sampleBuffer
    }
}

extension CameraViewController: AVCaptureMetadataOutputObjectsDelegate{
    
    // 検出されたメタデータ
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // サンプルを一つ取得
        guard let object = metadataObjects.first else {return}
        
        // boundsとpreviewViewのframeからpreviewView上の位置を計算、設定
        // metadataOutputはorientationを変更できないので、適宜座標軸を変更する必要がある
        let bounds = object.bounds
        let previewFrame = previewView.frame
        
        let startPoint = CGPoint(
            x: (1 - bounds.maxY) * previewFrame.width,
            y: bounds.minX * previewFrame.height
        )
        let endPoint = CGPoint(
            x: (1 - bounds.minY) * previewFrame.width,
            y: bounds.maxX * previewFrame.height
        )
        
        let detectRect = CGRect(
            x: startPoint.x,
            y: startPoint.y,
            width: endPoint.x - startPoint.x,
            height: endPoint.y - startPoint.y
        )
        
        self.detectView.frame = detectRect
        
    }
}
