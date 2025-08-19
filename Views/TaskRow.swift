import SwiftUI

struct TaskRow: View {
    let task: Task
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void
    let isSelected: Bool // Новый параметр
    let onSelect: (() -> Void)? // Обработчик выделения
    
    init(task: Task,
         onToggle: @escaping () -> Void,
         onDelete: @escaping () -> Void,
         onEdit: @escaping () -> Void,
         isSelected: Bool = false,
         onSelect: (() -> Void)? = nil) {
        self.task = task
        self.onToggle = onToggle
        self.onDelete = onDelete
        self.onEdit = onEdit
        self.isSelected = isSelected
        self.onSelect = onSelect
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Кружок выделения (если включен режим выбора)
            if onSelect != nil {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.system(size: 20))
                    .onTapGesture {
                        onSelect?()
                    }
            }
            
            // Чекбокс выполнения
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
            .onTapGesture {
                onToggle()
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
        .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
        .cornerRadius(10)
        .contentShape(Rectangle())
        .onTapGesture {
            if onSelect == nil {
                onToggle()
            }
        }
        .contextMenu {
            Button(action: onEdit) {
                Label("Редактировать", systemImage: "pencil")
            }
            Button(role: .destructive, action: onDelete) {
                Label("Удалить", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Удалить", systemImage: "trash.fill")
            }
            .tint(.red)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button(action: onEdit) {
                Label("Редактировать", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}
