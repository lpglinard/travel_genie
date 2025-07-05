class PlaceText {
  const PlaceText({required this.text});

  final String text;

  factory PlaceText.fromJson(Map<String, dynamic> json) {
    return PlaceText(text: json['text'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'text': text};
  }
}