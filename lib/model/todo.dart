class Todo {
  String title;
  bool isDone;

  Todo({this.title, this.isDone});

  Todo.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    isDone = json['isDone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['isDone'] = this.isDone;
    return data;
  }
}
