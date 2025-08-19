import SwiftUI

struct TaskRow: View {
    let task: Task
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Чекбокс
            ZStack {
                Circle()
                    .stroke(task.isCompleted ? Color.green : Color.gray, lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                if task.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.green)
                }
            }
            
            // Текст задачи
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .strikethrough(task.isCompleted)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .contentShape(Rectangle()) // Важно для распознавания тапа по всей области
        .onTapGesture {
            onToggle()
        }
        .contextMenu {
            Button(action: onEdit) {
                Label("Редактировать", systemImage: "pencil")
            }
            Button(role: .destructive, action: onDelete) {
                Label("Удалить", systemImage: "trash")
            }
        }
        // Удаление по свайпу влево (более заметный вариант)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Удалить", systemImage: "trash.fill")
            }
            .tint(.red)
        }
        // Редактирование по свайпу вправо
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button(action: onEdit) {
                Label("Редактировать", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}
