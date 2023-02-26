class Note {

  int? id;
  int type;
  String note;

  Note({this.id, required this.type, required this.note});

  factory Note.fromMap(Map<String, dynamic> json) => Note(
    id: json['id'],
    type: json['type'],
    note: json['note'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'note': note,
    };
  }
}
