import SwiftUI

@main
struct TodoListApp: App {
    // Создаем ViewModel один раз для всего приложения
    @StateObject private var viewModel = TaskViewModel(todoService: TodoService.shared)
    
    var body: some Scene {
        WindowGroup {
            TaskListView(viewModel: viewModel)
        }
    }
}
