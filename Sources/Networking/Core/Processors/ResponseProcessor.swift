import Foundation


public protocol ResponseProcessor {
    func process(data: Data, urlResponse: URLResponse) async throws
}


actor URLResponseProcessor {
    
    private var urlResponse: URLResponse
    private var data: Data
    private let processors: [ResponseProcessor]
    
    init(urlResponse: URLResponse, data: Data, processors: [ResponseProcessor]) {
        self.urlResponse = urlResponse
        self.data = data
        self.processors = processors
    }
    
    func process() async throws {
        for processor in processors {
            //try Task.checkCancellation()
            try await processor.process(data: data, urlResponse: urlResponse)
        }
//        try Task.checkCancellation()
    }
}

public struct AllowedCodeRangeResponseProcessor: ResponseProcessor {
    public enum Err: Error, Equatable {
        case notAHttpUrlResponse
    }
    
    private let allowedStatusCodeRange: ClosedRange<Int>
    
    public init(allowedStatusCodeRange: ClosedRange<Int>) {
        self.allowedStatusCodeRange = allowedStatusCodeRange
    }
    
    public func process(data: Data, urlResponse: URLResponse) async throws {
        guard let response = urlResponse as? HTTPURLResponse else {
            throw Err.notAHttpUrlResponse
        }
        guard allowedStatusCodeRange.contains(response.statusCode) else {
            throw NetworkingError.unexpectedStatusCode(statusCode: response.statusCode, data: data)
        }
    }
}
