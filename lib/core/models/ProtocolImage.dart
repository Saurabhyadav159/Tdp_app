class ProtocolImage {
  final String id;
  final String imageUrl;
  ProtocolImage({required this.id, required this.imageUrl});

  factory ProtocolImage.fromJson(Map<String, dynamic> json) {
    return ProtocolImage(
      id: json['id'],
      imageUrl: json['image'],
    );
  }
}
