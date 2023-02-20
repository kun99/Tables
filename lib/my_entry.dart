class MyEntry {

  // instance variables
  int? id;
  String desc;
  String source;
  String date;

  // constructor
  MyEntry({this.id, required this.desc, required this.source, required this.date});

  // factory function (will create the object for us)
  factory MyEntry.fromMap(Map<String, dynamic> json) => MyEntry(
    id: json['id'],
    desc: json['desc'],
    source: json['source'],
    date: json['date'],
  );

  // convert the instance variable to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'desc': desc,
      'source': source,
      'date': date,
    };
  }
}
