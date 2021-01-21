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

    @IBOutlet weak var cameraView: UIImageView!
    
    var device: AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // TODO: セッション開始
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // TODO: セッション停止
    }
    
    @IBAction func onTapShutter(_ sender: Any) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
