import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:split/Controller/group_database_controller.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Model/members_model.dart';
import 'package:split/Model/user_data_model.dart';
import 'package:split/Widgets/custom_button.dart';

class SettleAmountScreen extends StatefulWidget {
  const SettleAmountScreen({
    super.key,
    required this.groupDBController,
    required this.user,
    required this.member,
    required this.userData,
    required this.groupName,
    required this.receive,
  });

  final GroupDBController groupDBController;
  final User user;
  final Member member;
  final UserData userData;
  final String groupName;
  final double receive;

  @override
  State<SettleAmountScreen> createState() => _SettleAmountScreenState();
}

class _SettleAmountScreenState extends State<SettleAmountScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const SpinKitChasingDots(
                color: kSecondaryColor,
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "SETTLE AMOUNT",
                      textAlign: TextAlign.center,
                      style: kTitleTextStyle,
                    ),
                    kWidgetHeightGap,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.userData.name,
                            maxLines: 1,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            "----\$--->",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.member.name,
                            textAlign: TextAlign.end,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    kWidgetHeightGap,
                    Text(
                      "\$${widget.receive.toString()}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    kWidgetHeightGap,
                    CustomButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await widget.groupDBController
                            .settlePay(
                          widget.user.uid,
                          widget.member.uid,
                          widget.userData.name,
                          widget.member.name,
                          widget.groupName,
                          widget.receive,
                        )
                            .then((message) {
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.pop(context, message);
                        });
                      },
                      title: "SETTLE",
                    ),
                    CustomButton(
                      onPressed: () {
                        Navigator.pop(context, "Cancelled Transaction");
                      },
                      backgroundColor: Colors.black45,
                      titleColor: kTextColor,
                      title: "Cancel",
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
