import Foundation

final class TodoService: TodoServiceProtocol {
    static let shared = TodoService()
    private init() {}
    
    private let urlSession = URLSession(configuration: .default)
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func fetchTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        print("Fetching todos from: \(url)")
        
        let task = urlSession.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                        let response = try self?.jsonDecoder.decode(TodosResponse.self, from: data)
                        if let todos = response?.todos {
                            print("Received \(todos.count) todos from API")
                            print("First 3 todos: \(todos.prefix(3))")
                            completion(.success(todos))
                        } else {
                            completion(.failure(NetworkError.decodingError))
                        }
                    } catch {
                        print("Decoding error: \(error)")
                        completion(.failure(error))
                    }
        }
        
        task.resume()
    }
}
