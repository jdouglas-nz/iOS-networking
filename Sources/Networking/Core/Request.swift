import Foundation

public struct Request {
    
    public let path: String
    public let queryParameters: [String: String]?
    public let headers: [String: String]?
    public let timeout: TimeInterval?
    public let verb: HTTPVerb? // this is to allow the generic 'lower level' send(request:) to be used
    
    public init(path: String, queryParameters: [String : String]? = nil, headers: [String: String]? = nil, timeout: TimeInterval? = nil, verb: HTTPVerb? = nil) {
        self.path = path
        self.queryParameters = queryParameters
        self.headers = headers
        self.timeout = timeout
        self.verb = verb
    }
}

public enum HTTPVerb: String {
    case get
    case put
    case post
    case patch
    case delete
    case head
}
