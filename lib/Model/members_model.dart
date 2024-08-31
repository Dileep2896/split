import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  final String uid;
  final String name;
  final String email;
  double totalPay;
  double totalReceive;
  Map<String, dynamic> pay;
  Map<String, dynamic> receive;

  Member({
    required this.uid,
    required this.name,
    required this.email,
    required this.pay,
    required this.receive,
    required this.totalPay,
    required this.totalReceive,
  });

  factory Member.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Member(
      uid: doc.id,
      name: data['name'] ?? 'No name',
      email: data['email'] ?? 'No email',
      pay: data['pay'] ?? {},
      receive: data['receive'] ?? {},
      totalPay: data['totalPay'].toDouble(),
      totalReceive: data['totalReceive'].toDouble(),
    );
  }

  Member.copy(Member other)
      : uid = other.uid,
        name = other.name,
        email = other.email,
        totalPay = other.totalPay,
        totalReceive = other.totalReceive,
        pay = Map.from(
            other.pay.map((key, value) => MapEntry(key, Map.from(value)))),
        receive = Map.from(
            other.receive.map((key, value) => MapEntry(key, Map.from(value))));
}
