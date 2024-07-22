import Foundation

public actor ConcreteNetworking: Networking {
    
    private let baseUrl: URL
    
    private let prerequestTransformers: [PrerequestTransformer]
    private let responseProcessors: [ResponseProcessor]
    
    private let decoder: ResponseBodyDecoder
    private let encoder: RequestBodyEncoder
    
    private let urlSessionDataProvider: URLSessionDataProvider
    
    private let allowedStatusCodes: ClosedRange<Int>
    
    public init(baseUrl: URL,
                urlSessionDataProvider: URLSessionDataProvider,
                prerequestTransformers: [PrerequestTransformer] = [],
                responseProcessors: [ResponseProcessor] = [],
                decoder: ResponseBodyDecoder = JsonResponseBodyDecoder(decoder: .init()),
                encoder: RequestBodyEncoder = JsonInputEncoder(encoder: .init()),
                allowedStatusCodes: ClosedRange<Int> = 200...299) {
        self.baseUrl = baseUrl
        self.prerequestTransformers = prerequestTransformers
        self.responseProcessors = responseProcessors
        self.decoder = decoder
        self.encoder = encoder
        self.urlSessionDataProvider = urlSessionDataProvider
        self.allowedStatusCodes = allowedStatusCodes
    }
    
}

extension ConcreteNetworking {

    
//    func get<InputType: Encodable>(request: Request, inputType: InputType) async throws -> [String: String] {
//        
//    }
    
    public func get<InputType: Encodable, Response: Decodable>(request: Request, inputType: InputType) async throws -> Response {
        try await sendRequest(request, httpVerb: .get, input: inputType)
    }
    
    public func get<Response: Decodable>(request: Request) async throws -> Response {
        try await sendRequest(request, httpVerb: .get)

    }
    
    public func get(request: Request) async throws {
        try await sendRequest(request, httpVerb: .get)
    }
    
    public func put<InputType: Encodable, Response: Decodable>(request: Request, inputType: InputType) async throws -> Response {
        try await sendRequest(request, httpVerb: .put, input: inputType)
    }
    
    public func put<Response: Decodable>(request: Request) async throws -> Response {
        try await sendRequest(request, httpVerb: .put)
    }
    
    public func put(request: Request) async throws {
        try await sendRequest(request, httpVerb: .put)
    }
    
    public func post<InputType: Encodable, Response: Decodable>(request: Request, inputType: InputType) async throws -> Response {
        try await sendRequest(request, httpVerb: .post, input: inputType)
    }
    
    public func post<Response: Decodable>(request: Request) async throws -> Response {
        try await sendRequest(request, httpVerb: .post)
    }
    
    public func post(request: Request) async throws {
        try await sendRequest(request, httpVerb: .post)
    }
    
    public func delete<InputType: Encodable, Response: Decodable>(request: Request, inputType: InputType) async throws -> Response {
        try await sendRequest(request, httpVerb: .delete, input: inputType)
    }
    
    public func delete<Response: Decodable>(request: Request) async throws -> Response {
        try await sendRequest(request, httpVerb: .delete)
    }
    
    public func delete(request: Request) async throws {
        try await sendRequest(request, httpVerb: .delete)
    }
    
    public func patch<InputType: Encodable, Response: Decodable>(request: Request, inputType: InputType) async throws -> Response {
        try await sendRequest(request, httpVerb: .patch, input: inputType)
    }
    
    public func patch<Response: Decodable>(request: Request) async throws -> Response {
        try await sendRequest(request, httpVerb: .patch)
    }
    
    public func patch(request: Request) async throws {
        try await sendRequest(request, httpVerb: .patch)
    }
    
    public func send<InputType>(request: Request, input: InputType) async throws -> HttpResponse where InputType : Encodable {
        do {
            var transformed = try await transformedRequest(
                urlRequest: try urlRequest(
                    for: request,
                    verb: request.verb!),
                requestHeaders: request.headers)
            
            transformed.httpBody = try encoder.format(input: input)
            
            let (data, response) = try await data(for: transformed)
            
            try await processResponse(data: data, response: response)
            
            //TODO: this below shouldn't be in a 'generic' networking layer..
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkingError.unexpectedStatusCode(statusCode: -1, data: data)
            }
            var headers: [String: String]? = httpResponse.allHeaderFields as? [String: String]
            headers?["Location"] = httpResponse.url?.absoluteString
            return .init(statusCode: httpResponse.statusCode, headers: headers, responseBody: data)
            
        } catch let e as NetworkingError {
            throw e
        } catch {
            throw NetworkingError.unknown(error)
        }
    }
    
    public func send(request: Request) async throws -> HttpResponse {
        do {
            let transformed = try await transformedRequest(
                urlRequest: try urlRequest(
                    for: request,
                    verb: request.verb!),
                requestHeaders: request.headers)
            
            let (data, response) = try await data(for: transformed)
            
            try await processResponse(data: data, response: response)
            //TODO: this below shouldn't be in a 'generic' networking layer..
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkingError.unexpectedStatusCode(statusCode: -1, data: data)
            }
            var headers: [String: String]? = httpResponse.allHeaderFields as? [String: String]
            headers?["Location"] = httpResponse.url?.absoluteString
            return .init(statusCode: httpResponse.statusCode, headers: headers, responseBody: data)
        } catch let e as NetworkingError {
            throw e
        } catch {
            throw NetworkingError.unknown(error)
        }
    }
    
}

extension ConcreteNetworking {
    private func transformedRequest(urlRequest: URLRequest, requestHeaders: [String: String]?) async throws -> URLRequest {
        var transformers = prerequestTransformers
        if let requestHeaders, !requestHeaders.isEmpty {
            transformers.append(AddHeadersRequestTransformer(headers: requestHeaders))
        }
        return try await URLRequestTransformer(urlRequest: urlRequest, transformations: transformers).transform()
    }
    
    private func processResponse(data: Data, response: URLResponse) async throws {
        do {
            try await URLResponseProcessor(
                urlResponse: response,
                data: data,
                processors: responseProcessors + [AllowedCodeRangeResponseProcessor(allowedStatusCodeRange: allowedStatusCodes)])
            .process()
        } catch let e as NetworkingError {
            throw e
        } catch {
            throw NetworkingError.unknown(error)
        }
    }
    
    private func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await urlSessionDataProvider.data(for: urlRequest)
        } catch {
            throw NetworkingError.networkError(error)
        }
    }
    
    private func sendRequest<Response, InputType>(_ request: Request, httpVerb: HTTPVerb, input: InputType?) async throws -> Response where Response: Decodable, InputType: Encodable {
        do {
            var transformed = try await transformedRequest(
                urlRequest: try urlRequest(
                    for: request,
                    verb: httpVerb),
                requestHeaders: request.headers)
            
            transformed.httpBody = try encoder.format(input: input)
            
            let (data, response) = try await data(for: transformed)
            
            try await processResponse(data: data, response: response)
            
            return try decoder.decode(data: data)
        } catch let e as NetworkingError {
            throw e
        } catch {
            throw NetworkingError.unknown(error)
        }
    }
    
    private func sendRequest<Response>(_ request: Request, httpVerb: HTTPVerb) async throws -> Response where Response: Decodable {
        do {
            let transformed = try await transformedRequest(
                urlRequest: try urlRequest(
                    for: request,
                    verb: httpVerb),
                requestHeaders: request.headers)
            
            let (data, response) = try await data(for: transformed)
            
            try await processResponse(data: data, response: response)
            
            return try decoder.decode(data: data)
        } catch let e as NetworkingError {
            throw e
        } catch {
            throw NetworkingError.unknown(error)
        }
    }
    
    private func sendRequest(_ request: Request, httpVerb: HTTPVerb) async throws {
        do {
            let transformed = try await transformedRequest(
                urlRequest: try urlRequest(
                    for: request,
                    verb: httpVerb),
                requestHeaders: request.headers)
            
            let (data, response) = try await data(for: transformed)
            
            try await processResponse(data: data, response: response)
        } catch let e as NetworkingError {
            throw e
        } catch {
            throw NetworkingError.unknown(error)
        }
    }
    
    private func urlRequest(for request: Request, verb: HTTPVerb) throws -> URLRequest {
        var urlComponents = URLComponents(url: baseUrl.appendingPathComponent(request.path), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = request.queryParameters?.map({ (key: String, value: String) in
                .init(name: key, value: value)
        })
        
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        let url = urlComponents.url!
        
        var req = URLRequest(url: url)
        req.httpMethod = verb.rawValue.uppercased()
        if let timeout = request.timeout {
            req.timeoutInterval = timeout
        }
        return req
    }
}
