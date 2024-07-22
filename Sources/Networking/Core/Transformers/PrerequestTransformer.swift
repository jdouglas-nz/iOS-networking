import Foundation


public protocol PrerequestTransformer {
    func transform(urlRequest: URLRequest) async throws -> URLRequest
}

public struct AddHeadersRequestTransformer: PrerequestTransformer {
    private var headers: [String : String]
    
//    public init(header: (String: String)) {
//        self.init(headers: [header.0, header.1])
//    }
    
    public init(headers: [String : String]) {
        self.headers = headers
    }
    
    public func transform(urlRequest: URLRequest) async throws -> URLRequest {
        var r = urlRequest
        headers.forEach { (key: String, value: String) in
            r.setValue(value, forHTTPHeaderField: key)
        }
        return r
    }
}

public protocol AccessTokenProvider {
    func get() async throws -> String
}

public struct AuthTokenRequestTransformer: PrerequestTransformer {
    
    public enum Err: Error {
        case noTokenAvailable
    }
    
    private let accesssTokenProvider: AccessTokenProvider
    
    public init(accesssTokenProvider: AccessTokenProvider) {
        self.accesssTokenProvider = accesssTokenProvider
    }
    
    public func transform(urlRequest: URLRequest) async throws -> URLRequest {
        var r = urlRequest
        let token = try await accesssTokenProvider.get()
        r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return r
    }
}

actor URLRequestTransformer {
    private var urlRequest: URLRequest
    private let transformations: [PrerequestTransformer]
    
    init(urlRequest: URLRequest, transformations: [PrerequestTransformer]) {
        self.urlRequest = urlRequest
        self.transformations = transformations
    }
    
    func transform() async throws -> URLRequest {
        do {
            var r = urlRequest
            for transformation in transformations {
//                try Task.checkCancellation()
                r = try await transformation.transform(urlRequest: r)
            }
//            try Task.checkCancellation()
            return r
        } catch {
            throw NetworkingError.prerequestTransformerError(error)
        }
    }
}
