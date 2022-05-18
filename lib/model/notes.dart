class Notes {
  int? id;
  String? title;
  String? description;
  String? date;

  Notes(this.title, this.description, this.date, {this.id});

  Notes.fromMap(Map map) {
    id = map['id'];
    title = map['title'];
    description = map['description'];
    date = map['date'];
  }

  Map<String,dynamic> toMap() {
    Map<String, dynamic> map = {
      'title': this.title,
      'description': this.description,
      'date': this.date,
    };

    if (id != null) {
      map['id'] = this.id;
    }

    return map;
  }
}