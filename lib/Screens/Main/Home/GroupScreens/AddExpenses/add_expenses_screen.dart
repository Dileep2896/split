import 'package:flutter/material.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Model/members_model.dart';
import 'package:split/Screens/Main/Home/GroupScreens/AddExpenses/equally_distributed_tab.dart';
import 'package:split/Screens/Main/Home/GroupScreens/AddExpenses/unequally_distributed_tab.dart';

class AddExpensesScreen extends StatefulWidget {
  const AddExpensesScreen({
    super.key,
    required this.listOfMembers,
    required this.groupName,
  });

  final List<Member> listOfMembers;
  final String groupName;

  @override
  State<AddExpensesScreen> createState() => _AddExpensesScreenState();
}

class _AddExpensesScreenState extends State<AddExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "SPLIT YOUR BILL".toUpperCase(),
            textAlign: TextAlign.start,
            style: kTitleTextStyle.copyWith(fontSize: 20),
          ),
          backgroundColor: kSecondaryColor,
          bottom: const TabBar(
            dividerColor: kPrimaryColor,
            indicatorColor: kPrimaryLightColor,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              color: kTextColor,
            ),
            tabs: [
              Tab(
                child: Text(
                  "EQUALLY",
                ),
              ),
              Tab(
                child: Text(
                  "UNEQUALLY",
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            EquallyDistributedTab(
              listOfMembers: widget.listOfMembers,
              groupName: widget.groupName,
            ),
            UnequallyDistributedTab(
              listOfMembers: widget.listOfMembers,
              groupName: widget.groupName,
            ),
          ],
        ),
      ),
    );
  }
}
