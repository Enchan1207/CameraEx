//
//  ViewController.swift
//  CameraEx
//
//  Created by EnchantCode on 2020/01/05.
//  Copyright © 2020 EnchantCode. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    //--
    @IBOutlet weak var imageView: UIImageView!
    
    //--キャプチャセッション
    var captureSesion = AVCaptureSession()
    //--デバイス
    var mainCamera: AVCaptureDevice?
    var innerCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    //--出力
    var photoOutput: AVCapturePhotoOutput?
    //--表示レイヤ
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    //--
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //--
        setupCaptureSession()
        setupDevice()
        setupCameraIO()
        setupPreviewLayer()
        captureSesion.startRunning()
    }
    
    @IBAction func onTapShot(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
//        if var _:AVCaptureConnection = self.photoOutput?.connection(with: AVMediaType.video){
//            UIImageWriteToSavedPhotosAlbum(self.imageView.image!, nil, nil, nil)
//        }
        self.photoOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
    }
}

//---カメラ設定用メソッド
extension ViewController{
    
    //--カメラの設定
    func setupCaptureSession(){
        self.captureSesion.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    //--デバイスの設定
    func setupDevice(){
        //--プロパティを「実装位置指定なし」で設定
        let devicediscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        //--プロパティに従ってカメラを探し、前と後ろのカメラをそれぞれinner,maincameraに設定
        let devices = devicediscoverySession.devices
        for device in devices{
            if device.position == AVCaptureDevice.Position.back{
                mainCamera = device
            }else if device.position == AVCaptureDevice.Position.front{
                innerCamera = device
            }
        }
        
        currentDevice = mainCamera
    }

    //--入出力データの設定
    func setupCameraIO(){
        do {
            //--入力
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            captureSesion.addInput(captureDeviceInput)
            
            //--出力
            photoOutput = AVCapturePhotoOutput()
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSesion.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    //--レイヤの設定
    func setupPreviewLayer(){
        //--プレビューレイヤを初期化し、縦横比と向きを設定
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSesion)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        //--viewにpreviewlayerを設定
        self.cameraPreviewLayer?.frame = self.imageView.frame
        self.imageView.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }

}

//---カメラ画像デリゲート
extension ViewController: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(){
            let uiimage = UIImage(data:imageData)
            print(imageData.count)
            UIImageWriteToSavedPhotosAlbum(uiimage!, nil, nil, nil)
        }
    }
}
