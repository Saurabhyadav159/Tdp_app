class SelfImage {
  final String id;
  final String imageUrl;
  final String imagePath;
  final String position;

  SelfImage({
    required this.id,
    required this.imageUrl,
    required this.imagePath,
    required this.position,
  });

  factory SelfImage.fromJson(Map<String, dynamic> json) {
    return SelfImage(
      id: json['id'],
      imageUrl: json['image'],
      imagePath: json['imagePath'],
      position: json['position'],
    );
  }
}