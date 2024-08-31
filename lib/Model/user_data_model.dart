class UserData {
  final String? email;
  final String name;
  final double? creditAmount;
  final double? debitAmount;
  final List? friends;
  final List? friendsRequests;

  UserData({
    this.email,
    required this.name,
    this.creditAmount,
    this.debitAmount,
    this.friends,
    this.friendsRequests,
  });

  factory UserData.fromMap(Map data) {
    return UserData(
      email: data["email"],
      name: data['name'],
      creditAmount: data['creditAmount'].toDouble(),
      debitAmount: data['debitAmount'].toDouble(),
      friends: data['friends'],
      friendsRequests: data['friendsRequests'],
    );
  }
}
