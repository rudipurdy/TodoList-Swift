import SwiftUI

struct TaskListView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var showingAddSheet = false
    @State private var editingTask: Task?
    @State private var isSelectionMode = false // Режим выделения
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Панель инструментов при выделении
                if isSelectionMode && !viewModel.selectedTasks.isEmpty {
                    selectionToolbar
                }
                
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
                                },
                                isSelected: viewModel.isSelected(task),
                                onSelect: isSelectionMode ? {
                                    withAnimation {
                                        viewModel.toggleSelection(for: task)
                                    }
                                } : nil
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Мои задачи")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isSelectionMode {
                    selectionModeToolbar
                } else {
                    normalModeToolbar
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
    
    // MARK: - Toolbars
    
    // Панель инструментов в обычном режиме
    private var normalModeToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if !viewModel.allTasks.isEmpty {
                Button {
                    withAnimation {
                        isSelectionMode = true
                        viewModel.selectAll()
                    }
                } label: {
                    Image(systemName: "checkmark.circle")
                }
            }
            
            Button {
                showingAddSheet = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    // Панель инструментов в режиме выделения
    private var selectionModeToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button("Готово") {
                withAnimation {
                    isSelectionMode = false
                    viewModel.deselectAll()
                }
            }
            
            if viewModel.allSelected {
                Button("Снять все") {
                    withAnimation {
                        viewModel.deselectAll()
                    }
                }
            } else {
                Button("Выбрать все") {
                    withAnimation {
                        viewModel.selectAll()
                    }
                }
            }
        }
    }
    
    // Панель инструментов при выделении (внизу)
    private var selectionToolbar: some View {
        HStack {
            Text("Выбрано: \(viewModel.selectedTasks.count)")
                .font(.headline)
            
            Spacer()
            
            Button(role: .destructive) {
                withAnimation {
                    viewModel.deleteSelectedTasks()
                    isSelectionMode = false
                }
            } label: {
                Label("Удалить", systemImage: "trash")
            }
            .disabled(viewModel.selectedTasks.isEmpty)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
