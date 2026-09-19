class Branch {
  const Branch({this.id, required this.name});

  final int? id;
  final String name;

  factory Branch.fromMap(Map<String, Object?> map) =>
      Branch(id: map['id'] as int?, name: map['name'] as String);
}
