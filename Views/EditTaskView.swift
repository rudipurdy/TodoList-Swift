import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) var dismiss
    @State private var editedTask: Task
    @State private var descriptionText: String
    var onSave: (Task) -> Void
    
    init(task: Task, onSave: @escaping (Task) -> Void) {
        self._editedTask = State(initialValue: task)
        self._descriptionText = State(initialValue: task.description ?? "")
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Опишите задачу")) {
                    TextField("Заголовок", text: $editedTask.title)
                    TextField("Описание", text: $descriptionText)
                }
                
                Section {
                    Toggle("Завершено", isOn: $editedTask.isCompleted)
                    if let createdAt = editedTask.createdAt {
                        Text("Создано: \(createdAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отменить") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        var savedTask = editedTask
                        savedTask.description = descriptionText.isEmpty ? nil : descriptionText
                        onSave(savedTask)
                        dismiss()
                    }
                    .disabled(editedTask.title.isEmpty)
                }
            }
        }
    }
}
