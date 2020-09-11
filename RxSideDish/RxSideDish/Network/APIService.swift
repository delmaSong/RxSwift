//
//  APIService.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/08.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class APIService {
    let bag = DisposeBag()
    let list = PublishSubject<[Menu]>()
    
    func fetchWithRxCocoa(url: String) {
        _ = Observable.just(url)
            .map {URL(string: $0)! }
            .map { URLRequest(url: $0) }
            .flatMap { URLSession.shared.rx.data(request: $0) }
            .map { self.parse(data: $0) }
            .bind(to: list)
            .disposed(by: bag)
    }
    
    func parse(data: Data) -> [Menu] {
        var list = [Menu]()
        do {
            let decodedData = try JSONDecoder().decode(MenuContainer.self, from: data)
            list = decodedData.body
        } catch {
            print(error)
        }
        return list
    }
}
