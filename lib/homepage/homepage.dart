import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:river_todo/model/todo_model.dart';
import 'package:river_todo/provider/all_provider.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodos);
    final todoTextController = useTextEditingController();
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 50),
            children: [
              Title(
                todoTextController: todoTextController,
              ),
              TextField(
                controller: todoTextController,
                decoration: const InputDecoration(
                  labelText: 'What to do?',
                ),
                onSubmitted: (value) {
                  ref.read(todoListProvider.notifier).addTodo(todoTextController.text);
                  todoTextController.clear();
                },
              ),
              const SizedBox(
                height: 40,
              ),
              //Toolbar
              const Toolbar(),

              const SizedBox(
                height: 40,
              ),
              Column(
                children: [
                  ...todos.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Card(
                        elevation: 4,
                        child: Row(
                          children: [
                            Checkbox(
                              value: e.completed,
                              onChanged: (value) {
                                ref.read(todoListProvider.notifier).toggleComplete(e.id);
                              },
                            ),
                            Expanded(child: Text(e.description)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Title extends ConsumerWidget {
  const Title({
    Key? key,
    required this.todoTextController,
  }) : super(key: key);
  final TextEditingController todoTextController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'todos',
          style: TextStyle(
            fontSize: 86,
            fontWeight: FontWeight.w100,
          ),
        ),
        GestureDetector(
          onTap: () {
            ref.read(todoListProvider.notifier).addTodo(todoTextController.text);
            todoTextController.clear();
          },
          child: const Icon(
            Icons.done,
            size: 86,
          ),
        ),
      ],
    );
  }
}

class Toolbar extends HookConsumerWidget {
  const Toolbar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(todoListFilterProvider);

    Color? textColorFor(TodoListFilter value) {
      return filter == value ? Colors.blue : Colors.black;
    }

    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${ref.watch(uncompletedTodosCount)} items left',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Tooltip(
            message: 'All todos',
            child: TextButton(
              onPressed: () => ref.read(todoListFilterProvider.notifier).state = TodoListFilter.all,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                foregroundColor: MaterialStateProperty.all(textColorFor(TodoListFilter.all)),
              ),
              child: const Text('All'),
            ),
          ),
          Tooltip(
            message: 'Only uncompleted todos',
            child: TextButton(
              onPressed: () => ref.read(todoListFilterProvider.notifier).state = TodoListFilter.active,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                foregroundColor: MaterialStateProperty.all(
                  textColorFor(TodoListFilter.active),
                ),
              ),
              child: const Text('Active'),
            ),
          ),
          Tooltip(
            message: 'Only completed todos',
            child: TextButton(
              onPressed: () => ref.read(todoListFilterProvider.notifier).state = TodoListFilter.completed,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                foregroundColor: MaterialStateProperty.all(
                  textColorFor(TodoListFilter.completed),
                ),
              ),
              child: const Text('Completed'),
            ),
          ),
        ],
      ),
    );
  }
}
