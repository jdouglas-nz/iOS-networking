import Foundation

public protocol RequestBodyEncoder {
    func format<InputType: Encodable>(input: InputType?) throws -> Data?
}

public struct JsonInputEncoder: RequestBodyEncoder {
    
    public let encoder: JSONEncoder
    
    public init(encoder: JSONEncoder) {
        self.encoder = encoder
    }
    
    public func format<InputType>(input: InputType?) throws -> Data? where InputType : Encodable {
        if let input {
            return try encoder.encode(input)
        }
        return nil
    }
}

/// Only works for 'single level' encodables..
public struct XWWWFormURLEncoder: RequestBodyEncoder {
    
    public init() {}
    
    public func format<InputType>(input: InputType?) throws -> Data? where InputType : Encodable {
        guard let input else {
            return nil
        }
        let reflection = Mirror(reflecting: input)
        let s = reflection.children.enumerated().reduce(into: "") { partialResult, child in
            if let label = child.element.label, let value = "\(child.element.value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                partialResult += "\(label)=\(value != "nil" ? value : "")\(child.offset == reflection.children.count - 1 ? "" : "&")"
            }
        }
        
        return s.data(using: .utf8)
    }
    
}
