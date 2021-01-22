//
//  CameraViewControllerExt.swift
//  CameraEx
//
//  Created by EnchantCode on 2021/01/21.
//  Copyright © 2021 EnchantCode. All rights reserved.
//

import AVFoundation
import UIKit

extension CameraViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.detectedObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let detectObjType = self.detectedObjects[indexPath.row].type.rawValue

        cell.textLabel?.text = "\(detectObjType)"
        return cell
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    
    // サンプルバッファの出力をもらっておく
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        self.currentBuffer = sampleBuffer
    }
}

extension CameraViewController: AVCaptureMetadataOutputObjectsDelegate{
    
    // 検出されたメタデータ
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        for object in metadataObjects{
            self.detectedObjects.append(object)
            if(self.detectedObjects.count > 10){
                self.detectedObjects.remove(at: 0)
            }
        }
    }
}
