//
//  DeviceListViewController.swift
//  CameraEx
//
//  Created by EnchantCode on 2021/01/21.
//  Copyright © 2021 EnchantCode. All rights reserved.
//

import AVFoundation
import UIKit

class DeviceListViewController: UIViewController {
    
    @IBOutlet weak var deviceListView: UITableView!
    
    var devices: [AVCaptureDevice] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // リストビュー初期化
        self.deviceListView.delegate = self
        self.deviceListView.dataSource = self
        let nib = UINib(nibName: "DeviceInfoCell", bundle: nil)
        self.deviceListView.register(nib, forCellReuseIdentifier: "DeviceInfoCell")
        
        // リスト更新
        refleshDeviceList()
    }
    
    // デバイスリスト更新ボタン
    @IBAction func onTapReflesh(_ sender: Any) {
        refleshDeviceList()
    }
    
    /// デバイスリストをリフレッシュ
    func refleshDeviceList(){
        let candidates = discoverDevices(session: nil)
        self.devices = candidates
        
        if candidates.count == 0{
            let alertController = UIAlertController(title: "No device found!", message: "Please run it other than the simulator", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        }
        
        self.deviceListView.reloadData()
    }
    
    /// デバイス探索
    ///  - Parameters:
    ///     - session AVCaptureDevice.DiscoverySession?: 探索セッションの設定
    ///  - Returns: 探索結果
    func discoverDevices(session: AVCaptureDevice.DiscoverySession?) -> [AVCaptureDevice]{
        let defaultDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: AVCaptureDevice.Position.unspecified
        )
        
        let discoverySession = session ?? defaultDiscoverySession
        
        let candidates = discoverySession.devices
        return candidates
    }
    
}
