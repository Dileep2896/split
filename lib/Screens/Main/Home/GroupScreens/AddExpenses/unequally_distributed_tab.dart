import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:split/Controller/calculate_amount_split.dart';
import 'package:split/Controller/group_database_controller.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Model/members_model.dart';
import 'package:split/Model/messages.dart';
import 'package:split/Widgets/custom_button.dart';
import 'package:split/Widgets/custom_icon_text_field.dart';
import 'package:split/Widgets/custom_text_field.dart';
import 'package:split/Widgets/toast_widget.dart';

class UnequallyDistributedTab extends StatefulWidget {
  const UnequallyDistributedTab({
    super.key,
    required this.listOfMembers,
    required this.groupName,
  });

  final List<Member> listOfMembers;
  final String groupName;

  @override
  State<UnequallyDistributedTab> createState() =>
      _UnequallyDistributedTabState();
}

class _UnequallyDistributedTabState extends State<UnequallyDistributedTab> {
  List<double>? membersIndividualAmount;
  List<Member> processedMembers = [];

  bool isLoading = false;
  bool isError = false;
  String errorMessage = "";

  TextEditingController? descriptionController;
  String? description;

  GroupDBController groupDBController = GroupDBController();

  @override
  void initState() {
    super.initState();
    membersIndividualAmount =
        List<double>.filled(widget.listOfMembers.length, 0.0);
  }

  @override
  void dispose() {
    descriptionController?.dispose();
    super.dispose();
  }

  void messageToastAndPop(String message) {
    showToast(context, message);
    Navigator.pop(context);
  }

  // void printMemberTran(List<Member> members) {
  //   for (Member member in members) {
  //     print("${member.name} | PAY: ${member.pay}");
  //     print("${member.name} | RECEIVE: ${member.receive}");
  //     print(
  //         "Total Pay: ${member.totalPay} | Total Receive: ${member.totalReceive}");
  //     print(
  //         "-----------------------------------------------------------------");
  //   }
  //   print("-----------------------------------------------------------------");
  // }

  // void printIndMemberTran(Member member) {
  //   print("${member.name} | PA.Y: ${member.pay}");
  //   print("${member.name} | RECEIVE: ${member.receive}");
  //   print(
  //       "Total Pay: ${member.totalPay} | Total Receive: ${member.totalReceive}");
  //   print("-----------------------------------------------------------------");
  // }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    Member currUserData =
        widget.listOfMembers.singleWhere((members) => members.uid == user.uid);
    List<Member> members = widget.listOfMembers
        .where((members) => members.uid != user.uid)
        .toList();

    return isLoading
        ? const SpinKitChasingDots(
            color: kSecondaryColor,
          )
        : SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20,
                top: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomIconTextField(
                    icon: Icons.description,
                    controller: descriptionController,
                    hint: "Enter Description",
                    onChanged: (value) {
                      setState(() {
                        description = value!;
                      });
                    },
                  ),
                  kWidgetHeightGap,
                  const Divider(
                    color: kPrimaryLightColor,
                  ),
                  isError
                      ? Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.redAccent),
                        )
                      : const SizedBox(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        Member data = members[index];
                        String name =
                            "${data.name.split(" ")[0]} ${data.name.split(" ")[1]}";

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: CustomTextField(
                                  onChanged: (value) {
                                    if (value != "") {
                                      try {
                                        setState(() {
                                          isError = false;
                                          errorMessage = "";
                                        });
                                        double amount = double.parse(value);
                                        membersIndividualAmount![index] =
                                            amount;
                                        updateEachMemberAmount(
                                          currUserData,
                                          data,
                                          amount,
                                        );
                                      } on FormatException {
                                        setState(() {
                                          isError = true;
                                          errorMessage =
                                              "Please enter a valid amount";
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        isError = false;
                                        errorMessage = "";
                                      });
                                    }
                                  },
                                  textStyle: TextStyle(
                                    color: isError ? Colors.red : kTextColor,
                                  ),
                                  keyBoardType: TextInputType.number,
                                  icon: const Icon(
                                    Icons.attach_money,
                                  ),
                                  hintText: "0.0",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: CustomButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        double totalAmount =
                            membersIndividualAmount!.reduce((a, b) => a + b);
                        description ??= "something";
                        String desciptionMesssage =
                            "${currUserData.name} added \$$totalAmount for $description";
                        String message =
                            await groupDBController.updateMultipleMembers(
                          widget.listOfMembers,
                          widget.groupName,
                          desciptionMesssage,
                        );
                        if (message == Messages.expUpdateSuccess) {
                          messageToastAndPop(message);
                        } else {
                          setState(() {
                            isError = true;
                            errorMessage = message;
                          });
                        }
                        setState(() {
                          isLoading = false;
                        });
                      },
                      title: "SUBMIT",
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
