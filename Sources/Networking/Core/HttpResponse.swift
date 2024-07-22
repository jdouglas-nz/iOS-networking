//
//  File.swift
//  
//
//  Created by John Douglas on 14/07/2024.
//

import Foundation

public struct HttpResponse {
    public let statusCode: Int
    public let headers: [String: String]?
    public let responseBody: Data?
    
    init(statusCode: Int, headers: [String : String]?, responseBody: Data?) {
        self.statusCode = statusCode
        self.headers = headers
        self.responseBody = responseBody
    }
}
