import XCTest
@testable import toDoList

class TaskTests: XCTestCase {
    
    func testTaskInitialization() {
        let task = Task(id: 1, title: "Test", isCompleted: false)
        XCTAssertEqual(task.id, 1)
        XCTAssertEqual(task.title, "Test")
        XCTAssertFalse(task.isCompleted)
    }
    
    func testTaskToggle() {
        var task = Task(id: 1, title: "Test", isCompleted: false)
        task.isCompleted.toggle()
        XCTAssertTrue(task.isCompleted)
    }
}

class MockTodoService: TodoServiceProtocol {
    var fetchTodosCalled = false
    var mockTodos: [Todo] = []
    var mockError: Error?
    
    func fetchTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {
        fetchTodosCalled = true
        if let error = mockError {
            completion(.failure(error))
        } else {
            completion(.success(mockTodos))
        }
    }
}

class TaskViewModelTests: XCTestCase {
    
    var viewModel: TaskViewModel!
    var mockService: MockTodoService!
    
    override func setUp() {
        super.setUp()
        mockService = MockTodoService()
        viewModel = TaskViewModel(todoService: mockService)
    }
    
    func testFetchTodosSuccess() {
        // Подготовка
        let testTodo = Todo(id: 1, todo: "Test", completed: false)
        mockService.mockTodos = [testTodo]
        
        let expectation = XCTestExpectation(description: "Fetch todos")
        
        // Действие
        viewModel.loadInitialData()
        
        // Проверка
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertEqual(self.viewModel.allTasks.count, 1)
            XCTAssertEqual(self.viewModel.allTasks.first?.title, "Test")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddTask() {
        let newTask = Task(id: 1, title: "New", isCompleted: false)
        viewModel.addTask(newTask)
        XCTAssertEqual(viewModel.allTasks.count, 1)
        XCTAssertEqual(viewModel.allTasks.first?.title, "New")
    }
    
    func testDeleteTask() {
        let task = Task(id: 1, title: "Test", isCompleted: false)
        viewModel.addTask(task)
        viewModel.deleteTask(task)
        XCTAssertTrue(viewModel.allTasks.isEmpty)
    }
    
    func testToggleCompletion() {
        let task = Task(id: 1, title: "Test", isCompleted: false)
        viewModel.addTask(task)
        viewModel.toggleCompletion(for: task)
        XCTAssertTrue(viewModel.allTasks.first?.isCompleted ?? false)
    }
}

class TodoServiceTests: XCTestCase {
    
    func testFetchTodos() {
        let service = TodoService.shared
        let expectation = XCTestExpectation(description: "Fetch todos")
        
        service.fetchTodos { result in
            switch result {
            case .success(let todos):
                XCTAssertFalse(todos.isEmpty)
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}

class UITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--testing")
        app.launch()
    }
    
    func testAddTask() {
        app.navigationBars["Мои задачи"].buttons["plus"].tap()
        app.textFields["Заголовок"].tap()
        app.textFields["Заголовок"].typeText("Новая задача")
        app.buttons["Сохранить"].tap()
        XCTAssertTrue(app.staticTexts["Новая задача"].exists)
    }
}
