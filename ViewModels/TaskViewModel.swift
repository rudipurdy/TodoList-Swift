import Foundation
import CoreData
import Combine

class TaskViewModel: ObservableObject {
    @Published private(set) var allTasks: [Task] = []
    @Published var searchText: String = ""
    @Published var isLoading = false
    
    private let todoService: TodoServiceProtocol
    private let coreDataManager = CoreDataManager.shared 
    
    init(todoService: TodoServiceProtocol = TodoService.shared) {
        self.todoService = todoService
        loadInitialData()
    }
    
    var displayedTasks: [Task] {
        if searchText.isEmpty {
            return allTasks
        } else {
            return allTasks.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Загрузка данных (из Core Data + API)
    func loadInitialData() {
        isLoading = true
        
        // Сначала загружаем из Core Data
        allTasks = coreDataManager.fetchTasks()
        
        // Затем подгружаем из API (если нужно)
        todoService.fetchTodos { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let todos):
                    let newTasks = todos.map { $0.toTask() }
                    self?.allTasks.append(contentsOf: newTasks)
                    // Сохраняем новые задачи в Core Data
                    newTasks.forEach { self?.coreDataManager.addTask($0) }
                case .failure(let error):
                    print("Error loading tasks: \(error)")
                }
            }
        }
    }
    
    func addTask(_ task: Task) {
        allTasks.insert(task, at: 0)
        coreDataManager.addTask(task)
    }
    
    func updateTask(_ updatedTask: Task) {
        if let index = allTasks.firstIndex(where: { $0.id == updatedTask.id }) {
            allTasks[index] = updatedTask
            coreDataManager.updateTask(updatedTask)
        }
    }
    
    func deleteTask(_ task: Task) {
        allTasks.removeAll { $0.id == task.id }
        coreDataManager.deleteTask(task)
    }
    
    func toggleCompletion(for task: Task) {
        if let index = allTasks.firstIndex(where: { $0.id == task.id }) {
            allTasks[index].isCompleted.toggle()
            coreDataManager.updateTask(allTasks[index])
        }
    }
}
