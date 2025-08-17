import CoreData
import Foundation

final class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    // Контейнер Core Data
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodoModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // Сохранение контекста
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save Core Data: \(error)")
            }
        }
    }
}

// MARK: - CRUD операции
extension CoreDataManager {
    // Добавление задачи
    func addTask(_ task: Task) {
        let cdTask = CDTask(context: context)
        cdTask.id = Int64(task.id)
        cdTask.title = task.title
        cdTask.isCompleted = task.isCompleted
        cdTask.taskDescription = task.description
        cdTask.createdAt = task.createdAt ?? Date()
        saveContext()
    }
    
    // Получение всех задач
    func fetchTasks() -> [Task] {
        let request: NSFetchRequest<CDTask> = CDTask.fetchRequest()
        do {
            let cdTasks = try context.fetch(request)
            return cdTasks.map { cdTask in
                Task(
                    id: Int(cdTask.id),
                    title: cdTask.title ?? "",
                    isCompleted: cdTask.isCompleted,
                    description: cdTask.taskDescription,
                    createdAt: cdTask.createdAt
                )
            }
        } catch {
            print("Failed to fetch tasks: \(error)")
            return []
        }
    }
    
    // Обновление задачи
    func updateTask(_ task: Task) {
        let request: NSFetchRequest<CDTask> = CDTask.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", task.id)
        
        do {
            if let cdTask = try context.fetch(request).first {
                cdTask.title = task.title
                cdTask.isCompleted = task.isCompleted
                cdTask.taskDescription = task.description
                saveContext()
            }
        } catch {
            print("Failed to update task: \(error)")
        }
    }
    
    // Удаление задачи
    func deleteTask(_ task: Task) {
        let request: NSFetchRequest<CDTask> = CDTask.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", task.id)
        
        do {
            if let cdTask = try context.fetch(request).first {
                context.delete(cdTask)
                saveContext()
            }
        } catch {
            print("Failed to delete task: \(error)")
        }
    }
}
