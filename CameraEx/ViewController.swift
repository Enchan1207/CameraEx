//
//  ViewController.swift
//  CameraEx
//
//  Created by EnchantCode on 2021/01/14.
//  Copyright © 2020 EnchantCode. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    //
    @IBOutlet weak var imageView: UIImageView!
    
    // キャプチャセッション
    var captureSesion = AVCaptureSession()
    // デバイス
    var mainCamera: AVCaptureDevice?
    var innerCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    // 出力
    var photoOutput: AVCaptureVideoDataOutput?
    // 表示レイヤ
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 向き変更を検知
        NotificationCenter.default.addObserver(self, selector: #selector(onOrientationChanged(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        // セットアップ
        setupCaptureSession()
        setupDevice()
        setupCameraIO()
        setupPreviewLayer()
        captureSesion.startRunning()
    }
    
    // 向きが変更された時の処理
    @objc func onOrientationChanged(_ sender: Any){
        // lava casted
    }
    
    // 撮影ボタンがタップされたとき
    @IBAction func onTapShot(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        
        guard let _ = self.photoOutput?.connection(with: AVMediaType.video) else {return}
        
        // 画像データを取得
        print("Get image data...")
        guard let image = self.imageView.image else {return}
        
        // 保存!
        print("Saved.")
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
    }
}

// -カメラ設定用メソッド
extension ViewController{
    
    // カメラの設定
    func setupCaptureSession(){
        self.captureSesion.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    // デバイスの設定
    func setupDevice(){
        // プロパティを「実装位置指定なし」で設定
        let devicediscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        // プロパティに従ってカメラを探し、前と後ろのカメラをそれぞれinner,maincameraに設定
        let devices = devicediscoverySession.devices
        for device in devices{
            if device.position == AVCaptureDevice.Position.back{
                mainCamera = device
            }else if device.position == AVCaptureDevice.Position.front{
                innerCamera = device
            }
        }
        
        // TODO: アクティブ切り替え機能
        currentDevice = mainCamera
    }
    
    // 入出力データの設定
    func setupCameraIO(){
        do {
            // 入力
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            captureSesion.addInput(captureDeviceInput)
            
            // 出力
            photoOutput = AVCaptureVideoDataOutput()
            photoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            
            // デバイス設定
            do{
                try currentDevice?.lockForConfiguration()
                if  let frameRateRange = currentDevice?.activeFormat.videoSupportedFrameRateRanges.first{
                    currentDevice?.activeVideoMaxFrameDuration = frameRateRange.maxFrameDuration
                    currentDevice?.activeVideoMaxFrameDuration = frameRateRange.minFrameDuration
                }
                currentDevice?.unlockForConfiguration()
            } catch {
                print(error)
            }
            
            captureSesion.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    // レイヤの設定
    func setupPreviewLayer(){
        // プレビューレイヤを初期化し、縦横比と向きを設定
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSesion)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        // viewにpreviewlayerを設定
        self.cameraPreviewLayer?.frame = self.imageView.frame
        self.imageView.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
    
}

//
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    //
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let image = captureImage(sampleBuffer: sampleBuffer)
        
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
}

extension ViewController{
    // バッファから画像を取得する
    func captureImage(sampleBuffer: CMSampleBuffer) -> UIImage?{
        // イメージバッファを取得
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return nil}
        
        // CIImageに変換
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let ciContext = CIContext.init(options: nil)
        
        // CIImageからCGImageを生成
        let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent)!
        
        let deviceOrientation = UIDevice.current.orientation
        
        // UIImageにして返す
        return UIImage(cgImage: cgImage, scale: 0, orientation: .right)
    }
}
