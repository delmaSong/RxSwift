//
//  MenuDetail.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/18.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import Foundation

struct MenuDetailContainer: Codable {
    private(set) var hash: String
    private(set) var data: MenuDetail
}

struct MenuDetail: Codable {
    private(set) var topImage: String
    private(set) var thumbImages: [String]
    private(set) var menuDescription: String
    private(set) var point: String
    private(set) var deliveryInfo: String
    private(set) var deliveryFee: String
    private(set) var prices: [String]
    private(set) var detailImages: [String]

    enum CodingKeys: String, CodingKey {
        case topImage = "top_image"
        case thumbImages = "thumb_images"
        case menuDescription = "product_description"
        case point
        case deliveryInfo = "delivery_info"
        case deliveryFee = "delivery_fee"
        case prices
        case detailImages = "detail_section"
    }
}
