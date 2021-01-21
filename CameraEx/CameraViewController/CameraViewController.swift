//
//  CameraViewController.swift
//  CameraEx
//
//  Created by EnchantCode on 2021/01/21.
//  Copyright © 2021 EnchantCode. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    @IBOutlet weak var previewView: PreviewView!
    
    private let captureSession = AVCaptureSession()
    var device: AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupDeviceIO()
        self.previewView.videoPreviewLayer.session = self.captureSession
        print("Configured.")
    }
    
    // デバイス構成
    func setupDeviceIO(){
        guard let device = self.device else {return}
        
        guard let captureInput = try? AVCaptureDeviceInput(device: device) else{
            fatalError("Can't attach input!")
        }
        self.captureSession.addInput(captureInput)
        
        let photoOutput = AVCaptureVideoDataOutput()
        do{
            try device.lockForConfiguration()
            if  let frameRateRange = device.activeFormat.videoSupportedFrameRateRanges.first{
                
                device.activeVideoMinFrameDuration = frameRateRange.maxFrameDuration
                device.activeVideoMaxFrameDuration = frameRateRange.minFrameDuration
                
            }
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
        
        self.captureSession.addOutput(photoOutput)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.captureSession.startRunning()
        print("Session start")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.captureSession.stopRunning()
        print("Session stop")
    }
    
    @IBAction func onTapShutter(_ sender: Any) {
        // TODO: シャッター
        

    }

}
