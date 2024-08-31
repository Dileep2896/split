import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:split/Model/friend_data_model.dart';
import 'package:split/Model/messages.dart';
import 'package:split/Model/user_data_model.dart';

class UserDBController {
  CollectionReference users = FirebaseFirestore.instance.collection("Users");

  Future<String?> userSetup(String name, String authUID, String email) async {
    users.doc(authUID).set({
      'name': name,
      'creditAmount': 0.0,
      'debitAmount': 0.0,
      'email': email,
      'friends': [],
      'friendsRequests': []
    });
    return null;
  }

  Future<bool> checkIfDoExists(String uid) async {
    try {
      var doc = await users.doc(uid).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addFriend(String uid, dynamic myData) async {
    DocumentReference userDoc = users.doc(uid);

    try {
      await userDoc.update({
        'friendsRequests': FieldValue.arrayUnion([myData])
      });
      return Messages.sentFriendRequestSuccess;
    } catch (error) {
      return "Error: $error";
    }
  }

  Future<String> removeFriends(int index, Map<String, dynamic> data,
      UserData userData, String uid) async {
    DocumentReference userDoc = users.doc(uid);
    DocumentReference friendDoc = users.doc(data.keys.elementAt(0));

    try {
      await userDoc.update({
        'friends': FieldValue.arrayRemove([data]),
      });
      await friendDoc.update({
        'friends': FieldValue.arrayRemove([
          {
            uid: {
              "email": userData.email,
              "name": userData.name,
              "uid": uid,
            }
          }
        ]),
      });
      return Messages.friendRemovedSuccess;
    } catch (error) {
      return 'Error: $error';
    }
  }

  Future<String?> acceptFriendRequest(int index, Map<String, dynamic> data,
      UserData userData, String uid) async {
    DocumentReference userDoc = users.doc(uid);
    DocumentReference friendDoc = users.doc(data.keys.elementAt(0));

    try {
      await userDoc.update({
        'friends': FieldValue.arrayUnion([data]),
      });
      await friendDoc.update({
        'friends': FieldValue.arrayUnion([
          {
            uid: {
              "email": userData.email,
              "name": userData.name,
              "uid": uid,
            }
          }
        ]),
      });
      await userDoc.update({
        'friendsRequests': FieldValue.arrayRemove([data]),
      });
    } catch (e) {
      return "Error: $e";
    }

    return null;
  }

  Future<String> rejectFriendRequest(
      Map<String, dynamic> data, String uid) async {
    DocumentReference userDoc = users.doc(uid);
    try {
      await userDoc.update({
        'friendsRequests': FieldValue.arrayRemove([data]),
      });
      return Messages.friendRequestReject;
    } catch (e) {
      return "Error: $e";
    }
  }

  Stream<UserData> getUserData(String id) {
    return users.doc(id).snapshots().map((snap) {
      Map<String, dynamic> mapData = snap.data() as Map<String, dynamic>;
      return UserData.fromMap(mapData);
    });
  }

  Stream<List<FriendDataModel>> streamUsers(String? uid) {
    bool checkFriendsRequest(QueryDocumentSnapshot<Object?> doc, String uid) {
      bool found = false;
      var friendsRequests = doc.get('friendsRequests') as List<dynamic>?;
      if (friendsRequests == null) return false;

      found = friendsRequests.any((request) {
        if (request is Map<String, dynamic>) {
          found = request.keys.contains(uid);
        }
        return found;
      });
      return found;
    }

    bool checkFriendList(QueryDocumentSnapshot<Object?> doc, String uid) {
      bool found = false;
      var friendsRequests = doc.get('friends') as List<dynamic>?;
      if (friendsRequests == null) return false;

      found = friendsRequests.any((request) {
        if (request is Map<String, dynamic>) {
          found = request.keys.contains(uid);
        }
        return found;
      });
      return found;
    }

    if (uid == null) {
      return Stream.value([]);
    } else {
      return users.snapshots().map((snapshot) {
        return snapshot.docs
            .where((doc) {
              return doc.id != uid &&
                  !checkFriendsRequest(doc, uid) &&
                  !checkFriendList(doc, uid);
            }) // Filter out the current user
            .map((doc) => FriendDataModel.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      });
    }
  }
}
