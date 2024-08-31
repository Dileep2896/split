import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split/Controller/user_database_controller.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Model/friend_data_model.dart';
import 'package:split/Model/user_data_model.dart';
import 'package:split/Screens/Main/Friends/add_friends_screen.dart';
import 'package:split/Widgets/delete_dialog_boxes.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);
    User currentUser = Provider.of<User>(context);
    List<FriendDataModel> noOfUsers =
        Provider.of<List<FriendDataModel>>(context);

    List friends = userData.friends ?? [];
    UserDBController db = UserDBController();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryLightColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFriendsScreen(
                userData: userData,
                fbCurrUser: currentUser,
                noOfUsers: noOfUsers,
                db: db,
              ),
            ),
          );
        },
        isExtended: true,
        child: const Icon(
          Icons.person_add,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: friends.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Oops, Looks Like You Don't Have Any Friends"),
                  Text("Try Sending a friend request!")
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
                        friends[index][key]['name'].toString().split("")[0]),
                  ),
                  title: Text(
                    friends[index][key]['name'].toString().toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    friends[index][key]['email'].toString(),
                    style: const TextStyle(
                      color: kTextColor,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      showFriendDeleteDialog(
                        context,
                        index,
                        friends.elementAt(index),
                        friends.elementAt(index).keys.first,
                        userData,
                        currentUser.uid,
                        db,
                      );
                    },
                    child: const Icon(Icons.close),
                  ),
                );
              },
            ),
    );
  }
}
