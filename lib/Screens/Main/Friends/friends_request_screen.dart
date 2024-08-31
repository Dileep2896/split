import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split/Controller/user_database_controller.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Model/messages.dart';
import 'package:split/Model/user_data_model.dart';
import 'package:split/Widgets/toast_widget.dart';

class FriendsRequestScreen extends StatefulWidget {
  const FriendsRequestScreen({super.key});

  @override
  State<FriendsRequestScreen> createState() => _FriendsRequestScreenState();
}

class _FriendsRequestScreenState extends State<FriendsRequestScreen> {
  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);
    User currentUser = Provider.of<User>(context);

    List friends = userData.friendsRequests ?? [];
    UserDBController db = UserDBController();

    void showToastOutside(String result) {
      showToast(context, result);
    }

    return Scaffold(
      body: friends.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("There are no friend requests currently"),
                ],
              ),
            )
          : ListView.builder(
              itemCount: friends.length,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              itemBuilder: (context, index) {
                String key = friends.elementAt(index).keys.elementAt(0);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: kSecondaryColor,
                    child: Text(
                      friends[index][key]['name'].toString().split("")[0],
                    ),
                  ),
                  title: Text(
                    friends[index][key]['name'].toString().toUpperCase(),
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    friends[index][key]['email'].toString().split("@")[0],
                    style: const TextStyle(
                      color: kTextColor,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () async {
                          String? result = await db.acceptFriendRequest(
                            index,
                            friends.elementAt(index),
                            userData,
                            currentUser.uid,
                          );
                          if (result != null) {
                            showToastOutside(result);
                          }
                        },
                        child: const Icon(Icons.done),
                      ),
                      TextButton(
                        onPressed: () async {
                          String? result = await db.rejectFriendRequest(
                            friends.elementAt(index),
                            currentUser.uid,
                          );
                          if (result == Messages.friendRequestReject) {
                            showToastOutside(result);
                          }
                        },
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
