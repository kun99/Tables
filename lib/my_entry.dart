class MyEntry {

  // instance variables
  int? id;
  String descr;
  String source;
  String date;

  // constructor
  MyEntry({this.id, required this.descr, required this.source, required this.date});

  // factory function (will create the object for us)
  factory MyEntry.fromMap(Map<String, dynamic> json) => MyEntry(
    id: json['id'],
    descr: json['descr'],
    source: json['source'],
    date: json['date'],
  );

  // convert the instance variable to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descr': descr,
      'source': source,
      'date': date,
    };
  }
}
