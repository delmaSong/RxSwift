//
//  Menu.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/08.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import Foundation

struct Menu: Codable {
    private(set) var hashColor: String
    private(set) var image: String
    private(set) var imageDescription: String
    private(set) var deliveryType: [String]
    private(set) var title: String
    private(set) var menuDescription: String
    private(set) var originalPrice: String
    private(set) var discountedPrice: String?
    private(set) var badge: [String]?
    
    enum CodingKeys: String, CodingKey {
        case hashColor = "detail_hash"
        case image
        case imageDescription = "alt"
        case deliveryType = "delivery_type"
        case title
        case menuDescription = "description"
        case originalPrice = "s_price"
        case discountedPrice = "n_price"
        case badge
    }
}
