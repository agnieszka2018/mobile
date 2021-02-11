class Event {
  String id;
  String hash;
  String name;
  String note;
  int color;
  DateTime fromdate;
  DateTime todate;

  Event({
    this.id,
    this.hash,
    this.name,
    this.note,
    this.color,
    this.fromdate,
    this.todate,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Event(
      hash: map['hash'],
      name: map['name'],
      note: map['note'],
      color: map['color'],
      fromdate: DateTime.fromMillisecondsSinceEpoch(map['fromdate']),
      todate: DateTime.fromMillisecondsSinceEpoch(map['todate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hash': hash,
      'name': name,
      'note': note,
      'color': color,
      'fromdate': fromdate.toIso8601String(),
      'todate': todate.toIso8601String(),
    };
  }

  Event.fromJson(Map<String, dynamic> json) {
    hash = json['hash'];
    name = json['name'];
    note = json['note'];
    color = json['color'];
    fromdate = DateTime.tryParse(json['fromdate']);
    todate = DateTime.tryParse(json['todate']);
  }

  Map<String, dynamic> toJson() => {
        "hash": hash,
        "name": name,
        "note": note,
        "color": color,
        "fromdate": fromdate.toIso8601String(),
        "todate": todate.toIso8601String(),
      };
}
