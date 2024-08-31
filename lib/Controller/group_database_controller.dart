import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:split/Controller/user_database_controller.dart';
import 'package:split/Model/group_model.dart';
import 'package:split/Model/members_model.dart';
import 'package:split/Model/messages.dart';

class GroupDBController {
  CollectionReference groups = FirebaseFirestore.instance.collection("Groups");
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("Users");
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  UserDBController groupDBController = UserDBController();

  Future<String> createGroup(
    List<Map<String, dynamic>> selectedFriends,
    String groupName,
  ) async {
    try {
      DocumentReference groupDoc = groups.doc(groupName);

      await groupDoc.set({
        'name': groupName,
        'createdOn': DateTime.now(),
        'noOfMembers': selectedFriends.length,
        'groupActivity': [],
      });

      for (Map<String, dynamic> friend in selectedFriends) {
        DocumentReference friendDoc =
            groupDoc.collection('members').doc(friend['uid']);
        await friendDoc.set(friend);
      }

      return Messages.groupCreatedSuccess;
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<String> addMemberToGroup(
    List<Map<String, dynamic>> selectedFriends,
    String groupName,
  ) async {
    try {
      DocumentReference groupDoc = groups.doc(groupName);

      await groupDoc.set({
        'noOfMembers': selectedFriends.length,
      }, SetOptions(merge: true));

      for (Map<String, dynamic> friend in selectedFriends) {
        DocumentReference friendDoc =
            groupDoc.collection('members').doc(friend['uid']);
        await friendDoc.set(friend);
      }

      return Messages.memberAddSuccess;
    } catch (e) {
      return "Error: $e";
    }
  }

  Stream<List<Group>> streamGroups(String uid) {
    return FirebaseFirestore.instance
        .collection('Groups')
        .snapshots()
        .asyncMap((snapshot) async {
      var groupsList = <Group>[];

      for (var doc in snapshot.docs) {
        if (doc.id == 'Data') continue;

        var membersSnapshot = await doc.reference
            .collection('members')
            .where('uid', isEqualTo: uid)
            .get();

        if (membersSnapshot.docs.isNotEmpty) {
          var allMembers = await doc.reference.collection('members').get();
          List<Member> members =
              allMembers.docs.map((m) => Member.fromFirestore(m)).toList();

          var group = Group.fromFirestore(doc, members: members);
          groupsList.add(group);
        }
      }

      groupsList.sort((a, b) => -(a.createdOn.compareTo(b.createdOn)));
      return groupsList;
    });
  }

  Stream<Group> streamSingleGroup(String groupName) {
    // Assuming groupName is a unique identifier used to locate a specific group document.
    return FirebaseFirestore.instance
        .collection('Groups')
        .doc(groupName) // Use the doc method to specify the document.
        .snapshots()
        .asyncMap(
      (snapshot) async {
        List<Member> members = [];
        var membersSnapshot =
            await snapshot.reference.collection('members').get();

        if (membersSnapshot.docs.isNotEmpty) {
          var allMembers = await snapshot.reference.collection('members').get();
          members =
              allMembers.docs.map((m) => Member.fromFirestore(m)).toList();
        }

        return Group.fromFirestore(snapshot, members: members);
      },
    );
  }

  Stream<List<Member>> streamMembers(String groupName) {
    return groups.doc(groupName).collection('members').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Member.fromFirestore(doc)).toList());
  }

  Stream<Member> streamUserMember(String groupName, String userUID) {
    return groups
        .doc(groupName)
        .collection('members')
        .where('uid', isEqualTo: userUID)
        .snapshots()
        .map((snapshot) {
      return Member.fromFirestore(snapshot.docs.first);
    });
  }

  Future<void> calculatingTotalAmount() async {
    Map<String, Map<String, double>> eachMemTotalAmount = {};

    QuerySnapshot usersSnapshot = await usersCollection.get();

    for (var user in usersSnapshot.docs) {
      eachMemTotalAmount[user.id] = {
        'totalPay': 0.0,
        'totalReceive': 0.0,
      };
    }

    QuerySnapshot gourpSnapshot = await groups.get();

    for (var groupDoc in gourpSnapshot.docs) {
      QuerySnapshot membersSnapshot =
          await groupDoc.reference.collection('members').get();

      for (var memberDoc in membersSnapshot.docs) {
        eachMemTotalAmount.forEach((key, value) {
          if (key == memberDoc.get('uid')) {
            eachMemTotalAmount[memberDoc.get('uid')] = {
              'totalPay': value['totalPay']! + memberDoc.get('totalPay'),
              'totalReceive':
                  value['totalReceive']! + memberDoc.get('totalReceive'),
            };
          }
        });
      }
    }

    eachMemTotalAmount.forEach((key, value) async {
      await usersCollection.doc(key).set({
        'creditAmount': value['totalReceive'],
        'debitAmount': value['totalPay'],
      }, SetOptions(merge: true));
    });
  }

  // Function to update multiple members
  Future<String> updateMultipleMembers(
    List<Member> members,
    String groupName,
    String desciption,
  ) async {
    WriteBatch batch = firebaseFirestore.batch();

    try {
      await groups.doc(groupName).update({
        "groupActivity": FieldValue.arrayUnion([
          {DateTime.now().toString(): desciption}
        ])
      });
    } catch (e) {
      return "$e";
    }

    // Iterate over all members
    for (Member member in members) {
      DocumentReference memberRef =
          groups.doc(groupName).collection('members').doc(member.uid);
      Map<String, dynamic> updateData = {
        'pay': member.pay,
        'receive': member.receive,
        'totalPay': member.totalPay,
        'totalReceive': member.totalReceive,
      };
      // Add update operation to the batch
      batch.update(memberRef, updateData);
    }

    try {
      await batch.commit();
      await calculatingTotalAmount();
      return Messages.expUpdateSuccess;
    } catch (e) {
      return "$e";
    }
  }

  Future<String> settlePay(
    String userUID,
    String payUID,
    String userName,
    String payName,
    String groupName,
    double amount,
  ) async {
    CollectionReference collectionReference =
        groups.doc(groupName).collection("members");
    DocumentReference documentReference = groups.doc(groupName);

    String desciption = "$userName payed $payName, \$$amount";
    Map<String, String> descUpdate = {
      DateTime.now().toString(): desciption,
    };

    try {
      await collectionReference.doc(userUID).update({
        'pay.$payUID.amount': FieldValue.increment(-amount),
      });

      await collectionReference.doc(payUID).update({
        'receive.$userUID.amount': FieldValue.increment(-amount),
      });

      await collectionReference.doc(userUID).update({
        'totalPay': FieldValue.increment(-amount),
      });

      await collectionReference.doc(payUID).update({
        'totalReceive': FieldValue.increment(-amount),
      });

      await usersCollection.doc(userUID).set(
        {'debitAmount': FieldValue.increment(-amount)},
        SetOptions(merge: true),
      );

      await usersCollection.doc(payUID).set(
        {'creditAmount': FieldValue.increment(-amount)},
        SetOptions(merge: true),
      );

      await documentReference.update({
        "groupActivity": FieldValue.arrayUnion([descUpdate])
      });

      return Messages.settledSuccess;
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> isSafeToLeave(String uid, String groupName) async {
    DocumentSnapshot memberQuery =
        await groups.doc(groupName).collection('members').doc(uid).get();
    bool isSafeToLeave = false;
    isSafeToLeave =
        memberQuery.get('totalPay') == 0 && memberQuery.get('totalReceive') == 0
            ? true
            : false;
    return isSafeToLeave;
  }

  Future<bool> isGroupSafeDelete(String groupName) async {
    QuerySnapshot memberQuery =
        await groups.doc(groupName).collection('members').get();

    bool isSafeToDelete = false;

    for (var member in memberQuery.docs) {
      if (member.get('totalPay') == 0 && member.get("totalReceive") == 0) {
        isSafeToDelete = true;
      } else {
        isSafeToDelete = false;
        break;
      }
    }

    return isSafeToDelete;
  }

  Future<String> leaveGroup(String groupName, String uid) async {
    try {
      DocumentReference groupDoc = groups.doc(groupName);

      await groupDoc.set({
        'noOfMembers': FieldValue.increment(-1),
      }, SetOptions(merge: true));
      await groups.doc(groupName).collection('members').doc(uid).delete();
      return "Group Left Successfully";
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<String> deletGroup(String groupName) async {
    try {
      DocumentSnapshot groupSnapshot = await groups.doc(groupName).get();
      QuerySnapshot memberQuery =
          await groups.doc(groupName).collection('members').get();
      for (var member in memberQuery.docs) {
        await member.reference.delete();
      }

      await groupSnapshot.reference.delete();
      return Messages.groupDeleteSuccess;
    } catch (e) {
      return "Error: $e";
    }
  }
}
