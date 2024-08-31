import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:split/Model/members_model.dart';

class Group {
  final String name;
  final int noOfMembers;
  final DateTime createdOn; // Now required and non-nullable
  final List<dynamic> groupActivity;
  final List<Member> members;

  Group({
    required this.name,
    required this.noOfMembers,
    required this.groupActivity,
    required this.createdOn,
    required this.members,
  });

  factory Group.fromFirestore(DocumentSnapshot doc, {List<Member>? members}) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Group(
      name: doc.id,
      noOfMembers: data['noOfMembers'] ?? 0,
      createdOn: (data['createdOn']).toDate(), // Assume it must be present
      groupActivity: data['groupActivity'] ?? [],
      members: members ?? [],
    );
  }
}
