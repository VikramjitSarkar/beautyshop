// lib/models/category.dart

class Category {
  final String id;
  final String imageUrl;
  final String name;
  final String status;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.status,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] as String,
      imageUrl: json['image'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
