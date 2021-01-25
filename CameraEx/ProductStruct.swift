//
//  ProductStruct.swift
//  CameraEx
//
//  Created by EnchantCode on 2021/01/25.
//  Copyright © 2021 EnchantCode. All rights reserved.
//

import Foundation

struct Product: Equatable {
    var name: String
    let janCode: String
    
    static func ==(lhs: Product, rhs: Product) -> Bool{
        return lhs.janCode == rhs.janCode
    }
}
