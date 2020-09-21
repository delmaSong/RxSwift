//
//  UseCase.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/21.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct UseCase {
    let apiService = APIService()
    
    func fetchMenuDetail(ID: String) -> Observable<MenuDetail?> {
        let url = "\(EndPoints.DetailURL)/\(ID)"
        return apiService.fetch(url: url)
            .map { data -> MenuDetail? in
                var detailMenu: MenuDetail?
                do {
                    let decodedData = try JSONDecoder().decode(MenuDetailContainer.self, from: data)
                    detailMenu = decodedData.data
                } catch {
                    print(error)
                }
                return detailMenu
            }
    }
    
    func fetchMenuList(type: EndPoints) -> Observable<[Menu]> {
        let url = "\(EndPoints.BaseURL)\(type.rawValue)"
        return apiService.fetch(url: url)
            .map { data -> [Menu] in
                var list = [Menu]()
                do {
                    let decodedData = try JSONDecoder().decode(MenuContainer.self, from: data)
                    list = decodedData.data
                } catch {
                    print(error)
                }
                return list
            }
    }
}
