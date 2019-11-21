import 'dart:convert';
import 'dart:io';

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

  List _todoList = [];

  @override
  void initState() {
    super.initState();

    _readData().then((v) {
      if (v == null) return;

      setState(() => _todoList = json.decode(v));
    });
  }

  Future<File> _getFile() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/data.json');
    return file;
  }

  Future<File> _saveData() async {
    String data = json.encode(_todoList);
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
      _todoList.add({'title': text, 'value': false});
    });
    _saveData();
    textCtrl.clear();
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
          child: ListView.builder(
              itemCount: _todoList.length,
              padding: EdgeInsets.only(top: 10.0),
              itemBuilder: buildCheckboxListTile),
        )
      ]),
    );
  }

  Widget buildCheckboxListTile(context, int index) {
    return Dismissible(
        key: Key(index.toString()),
        direction: DismissDirection.startToEnd,
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
          title: Text(_todoList[index]['title']),
          value: _todoList[index]['value'],
          onChanged: (bool value) {
            setState(() => _todoList[index]['value'] = value);
            _saveData();
          },
          secondary: _todoList[index]['value']
              ? Icon(
                  Icons.check_circle,
                  color: Colors.green,
                )
              : Icon(Icons.error),
        ));
  }
}
