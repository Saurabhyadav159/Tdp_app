class FooterImage {
  final String id;
  final String imageUrl;
  final bool isLocal; // Add this field

  FooterImage({
    required this.id,
    required this.imageUrl,
    this.isLocal = false, // Default to false for API images
  });

  factory FooterImage.fromJson(Map<String, dynamic> json) {
    return FooterImage(
      id: json['id'],
      imageUrl: json['image'],
    );
  }

  // Add this factory constructor for local images
  factory FooterImage.local(String path) {
    return FooterImage(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      imageUrl: path,
      isLocal: true,
    );
  }
}
