import Foundation

public protocol Networking {
    
    func get<InputType: Encodable, Response: Decodable>(request: Request, inputType: InputType) async throws -> Response
    func get<Response: Decodable>(request: Request) async throws -> Response
    func get(request: Request) async throws
    
    
    func put<InputType: Encodable, Response: Decodable>(request: Request, inputType: InputType) async throws -> Response
    func put<Response: Decodable>(request: Request) async throws -> Response
    func put(request: Request) async throws
    
    func post<InputType: Encodable, Response: Decodable>(request: Request, inputType: InputType) async throws -> Response
    func post<Response: Decodable>(request: Request) async throws -> Response
    func post(request: Request) async throws
    
    
    func delete<InputType: Encodable, Response: Decodable>(request: Request, inputType: InputType) async throws -> Response
    func delete<Response: Decodable>(request: Request) async throws -> Response
    func delete(request: Request) async throws
    
    func patch<InputType: Encodable, Response: Decodable>(request: Request, inputType: InputType) async throws -> Response
    func patch<Response: Decodable>(request: Request) async throws -> Response
    func patch(request: Request) async throws
    
    func send(request: Request) async throws -> HttpResponse
    func send<InputType: Encodable>(request: Request, input: InputType) async throws -> HttpResponse

}

