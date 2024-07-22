
import Foundation

public enum NetworkingError: Error {
    case prerequestTransformerError(_ error: Error)
    case networkError(_ error: Error)
    case unexpectedStatusCode(statusCode: Int, data: Data)
    case responseProcessorError(_ error: Error)
    case unknown(_ error: Error)
}

