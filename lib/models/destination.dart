class Destination {
  const Destination(this.name, this.imageUrl);

  final String name;
  final String imageUrl;

  factory Destination.fromFirestore(Map<String, dynamic> data) {
    return Destination(
      data['displayName'] as String,
      data['photoUrl'] as String,
    );
  }
}
