import SwiftUI

struct TaskListView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var showingAddSheet = false
    @State private var editingTask: Task?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.displayedTasks) { task in
                        TaskRow(
                            task: task,
                            onToggle: {
                                withAnimation {
                                    viewModel.toggleCompletion(for: task)
                                }
                            },
                            onDelete: {
                                withAnimation {
                                    viewModel.deleteTask(task)
                                }
                            },
                            onEdit: {
                                editingTask = task
                            }
                        )
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Мои задачи")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddTaskView { newTask in
                    viewModel.addTask(newTask)
                }
            }
            .sheet(item: $editingTask) { task in
                EditTaskView(task: task) { updatedTask in
                    viewModel.updateTask(updatedTask)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
