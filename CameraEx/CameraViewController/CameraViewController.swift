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
    @IBOutlet weak var objectListView: UITableView!
    
    var detectedObjects: [AVMetadataObject] = []
    private let context = CIContext()
    
    private let captureSession = AVCaptureSession()
    private var isPrepared = false
    var currentBuffer: CMSampleBuffer?
    
    let videoOutput = AVCaptureVideoDataOutput()
    
    var device: AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デバイス設定
        self.setupDeviceIO()
        
        // レイヤ設定
        self.previewView.videoPreviewLayer.session = self.captureSession
        
        // オブジェクトリストビュー設定
        self.objectListView.dataSource = self
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateDetectionList), userInfo: nil, repeats: true)
        
        print("Configured.")
        self.isPrepared = true
    }
    
    @objc func updateDetectionList(){
        self.objectListView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.updateOrientation()
        self.captureSession.startRunning()
        print("Session start")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.captureSession.stopRunning()
        print("Session stop")
    }
    
    // TODO: not work
    override var shouldAutorotate: Bool{
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.updateOrientation()
    }
    
    // デバイス構成
    func setupDeviceIO(){
        // デバイスのフレームレートやらを設定
        guard let device = self.device else {return}
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
        
        // カメラ入力構成
        guard let captureInput = try? AVCaptureDeviceInput(device: device) else{
            fatalError("Can't attach input!")
        }
        self.captureSession.addInput(captureInput)
        
        // カメラ出力構成
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        self.captureSession.addOutput(self.videoOutput)
        
        // メタデータ出力構成
        let metaOutput = AVCaptureMetadataOutput()
        self.captureSession.addOutput(metaOutput)
        metaOutput.rectOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
        metaOutput.metadataObjectTypes = metaOutput.availableMetadataObjectTypes
        metaOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
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
    
    // videocaptureOutputの出力の向きを設定
    func updateOrientation(){
        guard let interfaceOrientation = self.view.window?.windowScene?.interfaceOrientation else {return}
        let orientation = self.getVideoOrientation(interfaceOrientation)
        
        self.videoOutput.connection(with: .video)?.videoOrientation = orientation
    }
    
    // UIInterfaceOrientation -> AVCaptureVideoOrientation
    func getVideoOrientation(_ from: UIInterfaceOrientation) -> AVCaptureVideoOrientation{
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
