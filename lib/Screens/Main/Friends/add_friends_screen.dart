import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:split/Controller/user_database_controller.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Model/friend_data_model.dart';
import 'package:split/Model/messages.dart';
import 'package:split/Model/user_data_model.dart';
import 'package:split/Widgets/toast_widget.dart';

class AddFriendsScreen extends StatefulWidget {
  const AddFriendsScreen({
    super.key,
    required this.userData,
    required this.fbCurrUser,
    required this.noOfUsers,
    required this.db,
  });

  final UserData userData;
  final User fbCurrUser;
  final List<FriendDataModel> noOfUsers;
  final UserDBController db;

  @override
  State<AddFriendsScreen> createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  bool sentIcon = false;

  void messageToast(String message) {
    showToast(context, message);
  }

  late List<bool> iconToggleState;

  @override
  void initState() {
    super.initState();
    iconToggleState = List<bool>.filled(widget.noOfUsers.length, false);
  }

  @override
  Widget build(BuildContext context) {
    String search = "";

    var filteredUsers = widget.noOfUsers.where((user) {
      return user.name.toLowerCase().contains(search.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kSecondaryColor,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  left: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: kPrimaryLightColor,
                    width: 3,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        cursorColor: kTextColor,
                        style: kDefaultTextStyle,
                        decoration: const InputDecoration(
                          hintText: 'Search by name...',
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            search = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
              ),
              kWidgetHeightGap,
              const Divider(color: kSecondaryColor),
              widget.noOfUsers.isEmpty
                  ? const Expanded(child: Center(child: Text('No Members')))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          var friend = filteredUsers[index];
                          return ListTile(
                            title: Text(friend.name),
                            subtitle: Text(friend.email),
                            trailing: IconButton(
                              onPressed: () async {
                                String message =
                                    await widget.db.addFriend(friend.id, {
                                  widget.fbCurrUser.uid: {
                                    "name": widget.userData.name,
                                    "email": widget.userData.email,
                                    "uid": widget.fbCurrUser.uid,
                                  }
                                });
                                if (message ==
                                    Messages.sentFriendRequestSuccess) {
                                  setState(() {
                                    iconToggleState[index] = true;
                                  });
                                }
                                messageToast(message);
                              },
                              icon: Icon(
                                iconToggleState[index]
                                    ? Icons.done
                                    : Icons.person_add,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
