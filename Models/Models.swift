import Foundation

// Модель для API ответа
struct TodosResponse: Codable {
    let todos: [Todo]
}

// Модель для данных из API (dummyjson.com)
struct Todo: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    
    func toTask() -> Task {
        let task = Task(
            id: id,
            title: todo,
            isCompleted: completed,
            description: nil,
            createdAt: Date()
        )
        print("Converted Todo to Task: \(task)")
        return task
    }
}

// Наша внутренняя модель для работы в приложении
struct Task: Identifiable {
    var id: Int
    var title: String
    var isCompleted: Bool
    var description: String?  // Добавляем опциональное описание
    var createdAt: Date?
}

// Ошибки сети
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
}
