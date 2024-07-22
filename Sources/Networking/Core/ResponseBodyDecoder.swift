import Foundation

public protocol ResponseBodyDecoder {
    func decode<Response: Decodable>(data: Data) throws -> Response
}

public struct JsonResponseBodyDecoder: ResponseBodyDecoder {
    private let decoder: JSONDecoder
    
    public init(decoder: JSONDecoder) {
        self.decoder = decoder
    }
    
    public func decode<Response>(data: Data) throws -> Response where Response : Decodable {
        try decoder.decode(Response.self, from: data)
    }
}
