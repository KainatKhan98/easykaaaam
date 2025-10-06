
class Category {
  final String id;
  final String title;
  final String imageUrl;

  Category({required this.id, required this.title, required this.imageUrl});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      title: json['name'] ?? 'No title',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}