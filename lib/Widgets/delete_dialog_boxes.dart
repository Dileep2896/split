import 'package:flutter/material.dart';
import 'package:split/Controller/group_database_controller.dart';
import 'package:split/Controller/user_database_controller.dart';
import 'package:split/Model/user_data_model.dart';
import 'package:split/Widgets/dialog_utils.dart';
import 'package:split/Widgets/toast_widget.dart';

void showFriendDeleteDialog(
  BuildContext mainContext,
  int index,
  Map<String, dynamic> friend,
  String key,
  UserData userData,
  String uid,
  UserDBController db,
) {
  DialogUtils.showCustomDialog(
    mainContext,
    title: "REMOVE FRIEND",
    okBtnFunction: (context) async {
      Navigator.pop(context);
      await db.removeFriends(index, friend, userData, uid).then((message) {});
    },
    okBtnText: "Remove",
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("You are about to unfriend"),
        Text(
          friend[key]['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    ),
  );
}

void popMultiple(BuildContext context, int count) {
  int popCount = 0;
  Navigator.popUntil(context, (route) {
    return popCount++ >= count;
  });
}

void showMemberLeaveDialog(
  BuildContext mainContext,
  String groupName,
  String uid,
) {
  DialogUtils.showCustomDialog(
    mainContext,
    title: "LEAVE GROUP",
    okBtnFunction: (context) async {
      await GroupDBController().leaveGroup(groupName, uid).then((message) {
        showToast(mainContext, message);
        Navigator.pop(context);
        Navigator.pop(mainContext);
      });
    },
    okBtnText: "LEAVE",
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("You are about to leave the group"),
        Text(
          groupName.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    ),
  );
}

void showMemberUnableLeaveDialog(
  BuildContext mainContext,
  String groupName,
) {
  DialogUtils.showCustomDialog(
    mainContext,
    title: "UNABLE TO LEAVE GROUP",
    okBtnFunction: (context) {
      Navigator.pop(context);
    },
    okBtnText: "OK",
    isShowCancel: false,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "There are transactions yet to settle, you cannot leave the group.",
        ),
        Text(
          groupName.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    ),
  );
}

void showGroupDeleteDialog(
  BuildContext mainContext,
  String groupName,
) {
  DialogUtils.showCustomDialog(
    mainContext,
    title: "DELETE GROUP",
    okBtnFunction: (context) async {
      await GroupDBController().deletGroup(groupName).then((message) {
        showToast(mainContext, message);
        Navigator.pop(context);
        Navigator.pop(mainContext);
      });
    },
    okBtnText: "DELETE",
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("You are about to delete the group"),
        Text(
          groupName.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    ),
  );
}

void showGroupUnableDeleteDialog(
  BuildContext mainContext,
  String groupName,
) {
  DialogUtils.showCustomDialog(
    mainContext,
    title: "UNABLE TO DELETE GROUP",
    okBtnFunction: (context) {
      Navigator.pop(context);
    },
    okBtnText: "OK",
    isShowCancel: false,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "There are transactions yet to settle, you cannot delete the group.",
        ),
        Text(
          groupName.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    ),
  );
}
