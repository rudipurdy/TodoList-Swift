import Foundation

protocol TodoServiceProtocol {
    func fetchTodos(completion: @escaping (Result<[Todo], Error>) -> Void)
}
