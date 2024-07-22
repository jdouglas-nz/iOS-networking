import Foundation

public class NetworkingBuilder {
    
    private(set) var baseUrl: URL!
    private(set) var encoder: RequestBodyEncoder?
    private(set) var decoder: ResponseBodyDecoder?
    private(set) var urlSessionDataProvider: URLSessionDataProvider?
    private(set) var headers: [String: String]?
    
    private(set) var authTokenProvider: AccessTokenProvider?
    private(set) var prerequestTransformers = [PrerequestTransformer]()
    private(set) var responseProcessors = [ResponseProcessor]()
    
    private(set) var statusCodeRange: ClosedRange<Int>?
    
    public init() {}
    
    public func withBaseURL(_ url: URL) -> NetworkingBuilder {
        baseUrl = url
        return self
    }
    
    public func withJsonEncoder(_ encoder: JSONEncoder) -> NetworkingBuilder {
        self.encoder = JsonInputEncoder(encoder: encoder)
        return self
    }
    
    public func withJsonDecoder(_ decoder: JSONDecoder) -> NetworkingBuilder {
        self.decoder = JsonResponseBodyDecoder(decoder: decoder)
        return self
    }
    
    public func withBodyEncoder(_ encoder: RequestBodyEncoder) -> NetworkingBuilder {
        self.encoder = encoder
        return self
    }
    
    public func withResponseBodyDecoder(_ decoder: ResponseBodyDecoder) -> NetworkingBuilder {
        self.decoder = decoder
        return self
    }
    
    public func withURLSessionDataProvider(_ provider: URLSessionDataProvider) -> NetworkingBuilder {
        urlSessionDataProvider = provider
        return self
    }
    
    public func withPrerequestTransformer(_ transformer: PrerequestTransformer) -> NetworkingBuilder {
        prerequestTransformers.append(transformer)
        return self
    }
    
    public func withResponseProcessor(_ processor: ResponseProcessor) -> NetworkingBuilder {
        responseProcessors.append(processor)
        return self
    }
    
    public func withHeaders(_ headers: [String: String]) -> NetworkingBuilder {
        self.headers = headers
        return self
    }
    
    public func withAllowedStatusCodes(_ range: ClosedRange<Int>) -> NetworkingBuilder {
        statusCodeRange = range
        return self
    }
    
    public func build() -> Networking {
        guard let baseUrl else {
            fatalError("you need a baseUrl")
        }
        let encoder = encoder ?? JsonInputEncoder(encoder: .init())
        let decoder = decoder ?? JsonResponseBodyDecoder(decoder: .init())
        let urlSessionDataProvider = urlSessionDataProvider ?? URLSession.shared
        if let headers {
            prerequestTransformers.append(AddHeadersRequestTransformer(headers: headers))
        }
        let statusCodeRange = statusCodeRange ?? 200...299
        
        return ConcreteNetworking(
            baseUrl: baseUrl,
            urlSessionDataProvider: urlSessionDataProvider,
            prerequestTransformers: prerequestTransformers,
            responseProcessors: responseProcessors,
            decoder: decoder,
            encoder: encoder,
            allowedStatusCodes: statusCodeRange
        )
    }
    
    
}

