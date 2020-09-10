//
//  EndPoint.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/10.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import Foundation

enum EndPoint {
    static let baseURL = "https://h3rb9c0ugl.execute-api.ap-northeast-2.amazonaws.com/develop/baminchan/"
    static let main = "\(baseURL)main/"
    static let side = "\(baseURL)side/"
    static let soup = "\(baseURL)soup/"
}

enum QueryParameters: CustomStringConvertible {
    case main
    case side
    case soup
    
    var description: String {
        switch self {
        case .main: return "main"
        case .side: return "side"
        case .soup: return "soup"
        }
    }
}
