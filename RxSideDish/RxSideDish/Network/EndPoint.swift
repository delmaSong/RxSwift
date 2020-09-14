//
//  EndPoint.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/10.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import Foundation

enum EndPoints: String, CaseIterable {
    case main = "main"
    case soup = "soup"
    case side = "side"
    
    static let BaseURL = "https://h3rb9c0ugl.execute-api.ap-northeast-2.amazonaws.com/develop/baminchan/"
}
