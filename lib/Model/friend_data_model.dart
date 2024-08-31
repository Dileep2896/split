class FriendDataModel {
  final String id;
  final String name;
  final String email;

  FriendDataModel({required this.id, required this.name, required this.email});

  // Factory constructor to create a User instance from a Firestore document
  factory FriendDataModel.fromFirestore(Map<String, dynamic> data, String id) {
    return FriendDataModel(
      id: id,
      name: data['name'] as String, // Cast to avoid type issues
      email: data['email'] as String, // Cast to avoid type issues
    );
  }
}
