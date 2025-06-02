class Note {
  final int? id; // Nullable if auto-incrementing
  final int? userId;
  final String foodName;
  final String measure;
  final String createdAt;

  Note({
    this.id,
    this.userId,
    required this.foodName,
    required this.measure,
    required this.createdAt,
  });

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'food_name': foodName,
      'measure': measure,
      'createdAt': createdAt,
    };
  }

  // Create a Note object from a Map object
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      foodName: map['food_name'] as String,
      measure: map['measure'] as String,
      createdAt: map['createdAt'] as String,
    );
  }
}