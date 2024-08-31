import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split/Controller/group_database_controller.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Model/group_model.dart';
import 'package:split/Model/members_model.dart';
import 'package:split/Screens/Main/Home/GroupScreens/group_activity_tab.dart';
import 'package:split/Screens/Main/Home/GroupScreens/SettleAmount/settle_tab.dart';
import 'package:split/Screens/Main/Home/GroupScreens/AddExpenses/add_expenses_screen.dart';
import 'package:split/Screens/Main/Home/GroupScreens/group_setting_screen.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({
    super.key,
    required this.index,
  });

  final int index;

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  GroupDBController groupDB = GroupDBController();

  @override
  Widget build(BuildContext context) {
    Group groupData = Provider.of<List<Group>>(context)[widget.index];
    String groupName = groupData.name;

    return StreamBuilder<List<Member>>(
      stream: groupDB.streamMembers(groupName),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: kSecondaryColor,
                title: Text(groupName.toUpperCase()),
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
                        "ACTIVITY",
                      ),
                    ),
                    Tab(
                      child: Text("SETTLE"),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupSettingScreen(
                            groupName: groupName,
                            index: widget.index,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: kTextColor,
                    ),
                  )
                ],
              ),
              body: TabBarView(
                children: [
                  GroupActivityTab(
                    index: widget.index,
                  ),
                  SettleTab(
                    index: widget.index,
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddExpensesScreen(
                        listOfMembers: snapshot.data!,
                        groupName: groupName,
                      ),
                    ),
                  );
                },
                backgroundColor: kPrimaryLightColor,
                label: const Text("Add Expenses"),
                icon: const Icon(
                  Icons.attach_money,
                ),
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text("NO DATA")),
          );
        }
      },
    );
  }
}
