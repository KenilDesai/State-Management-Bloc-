import 'dart:async';
import 'package:flutter/material.dart';



class Todo {
  final String title;

  Todo(this.title);
}

// This is main logic class
// for this we have to create class bloc


class TodoBloc {
  final todoController = StreamController<
      List<Todo>>.broadcast(); //this is for saparate a list item

  List<Todo> todos = [];

  Stream<List<Todo>> get todoStream => todoController.stream;

  void addItem(Todo todo) {
    todos.add(todo);
    todoController.sink.add(todos);
  }

  void dispose() {
    todoController.close();
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController controller = TextEditingController();
  final TodoBloc todobloc = TodoBloc();

  @override
  void dispose() {
    controller.dispose();
    todobloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: StreamBuilder<List<Todo>>(
        stream: todobloc.todoStream,
        builder: (context, snapshot) {
          // snapshot is basicaly duplicate the data
          return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                final todo = snapshot.data![index];
                return ListTile(
                  title: Text(todo.title),
                );
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Add Item'),
                  content: TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: 'Enter Item'),
                  ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          todobloc.addItem(Todo(controller.text));
                          controller.clear(); //it's optional
                          Navigator.of(context).pop();
                        },
                        child: Text('Add'))
                  ],
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
