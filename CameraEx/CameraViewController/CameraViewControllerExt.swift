//
//  CameraViewControllerExt.swift
//  CameraEx
//
//  Created by EnchantCode on 2021/01/21.
//  Copyright © 2021 EnchantCode. All rights reserved.
//

import AVFoundation
import UIKit
import SwiftyJSON

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
        let barcodeObjects = metadataObjects.filter {return [.ean8, .ean13, .code128].contains($0.type)}
        guard let sampledInstance = barcodeObjects.first else {return}
        
        // boundsとpreviewViewのframeからpreviewView上の位置を計算、設定
        // metadataOutputはorientationを変更できないので、適宜座標軸を変更する必要がある
        let bounds = sampledInstance.bounds
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
        
        // バーコードの値を取得
        guard let codeObject = sampledInstance as? AVMetadataMachineReadableCodeObject else {return}
        guard let barcodeValue = codeObject.stringValue else {return}
        
        // 読み取ったことがなければ
        if(!self.detectedCodes.contains(barcodeValue)){
            self.detectedCodes.append(barcodeValue)
            
            // APIに投げる
            let endPoint = "https://shopping.yahooapis.jp/ShoppingWebService/V3/itemSearch"
            guard let response = try? Data(contentsOf: URL(string: "\(endPoint)?appid=\(YAHOO_API_CLIENT_ID)&jan_code=\(barcodeValue)")!) else {return}
            guard let responseJson = try? JSON(data: response) else {return}
            
            // labelに表示
            let productName = responseJson["hits"][0]["name"].string
            self.positionLabel.text = productName
        }
    }
}
