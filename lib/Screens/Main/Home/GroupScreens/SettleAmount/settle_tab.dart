import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split/Controller/group_database_controller.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Model/group_model.dart';
import 'package:split/Model/members_model.dart';
import 'package:split/Model/messages.dart';
import 'package:split/Model/user_data_model.dart';
import 'package:split/Screens/Main/Home/GroupScreens/SettleAmount/settle_amount_screen.dart';
import 'package:split/Widgets/toast_widget.dart';

class SettleTab extends StatefulWidget {
  const SettleTab({
    super.key,
    required this.index,
  });

  final int index;

  @override
  State<SettleTab> createState() => _SettleTabState();
}

class _SettleTabState extends State<SettleTab> {
  bool isError = false;
  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    Group groupData = Provider.of<List<Group>>(context)[widget.index];
    User user = Provider.of<User>(context);
    UserData userData = Provider.of<UserData>(context);
    String groupName = groupData.name;
    GroupDBController groupDBController = GroupDBController();

    return StreamBuilder(
      stream: GroupDBController().streamMembers(groupName),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          List<Member> members =
              snapshot.data!.where((member) => member.uid != user.uid).toList();
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isError
                      ? errorMessage
                      : "Tap on red button to settle".toUpperCase(),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      Member member = members[index];
                      String selfName = member.pay[user.uid].keys.first;

                      // Pay indicates the other members needs to pay you
                      double pay = member.pay[user.uid][selfName].toDouble();
                      // Receive indicates the other members needs to receive from you
                      double receive =
                          member.receive[user.uid][selfName].toDouble();

                      return Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(
                                  top: 20,
                                  left: 20,
                                  bottom: 20,
                                ),
                                color: kSecondaryColor,
                                child: Text(
                                  member.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            receive != 0.0
                                ? InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SettleAmountScreen(
                                            groupDBController:
                                                groupDBController,
                                            user: user,
                                            member: member,
                                            userData: userData,
                                            groupName: groupName,
                                            receive: receive,
                                          ),
                                        ),
                                      ).then((message) {
                                        if (message ==
                                            Messages.settledSuccess) {
                                          showToast(context, message);
                                        } else {
                                          setState(() {
                                            isError = true;
                                            errorMessage = message;
                                          });
                                        }
                                      });
                                    },
                                    child: Ink(
                                      padding: const EdgeInsets.all(20),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF8B0000),
                                      ),
                                      child: OwnTextInfo(
                                        pay: receive,
                                        ownTitle: "you own",
                                      ),
                                    ),
                                  )
                                : pay != 0.0
                                    ? Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF013220),
                                        ),
                                        child: OwnTextInfo(
                                          pay: pay,
                                          ownTitle: "owns you",
                                        ),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF8B8000),
                                        ),
                                        child: const Text(
                                          "SETTLED",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
        return const Center(
          child: Text(
            "DATA NOT FOUND",
          ),
        );
      },
    );
  }
}

class OwnTextInfo extends StatelessWidget {
  const OwnTextInfo({
    super.key,
    required this.pay,
    required this.ownTitle,
  });

  final double pay;
  final String ownTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          ownTitle,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          "\$ ${pay.toString()}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
