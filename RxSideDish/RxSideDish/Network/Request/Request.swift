//
//  Request.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/10.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import Foundation
import Alamofire

enum HTTPMethod: String {
    case GET, POST, PUT, PATCH, DELETE
}

protocol Request {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    func asURLRequest() -> URLRequest
}

extension Request {
    var method: HTTPMethod { return .GET }
    var headers: HTTPHeaders? { return nil }
    
    func asURLRequest() -> URLRequest {
        var request = URLRequest(url: URL(string: path)!)
        request.httpMethod = self.method.rawValue
        return request
    }
}
