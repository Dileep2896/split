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
import 'package:split/Widgets/toast_widget.dart';

final _formKey = GlobalKey<FormState>();

class EquallyDistributedTab extends StatefulWidget {
  const EquallyDistributedTab({
    super.key,
    required this.listOfMembers,
    required this.groupName,
  });

  final List<Member> listOfMembers;
  final String groupName;

  @override
  State<EquallyDistributedTab> createState() => _EquallyDistributedTabState();
}

class _EquallyDistributedTabState extends State<EquallyDistributedTab> {
  List<bool>? isCheckValues;

  double equallySplitAmount = 0.0;
  String? totalAmount;
  String? description;
  String? errorMessage;
  bool isError = false;
  bool isLoading = false;

  TextEditingController? amountController;
  TextEditingController? descriptionController;

  List<Member>? updatedMembers;

  GroupDBController groupDBController = GroupDBController();

  @override
  void initState() {
    super.initState();
    isCheckValues = List.filled(widget.listOfMembers.length, true);
  }

  void calculateAmount(String? value) {
    if (value != null) {
      double amount;
      if (value == "") {
        amount = 0;
      } else {
        amount = double.parse(value);
      }
      double splitAmount = double.parse((amount /
              (isCheckValues!.where(
                (value) => value == true,
              )).length)
          .toStringAsFixed(2));
      equallySplitAmount = splitAmount;
    }
  }

  @override
  void dispose() {
    amountController?.dispose();
    descriptionController?.dispose();
    super.dispose();
  }

  bool isDouble(String value) {
    try {
      double.parse(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  void messageToastAndPop(String message) {
    showToast(context, message);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    Member currUserData =
        widget.listOfMembers.singleWhere((members) => members.uid == user.uid);

    return isLoading
        ? const SpinKitChasingDots(
            color: kSecondaryColor,
          )
        : Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20,
              top: 20,
            ),
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomIconTextField(
                      controller: descriptionController,
                      icon: Icons.description,
                      hint: "Enter Description",
                      onChanged: (value) {
                        setState(() {
                          description = value!;
                        });
                      },
                    ),
                    kWidgetHeightGap,
                    CustomIconTextField(
                      controller: amountController,
                      hint: "Enter Amount",
                      icon: Icons.attach_money,
                      validator: (value) {
                        if (value!.isEmpty || !isDouble(value)) {
                          return "Please Enter a valid number amount";
                        } else {
                          return null;
                        }
                      },
                      keyBoardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        setState(() {
                          if (_formKey.currentState!.validate()) {
                            totalAmount = value!;
                            calculateAmount(value);
                            updatedMembers = updateMemberAmounts(
                              context,
                              widget.listOfMembers,
                              equallySplitAmount,
                              isCheckValues!,
                            );
                          }
                        });
                      },
                    ),
                    kWidgetHeightGap,
                    const Divider(
                      color: kPrimaryLightColor,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.listOfMembers.length,
                        itemBuilder: (context, index) {
                          Member data = widget.listOfMembers[index];
                          String names =
                              "${data.name.split(" ")[0]} ${data.name.split(" ").length > 1 ? data.name.split(" ")[1] : ""}";
                          bool isUser = data == currUserData;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Checkbox(
                              activeColor: kTextColor,
                              value: isCheckValues?[index] ?? false,
                              onChanged: (value) {
                                setState(() {
                                  isCheckValues?[index] = value!;
                                  if (totalAmount != null) {
                                    calculateAmount(totalAmount);
                                    updatedMembers = updateMemberAmounts(
                                      context,
                                      widget.listOfMembers,
                                      equallySplitAmount,
                                      isCheckValues!,
                                    );
                                  }
                                });
                              },
                            ),
                            title: Text(
                              names,
                              style: TextStyle(
                                color:
                                    isUser ? Colors.greenAccent : Colors.white,
                              ),
                            ),
                            trailing: Text(
                              "\$ ${isCheckValues![index] ? equallySplitAmount : 0.0}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: kTextColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    isError
                        ? Text("Error: ${errorMessage ?? "wUw"}")
                        : const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: CustomButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          description ??= "something";
                          String desciptionMessage =
                              "${currUserData.name} added \$$totalAmount for $description";
                          String message =
                              await groupDBController.updateMultipleMembers(
                            updatedMembers!,
                            widget.groupName,
                            desciptionMessage,
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
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
