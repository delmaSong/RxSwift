//
//  Menu.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/08.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import Foundation
import RxDataSources

struct SectionOfMenu {
    var sectionType: EndPoints
    var items: [Item]
}

extension SectionOfMenu: SectionModelType {
    typealias Item = Menu

    init(original: SectionOfMenu, items: [Menu]) {
        self = original
        self.items = items
    }
}

struct MenuContainer: Codable {
    private(set) var statusCode: Int
    private(set) var data: [Menu]
    
    enum CodingKeys: String, CodingKey {
        case statusCode
        case data = "body"
    }
}

struct Menu: Codable, Equatable {
    private(set) var menuID: String
    private(set) var image: String
    private(set) var imageDescription: String
    private(set) var deliveryType: [String]
    private(set) var title: String
    private(set) var menuDescription: String
    private(set) var originalPrice: String?
    private(set) var discountedPrice: String?
    private(set) var badge: [String]?
    
    enum CodingKeys: String, CodingKey {
        case menuID = "detail_hash"
        case image
        case imageDescription = "alt"
        case deliveryType = "delivery_type"
        case title
        case menuDescription = "description"
        case originalPrice = "n_price"
        case discountedPrice = "s_price"
        case badge
    }
}
