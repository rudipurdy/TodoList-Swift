import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var isCompleted = false
    @State private var description: String = ""
    var onSave: (Task) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Заголовок", text: $title)
                    TextField("Описание", text: $description)
                } header: {
                    Text("Опишите задачу")
                }
                
                Section {
                    Toggle("Завершено", isOn: $isCompleted)
                }
            }
            .navigationTitle("Новая задача")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отменить") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        let newTask = Task(
                            id: Int.random(in: 1...10000),
                            title: title,
                            isCompleted: isCompleted,
                            description: description.isEmpty ? nil : description
                        )
                        onSave(newTask)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
