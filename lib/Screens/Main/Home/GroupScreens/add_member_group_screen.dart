import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:split/Controller/group_database_controller.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Model/group_model.dart';
import 'package:split/Model/user_data_model.dart';
import 'package:split/Widgets/custom_button.dart';
import 'package:split/Widgets/toast_widget.dart';

final _formKey = GlobalKey<FormState>();

class AddMemberGroupScreen extends StatefulWidget {
  const AddMemberGroupScreen({
    super.key,
    required this.groupName,
    required this.groupData,
    required this.userData,
    required this.fbCurrUser,
  });

  final String groupName;
  final Group groupData;
  final UserData userData;
  final User fbCurrUser;

  @override
  State<AddMemberGroupScreen> createState() => _AddMemberGroupScreenState();
}

class _AddMemberGroupScreenState extends State<AddMemberGroupScreen> {
  String? groupName;
  bool isFriendsEmpty = false;
  bool isLoading = false;
  GroupDBController db = GroupDBController();

  late List<bool> friendsListSelected;
  List friends = [];
  List<Map<String, dynamic>> selectedItems = [];

  void toggleSelection(int index, Map<String, dynamic> itemData) {
    setState(() {
      int existingIndex = selectedItems
          .indexWhere((item) => item['uid'] == itemData.keys.elementAt(0));
      if (existingIndex != -1) {
        selectedItems.removeAt(existingIndex);
      } else {
        String key = itemData.keys.elementAt(0);
        Map<String, dynamic> newItem = {
          'uid': itemData[key]['uid'],
          'name': itemData[key]['name'],
          'email': itemData[key]['email'],
          "totalPay": 0.0,
          "totalReceive": 0.0,
          'pay': {},
          'receive': {},
        };
        selectedItems.add(newItem);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    UserData userData = widget.userData;
    List membersUID = [];

    selectedItems.add({
      "uid": widget.fbCurrUser.uid,
      "name": userData.name,
      "email": userData.email,
      "totalPay": 0.0,
      "totalReceive": 0.0,
      "pay": {},
      "receive": {},
    });

    for (var member in widget.groupData.members) {
      membersUID.add(member.uid);
    }

    for (var friend in userData.friends!) {
      String key = friend.keys.first;
      if (!membersUID.contains(key)) {
        friends.add(friend);
      } else {
        selectedItems.add(formatMemberData(
            friend[key]['uid'], friend[key]['name'], friend[key]['email']));
      }
    }

    friendsListSelected = List<bool>.filled(friends.length, false);
  }

  Map<String, dynamic> formatMemberData(String uid, String name, String email) {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "totalPay": 0.0,
      "totalReceive": 0.0,
      "pay": {},
      "receive": {},
    };
  }

  List<Map<String, dynamic>> updateMembers(List<Map<String, dynamic>> members) {
    for (var member in members) {
      Map<String, Map<String, dynamic>> payMap = {};
      Map<String, Map<String, dynamic>> receiveMap = {};

      // Add each other member to the current member's pay and receive maps
      for (var otherMember in members) {
        if (otherMember['uid'] != member['uid']) {
          // Ensure not to add themselves
          payMap[otherMember['uid']] = {
            "amount": 0.0,
          };
          receiveMap[otherMember['uid']] = {
            "amount": 0.0,
          };
        }
      }

      // Assign the updated maps to the member
      member['pay'] = payMap;
      member['receive'] = receiveMap;
    }
    return members;
  }

  void createToast(String message) {
    showToast(context, message, duration: const Duration(seconds: 1));
  }

  void toggleLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void popNavigator() {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kSecondaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 200), () {
              Navigator.of(context).pop();
            });
          },
        ),
      ),
      body: StreamBuilder<Group>(
          stream: db.streamSingleGroup(widget.groupName),
          builder: (context, snapshot) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 30.0,
                ),
                child: isLoading
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpinKitChasingDots(
                            color: kSecondaryColor,
                          ),
                          kWidgetHeightGap,
                          Text(
                            "ADD MEMBERS",
                            style: kDefaultTextStyle,
                          ),
                        ],
                      )
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Text(
                                "ADD MEMBERS TO GROUP ${widget.groupName}",
                                style: kTitleTextStyle.copyWith(fontSize: 25),
                              ),
                            ),
                            kWidgetHeightGap,
                            Text(
                              "Tap to select friends".toUpperCase(),
                            ),
                            const Divider(
                              color: kPrimaryLightColor,
                            ),
                            friends.isEmpty
                                ? const Expanded(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Oops, looks like there are no friends to add",
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : Expanded(
                                    child: ListView.builder(
                                    itemCount: friends.length,
                                    itemBuilder: (context, index) {
                                      String key = friends
                                          .elementAt(index)
                                          .keys
                                          .elementAt(0);
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: ListTile(
                                          selected: friendsListSelected[index],
                                          textColor: kPrimaryLightColor,
                                          selectedColor: Colors.white,
                                          selectedTileColor: kPrimaryLightColor,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                friendsListSelected[index]
                                                    ? Colors.white60
                                                    : kSecondaryColor,
                                            child: Text(
                                              friends[index][key]['name']
                                                  .toString()
                                                  .split("")[0],
                                              style: TextStyle(
                                                color:
                                                    friendsListSelected[index]
                                                        ? kPrimaryColor
                                                        : kPrimaryLightColor,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            friends[index][key]['name']
                                                .toString()
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onTap: () {
                                            toggleSelection(
                                                index, friends[index]);
                                            setState(() {
                                              friendsListSelected[index] =
                                                  !friendsListSelected[index];
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  )),
                            isFriendsEmpty
                                ? const Text(
                                    "Please select atleast 1 friend",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                    ),
                                  )
                                : const SizedBox(),
                            CustomButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  if (selectedItems.isEmpty) {
                                    setState(() {
                                      isFriendsEmpty = true;
                                    });
                                  } else {
                                    selectedItems =
                                        updateMembers(selectedItems);
                                    setState(() {
                                      isFriendsEmpty = false;
                                    });
                                    toggleLoading(true);
                                    await db
                                        .addMemberToGroup(selectedItems,
                                            widget.groupData.name)
                                        .then((message) {
                                      createToast(message);
                                      toggleLoading(false);
                                      popNavigator();
                                    });
                                  }
                                }
                              },
                              title: "ADD MEMBERS",
                            )
                          ],
                        ),
                      ),
              ),
            );
          }),
    );
  }
}
