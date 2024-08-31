import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:split/Controller/group_database_controller.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Model/user_data_model.dart';
import 'package:split/Widgets/custom_button.dart';
import 'package:split/Widgets/custom_text_field.dart';
import 'package:split/Widgets/toast_widget.dart';

final _formKey = GlobalKey<FormState>();

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({
    super.key,
    required this.userData,
    required this.fbCurrUser,
    required this.db,
  });

  final UserData userData;
  final User fbCurrUser;
  final GroupDBController db;

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  String? groupName;
  bool isFriendsEmpty = false;
  bool isLoading = false;

  late List<bool> friendsListSelected;
  List<Map<String, dynamic>> selectedItems = [];

  @override
  void initState() {
    super.initState();
    UserData userData = widget.userData;
    friendsListSelected =
        List<bool>.filled(widget.userData.friends?.length ?? 0, false);
    selectedItems.add({
      "uid": widget.fbCurrUser.uid,
      "name": userData.name,
      "email": userData.email,
      "totalPay": 0.0,
      "totalReceive": 0.0,
      "pay": {},
      "receive": {},
    });
  }

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
  }

  @override
  Widget build(BuildContext context) {
    List friends = widget.userData.friends ?? [];

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 30.0,
          ),
          child: isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SpinKitChasingDots(
                      color: kSecondaryColor,
                    ),
                    kWidgetHeightGap,
                    Text(
                      "Creating Group".toUpperCase(),
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
                          "CREATE A NEW GROUP",
                          style: kTitleTextStyle.copyWith(fontSize: 25),
                        ),
                      ),
                      kWidgetHeightGap,
                      CustomTextField(
                        hintText: "Enter Group Name",
                        onChanged: (value) {
                          groupName = value;
                        },
                        validator: (groupVal) => groupVal!.length < 3
                            ? "group name should be atleast 3 characters"
                            : null,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        "Oops, Looks Like You Don't Have Any Friends")
                                  ],
                                ),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                              itemCount: friends.length,
                              itemBuilder: (context, index) {
                                String key =
                                    friends.elementAt(index).keys.elementAt(0);
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
                                          color: friendsListSelected[index]
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
                                      toggleSelection(index, friends[index]);
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
                            if (selectedItems.length < 2) {
                              setState(() {
                                isFriendsEmpty = true;
                              });
                            } else {
                              selectedItems = updateMembers(selectedItems);
                              setState(() {
                                isFriendsEmpty = false;
                              });
                              toggleLoading(true);
                              await widget.db
                                  .createGroup(selectedItems, groupName!)
                                  .then((message) {
                                createToast(message);
                                toggleLoading(false);
                                popNavigator();
                              });
                            }
                          }
                        },
                        title: "Create Group",
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
