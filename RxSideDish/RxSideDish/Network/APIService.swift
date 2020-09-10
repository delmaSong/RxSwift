//
//  APIService.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/08.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import Foundation

class APIService {
    func fetch(request: URLRequest, completion: @escaping ([Menu]) -> Void) {
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error { print(error); return }
            guard let data = data else { return }
            do {
                let decodedData = try JSONDecoder().decode(MenuContainer.self, from: data)
                completion(decodedData.body)
            } catch {
                print(error)
            }
        }.resume()
    }
}
