// Компонент поиска
import SwiftUI

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            TextField("Найти задачу...", text: $text)
                .padding(8)
                .padding(.horizontal, 24)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button {
                                text = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                        Spacer()
                            
                            // Иконка микрофона справа
                            Image(systemName: "microphone")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                    }
                )
                .focused($isFocused)
                .onTapGesture {
                    isFocused = true
                }
        }
        .padding(.horizontal)
        .contentShape(Rectangle()) // Делаем всю область кликабельной
        .onTapGesture {
            // Скрываем клавиатуру при тапе вне текстового поля
            isFocused = false
        }
    }
}
