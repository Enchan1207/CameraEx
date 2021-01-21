//
//  DeviceInfoCell.swift
//  CameraEx
//
//  Created by EnchantCode on 2021/01/21.
//  Copyright © 2021 EnchantCode. All rights reserved.
//

import UIKit

class DeviceInfoCell: UITableViewCell {
    
    @IBOutlet weak var infoIcon: UIImageView!
    @IBOutlet weak var infoStringLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
