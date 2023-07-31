import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:river_todo/model/todo_model.dart';
import 'package:uuid/uuid.dart';

var _uuid = const Uuid();

final todoListProvider = StateNotifierProvider<TodoList, List<TodoModel>>(
  (ref) {
    return TodoList([]);
  },
);

class TodoList extends StateNotifier<List<TodoModel>> {
  TodoList([List<TodoModel>? initialTodos]) : super(initialTodos ?? []);

  void addTodo(String desc) {
    state = [
      ...state,
      TodoModel(
        id: _uuid.v4(),
        description: desc,
      ),
    ];
  }

  void toggleComplete(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          TodoModel(
            id: todo.id,
            description: todo.description,
            completed: !todo.completed,
          )
        else
          todo,
    ];
  }

  void editTodo({required String id, required String desc}) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          TodoModel(
            id: todo.id,
            description: desc,
            completed: todo.completed,
          )
        else
          todo,
    ];
  }

  void remove(TodoModel target) {
    state = state.where((element) => element.id != target.id).toList();
  }
}

final todoListFilterProvider = StateProvider(
  (ref) => TodoListFilter.all,
);
final uncompletedTodosCount = Provider<int>((ref) {
  return ref.watch(todoListProvider).where((todo) => !todo.completed).length;
});

final filteredTodos = Provider<List<TodoModel>>((ref) {
  final filter = ref.watch(todoListFilterProvider);
  final todos = ref.watch(todoListProvider);

  switch (filter) {
    case TodoListFilter.completed:
      return todos.where((todo) => todo.completed).toList();
    case TodoListFilter.active:
      return todos.where((todo) => !todo.completed).toList();
    case TodoListFilter.all:
      return todos;
  }
});
