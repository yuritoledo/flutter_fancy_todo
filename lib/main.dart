import 'dart:convert';
import 'dart:io';
import 'package:todo/model/todo.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
          primaryColor: Colors.redAccent, accentColor: Colors.deepPurple),
    ));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final textCtrl = TextEditingController();

  List<Todo> _todoList = [];

  int _removedIndex;

  Todo _removedItem;

  @override
  void initState() {
    super.initState();

    _readData().then((value) {
      if (value == null) return;

      setState(() {
        final todoJson = jsonDecode(value);
        for (var todo in todoJson) {
          _todoList.add(Todo.fromJson(todo));
        }
        print(_todoList);
      });
    });
  }

  Future<File> _getFile() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/data.json');
    return file;
  }

  Future<File> _saveData() async {
    String data = jsonEncode(_todoList);
    File file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      File file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  void _addTodo() {
    final text = textCtrl.value.text;
    if (text == null) return;

    setState(() {
      _todoList.add(Todo(title: text, isDone: false));
    });
    _saveData();
    textCtrl.clear();
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _todoList.sort((a, b) {
        if (a.isDone && !b.isDone)
          return 1;
        else if (a.isDone && b.isDone)
          return 0;
        else
          return -1;
      });

      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To do list'),
        centerTitle: true,
      ),
      body: Column(children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 1.0),
          child: (Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: textCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nova tarefa',
                  ),
                ),
              ),
              RaisedButton(
                onPressed: _addTodo,
                child: Text('Adiciona'),
                textColor: Colors.white,
              )
            ],
          )),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
                itemCount: _todoList.length,
                padding: EdgeInsets.only(top: 10.0),
                itemBuilder: buildCheckboxListTile),
          ),
        )
      ]),
    );
  }

  Widget buildCheckboxListTile(context, int index) {
    return Dismissible(
        key: Key(DateTime.now().toString()),
        direction: DismissDirection.startToEnd,
        onDismissed: (dir) {
          setState(() {
            _removedIndex = index;
            _removedItem = _todoList[index];
            _todoList.removeAt(index);
          });

          _saveData();

          final snackbar = SnackBar(
            content: Text('data'),
            duration: Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                setState(() {
                  _todoList.insert(_removedIndex, _removedItem);
                });
              },
            ),
          );

          Scaffold.of(context).showSnackBar(snackbar);
        },
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        child: CheckboxListTile(
          title: Text(_todoList[index].title),
          value: _todoList[index].isDone,
          onChanged: (bool value) {
            setState(() => _todoList[index].isDone = value);
            _saveData();
          },
          secondary: _todoList[index].isDone
              ? Icon(
                  Icons.check_circle,
                  color: Colors.green,
                )
              : Icon(Icons.error),
        ));
  }
}
