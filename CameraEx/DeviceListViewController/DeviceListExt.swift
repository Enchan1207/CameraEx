//
//  DeviceListExt.swift
//  CameraEx
//
//  Created by EnchantCode on 2021/01/21.
//  Copyright © 2021 EnchantCode. All rights reserved.
//

import AVFoundation
import UIKit

extension DeviceListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PreviewSegue", sender: self.devices[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "PreviewSegue"){
            guard let destination = segue.destination as? CameraViewController else {return}
            destination.device = sender as? AVCaptureDevice
        }
    }
}

extension DeviceListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.deviceListView.dequeueReusableCell(withIdentifier: "DeviceInfoCell") as! DeviceInfoCell
        let device = self.devices[indexPath.row]
        cell.infoStringLabel.text = device.localizedName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // TODO: 効いてない
        tableView.estimatedRowHeight = 40
        return UITableView.automaticDimension
    }
    
    
}

