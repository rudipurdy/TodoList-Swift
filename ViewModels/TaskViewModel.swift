import Foundation
import CoreData
import Combine

class TaskViewModel: ObservableObject {
    @Published private(set) var allTasks: [Task] = []
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var selectedTasks: Set<Int> = [] // ID выделенных задач
    
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
        let localTasks = coreDataManager.fetchTasks()
        self.allTasks = localTasks
        print("Loaded \(localTasks.count) tasks from Core Data")
        
        // Затем загружаем из API
        todoService.fetchTodos { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let todos):
                    let newTasks = todos.map { $0.toTask() }
                    print("Received \(newTasks.count) tasks from API")
                    
                    // Фильтруем дубликаты
                    let uniqueNewTasks = newTasks.filter { newTask in
                        !localTasks.contains(where: { $0.id == newTask.id })
                    }
                    
                    print("Adding \(uniqueNewTasks.count) unique new tasks")
                    self?.allTasks.append(contentsOf: uniqueNewTasks)
                    
                    // Сохраняем только новые задачи
                    uniqueNewTasks.forEach { self?.coreDataManager.addTask($0) }
                    
                case .failure(let error):
                    print("Error loading tasks: \(error)")
                }
            }
        }
    }
    
    // Выделить все задачи
    func selectAll() {
        selectedTasks = Set(allTasks.map { $0.id })
    }
    
    func deselectAll() {
        selectedTasks.removeAll()
    }
    
    func toggleSelection(for task: Task) {
        if selectedTasks.contains(task.id) {
            selectedTasks.remove(task.id)
        } else {
            selectedTasks.insert(task.id)
        }
    }
    
    // Проверить, выделена ли задача
    func isSelected(_ task: Task) -> Bool {
        selectedTasks.contains(task.id)
    }
    
    // Проверить, выделены ли все задачи
    var allSelected: Bool {
        !allTasks.isEmpty && selectedTasks.count == allTasks.count
    }
    
    // Удалить выделенные задачи (БЕЗ анимации)
        func deleteSelectedTasks() {
            let tasksToDelete = allTasks.filter { selectedTasks.contains($0.id) }
            
            // Удаляем из локального массива
            allTasks.removeAll { selectedTasks.contains($0.id) }
            
            // Удаляем из Core Data
            tasksToDelete.forEach { coreDataManager.deleteTask($0) }
            
            // Очищаем выделение
            selectedTasks.removeAll()
        }
    
    // Удалить все задачи (БЕЗ анимации)
        func deleteAllTasks() {
            // Удаляем из Core Data
            allTasks.forEach { coreDataManager.deleteTask($0) }
            
            // Очищаем массив
            allTasks.removeAll()
            
            // Очищаем выделение
            selectedTasks.removeAll()
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
    
    // Удалить конкретную задачу (БЕЗ анимации)
        func deleteTask(_ task: Task) {
            allTasks.removeAll { $0.id == task.id }
            coreDataManager.deleteTask(task)
        }
    
    // Переключить выполнение задачи (БЕЗ анимации)
        func toggleCompletion(for task: Task) {
            if let index = allTasks.firstIndex(where: { $0.id == task.id }) {
                allTasks[index].isCompleted.toggle()
                coreDataManager.updateTask(allTasks[index])
            }
        }
}
