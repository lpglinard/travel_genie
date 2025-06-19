class Photo {
  const Photo({
    required this.reference,
    this.width,
    this.height,
    this.url,
  });

  final String reference;
  final int? width;
  final int? height;
  final String? url;

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      reference: json['reference'] as String? ?? '',
      width: json['width'] as int?,
      height: json['height'] as int?,
      url: json['url'] as String?,
    );
  }
}
