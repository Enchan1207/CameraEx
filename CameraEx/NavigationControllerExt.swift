//
//  NavigationControllerExt.swift
//  CameraEx
//
//  Created by EnchantCode on 2021/01/22.
//  Copyright © 2021 EnchantCode. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var shouldAutorotate: Bool {
        guard let viewController = self.visibleViewController else{return false}
        return viewController.shouldAutorotate
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let viewController = self.visibleViewController else{return .allButUpsideDown}
        return viewController.supportedInterfaceOrientations
    }
}
