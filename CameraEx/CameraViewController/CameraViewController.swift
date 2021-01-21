//
//  CameraViewController.swift
//  CameraEx
//
//  Created by EnchantCode on 2021/01/21.
//  Copyright © 2021 EnchantCode. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage
import Photos

class CameraViewController: UIViewController {

    @IBOutlet weak var previewView: PreviewView!
    
    private let context = CIContext()
    
    private let captureSession = AVCaptureSession()
    private var isPrepared = false
    var currentBuffer: CMSampleBuffer?
    
    var device: AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 向き変更検知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onOrientationChanged(_:)),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        
        // デバイス設定
        self.setupDeviceIO()
        
        // レイヤ設定
        self.previewView.videoPreviewLayer.session = self.captureSession
        self.previewView.videoPreviewLayer.connection?.videoOrientation = self.getVideoOrientation(UIDevice.current.orientation)
        
        print("Configured.")
        self.isPrepared = true
    }
    
    // デバイス構成
    func setupDeviceIO(){
        guard let device = self.device else {return}
        
        guard let captureInput = try? AVCaptureDeviceInput(device: device) else{
            fatalError("Can't attach input!")
        }
        
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
        
        self.captureSession.addInput(captureInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        self.captureSession.addOutput(videoOutput)
    }
    
    @objc func onOrientationChanged(_ sender: Any){
        self.previewView.videoPreviewLayer.connection?.videoOrientation = self.getVideoOrientation(UIDevice.current.orientation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.captureSession.startRunning()
        print("Session start")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.captureSession.stopRunning()
        print("Session stop")
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // サンプルバッファからCIImageを生成
    func createImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CIImage? {
        // イメージバッファを取得
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return nil}
        
        // CIImageに変換
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        return ciImage
    }

    // Data型の画像データをフォトライブラリに保存
    func saveImage(data: Data, completionHandler: ((Bool, Error?) -> Void)? = nil){
        PHPhotoLibrary.requestAuthorization { (status) in
            // 許可ステータス
            let successStatus: [PHAuthorizationStatus]
            if #available(iOS 14, *) {
                successStatus = [.authorized, .limited]
            } else {
                successStatus = [.authorized]
            }
            guard successStatus.contains(status) else {return}
            
            // 新規アセット作成を要求
            PHPhotoLibrary.shared().performChanges( {
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: data, options: nil)
            }, completionHandler: completionHandler)
            
        }
    }
    
    // UIDevice.orientation -> AVCaptureVideoOrientation
    func getVideoOrientation(_ from: UIDeviceOrientation) -> AVCaptureVideoOrientation{
        switch from {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    // シャッター
    @IBAction func onTapShutter(_ sender: Any) {
        guard self.isPrepared else {return}
        guard let currentBuffer = self.currentBuffer else {return}
        guard let bufferImage = self.createImageFromSampleBuffer(sampleBuffer: currentBuffer) else {return}
        guard let imageData = UIImage(ciImage: bufferImage).pngData() else {return}
        
        saveImage(data: imageData)
    }
    
}
