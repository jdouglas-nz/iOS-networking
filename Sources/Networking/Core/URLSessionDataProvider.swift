import Foundation

public protocol URLSessionDataProvider {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}


extension URLSession: URLSessionDataProvider {
    
    
}
