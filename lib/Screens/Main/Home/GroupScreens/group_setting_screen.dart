import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:split/Controller/date_converter.dart';
import 'package:split/Controller/group_database_controller.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Model/group_model.dart';
import 'package:split/Model/members_model.dart';
import 'package:split/Model/user_data_model.dart';
import 'package:split/Screens/Main/Home/GroupScreens/add_member_group_screen.dart';
import 'package:split/Screens/Main/Home/GroupScreens/group_screen.dart';
import 'package:split/Widgets/delete_dialog_boxes.dart';
import 'package:split/Widgets/member_setting_trailing_text.dart';

class GroupSettingScreen extends StatefulWidget {
  const GroupSettingScreen({
    super.key,
    required this.groupName,
    required this.index,
  });

  final String groupName;
  final int index;

  @override
  State<GroupSettingScreen> createState() => _GroupSettingScreenState();
}

class _GroupSettingScreenState extends State<GroupSettingScreen> {
  GroupDBController groupDBController = GroupDBController();

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    UserData userData = Provider.of<UserData>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kSecondaryColor,
        title: const Text("Group Settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // Custom icon
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupScreen(index: widget.index),
              ),
            );
          },
        ),
      ),
      body: StreamBuilder<Group>(
        stream: groupDBController.streamSingleGroup(widget.groupName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SpinKitChasingDots(
              color: kSecondaryColor,
            );
          }
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              Group groupData = snapshot.data!;
              List<Member> groupMembers = snapshot.data!.members;

              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20.0,
                          left: 20,
                          right: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.groupName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Text(
                                  "Total Group Members: ",
                                ),
                                Text(
                                  "${groupMembers.length}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Text(
                                  "Total Group Activities: ",
                                ),
                                Text(
                                  "${groupData.groupActivity.length}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            kWidgetHeightGap,
                            Text("Group Members".toUpperCase()),
                            const Divider(
                              color: kPrimaryLightColor,
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddMemberGroupScreen(
                                groupName: groupData.name,
                                groupData: groupData,
                                userData: userData,
                                fbCurrUser: user,
                              ),
                            ),
                          );
                        },
                        splashColor: kSecondaryColor,
                        leading: const SizedBox(
                          width: 40,
                          child: Icon(
                            Icons.group_add,
                            color: Colors.white,
                          ),
                        ),
                        titleTextStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                        title: const Text(
                          "Add people to the group",
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: groupMembers.length,
                        itemBuilder: (context, index) {
                          Member member = groupMembers[index];
                          return ListTile(
                            leading: SizedBox(
                              width: 40,
                              child: CircleAvatar(
                                backgroundColor: kSecondaryColor,
                                child: Text(member.name[0]),
                              ),
                            ),
                            title: Text(member.name),
                            subtitle: Text(member.email),
                            trailing: member.totalPay != 0.0
                                ? MemberSettingTrailingText(
                                    text: member.totalPay.toString(),
                                    tranDirection: "owes",
                                    color: Colors.redAccent,
                                  )
                                : member.totalReceive != 0.0
                                    ? MemberSettingTrailingText(
                                        text: member.totalReceive.toString(),
                                        tranDirection: "gets back",
                                        color: Colors.greenAccent,
                                      )
                                    : const SizedBox(),
                          );
                        },
                      ),
                      kWidgetHeightGap,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text("More Settings".toUpperCase()),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: kPrimaryLightColor,
                        ),
                      ),
                      ListTile(
                        leading: const SizedBox(
                          width: 40,
                          child: Icon(Icons.date_range),
                        ),
                        title: Text(
                          "Created ${formatDateTime(groupData.createdOn)}",
                        ),
                      ),
                      ListTile(
                        onTap: () async {
                          await groupDBController
                              .isSafeToLeave(user.uid, widget.groupName)
                              .then((isSafeToLeave) {
                            if (isSafeToLeave) {
                              showMemberLeaveDialog(
                                context,
                                widget.groupName,
                                user.uid,
                              );
                            } else {
                              showMemberUnableLeaveDialog(
                                context,
                                widget.groupName,
                              );
                            }
                          });
                        },
                        splashColor: kSecondaryColor,
                        leading: const SizedBox(
                          width: 40,
                          child: Icon(Icons.exit_to_app),
                        ),
                        title: const Text("LEAVE GROUP"),
                      ),
                      ListTile(
                        onTap: () async {
                          await groupDBController
                              .isGroupSafeDelete(widget.groupName)
                              .then((isSafeToDelete) {
                            if (isSafeToDelete) {
                              showGroupDeleteDialog(context, widget.groupName);
                            } else {
                              showGroupUnableDeleteDialog(
                                context,
                                widget.groupName,
                              );
                            }
                          });
                        },
                        splashColor: Colors.red[50],
                        iconColor: Colors.redAccent,
                        textColor: Colors.redAccent,
                        leading: const SizedBox(
                          width: 40,
                          child: Icon(Icons.delete),
                        ),
                        title: const Text("DELETE GROUP"),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
          return const Center(
            child: Text(
              "Group Not Found",
            ),
          );
        },
      ),
    );
  }
}
