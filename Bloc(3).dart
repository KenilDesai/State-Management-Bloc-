import 'dart:async';
import 'package:flutter/material.dart';

class Todo {
  final String title;
  bool completed;
  Todo(this.title, {this.completed = false});
}

class TodoBloc {
  final _todoController = StreamController<List<Todo>>.broadcast();
  List<Todo> _todos = [];
  Stream<List<Todo>> get todostream => _todoController.stream;
  void addTodo(Todo todo) {
    _todos.add(todo);
    _todoController.sink.add(_todos);
  }

  void toggleTodoCompletion(int index) {
    _todos[index].completed = !_todos[index].completed;
    _todoController.sink.add(_todos);
  }

  void dispose() {
    _todoController.close();
  }
}

void main() {
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TODO APP",
      home: Myapplication(),
    );
  }
}

class Myapplication extends StatefulWidget {
  const Myapplication({Key? key}) : super(key: key);
  @override
  State<Myapplication> createState() => _MyapplicationState();
}

class _MyapplicationState extends State<Myapplication> {
  final TextEditingController _controller = TextEditingController();
  final TodoBloc _todoBloc = TodoBloc();
  final List<String> _cartItems = [];
  @override
  void dispose() {
    _controller.dispose();
    _todoBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bloc App"),
      ),
      body: StreamBuilder<List<Todo>>(
        stream: _todoBloc.todostream,
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              final todo = snapshot.data![index];
              return ListTile(
                title: Text(
                  todo.title,
                  style: TextStyle(
                    decoration:
                        todo.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    todo.completed
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                  ),
                  onPressed: () {
                    _todoBloc.toggleTodoCompletion(index);
                  },
                ),
                onTap: () {
                  addToCart(todo.title);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added "${todo.title}" to cart')),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Add Item"),
                content: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: "Enter Todo Name"),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      _todoBloc.addTodo(Todo(_controller.text));
                      _controller.clear();
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartPage(cartItems: _cartItems),
              ),
            );
          },
          child: Text('Open Cart'),
        ),
      ],
    );
  }

  void addToCart(String item) {
    setState(() {
      _cartItems.add(item);
    });
  }
}

class CartPage extends StatelessWidget {
  final List<String> cartItems;
  const CartPage({Key? key, required this.cartItems}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(cartItems[index]),
          );
        },
      ),
    );
  }
}
