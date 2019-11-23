class Todo {
  String title;
  bool isDone;

  Todo({this.title, this.isDone});

  Todo.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    isDone = json['isDone'];
  }

  toJson() {
    return {
      'title': title,
      'isDone': isDone,
    };
  }
}
