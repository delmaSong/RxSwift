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
    func fetch(url: String) -> Observable<Data> {
        return Observable.just(url)
            .map {URL(string: $0)! }
            .map { URLRequest(url: $0) }
            .flatMap { URLSession.shared.rx.data(request: $0) }
    }
}
