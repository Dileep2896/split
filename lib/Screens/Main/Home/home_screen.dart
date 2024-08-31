import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:split/Controller/date_converter.dart';
import 'package:split/Controller/group_database_controller.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Model/friend_data_model.dart';
import 'package:split/Model/group_model.dart';
import 'package:split/Model/members_model.dart';
import 'package:split/Model/user_data_model.dart';
import 'package:split/Screens/Main/Home/GroupScreens/create_group_screen.dart';
import 'package:split/Screens/Main/Home/GroupScreens/group_screen.dart';
import 'package:split/Widgets/app_bar_pay_details.dart';
import 'package:split/Widgets/group_amount_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String id = "home_screen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);
    User currentUser = Provider.of<User>(context);
    Provider.of<List<Group>>(context);
    Provider.of<List<FriendDataModel>>(context);

    GroupDBController db = GroupDBController();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Hello, ${userData.name.split(" ")[0].toUpperCase()}",
                  style: const TextStyle(
                    color: kTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    AppBarPayDetail(
                      payTitle: "PAY: ",
                      payAmount: "\$${userData.debitAmount}",
                      payAmountColor: Colors.black,
                      textColor: kTextColor,
                    ),
                    AppBarPayDetail(
                      payTitle: "RECEIVE: ",
                      payAmount: "\$${userData.creditAmount}",
                      payAmountColor: kPrimaryLightColor,
                      textColor: Colors.white70,
                    ),
                  ],
                )
              ],
            ),
            StreamBuilder<List<Group>>(
              stream: db.streamGroups(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Waiting for the connection to be established
                  return const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpinKitChasingDots(
                          color: kSecondaryColor,
                        ),
                        kWidgetHeightGap,
                        Text(
                          'Loading Data...',
                          style: TextStyle(
                            color: kTextColor,
                          ),
                        )
                      ],
                    ),
                  );
                } else if (snapshot.connectionState == ConnectionState.active ||
                    snapshot.connectionState == ConnectionState.done) {
                  // Connection active or stream has finished
                  if (snapshot.hasError) {
                    // Stream encountered an error
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    // Stream is connected and data is available
                    return Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          Group group = snapshot.data![index];
                          int accentColorIndex = index % accentColors.length;
                          return StreamBuilder<Member>(
                            stream: db.streamUserMember(
                              group.name,
                              currentUser.uid,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Card(
                                  elevation: 8.0,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 6.0,
                                  ),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: kSecondaryColor,
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                        vertical: 10.0,
                                      ),
                                      leading: Container(
                                        padding:
                                            const EdgeInsets.only(right: 12.0),
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            right: BorderSide(
                                              width: 1.0,
                                              color: Colors.white24,
                                            ),
                                          ),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: accentColors[
                                                  accentColorIndex],
                                              width: 3,
                                            ),
                                          ),
                                          child: Text(
                                            group.name[0],
                                            style: TextStyle(
                                              color: accentColors[
                                                  accentColorIndex],
                                              fontSize: 30,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        group.name.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20,
                                        ),
                                      ),
                                      subtitle: Column(
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.group,
                                                size: 16,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                group.noOfMembers.toString(),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              Text(
                                                "Created: ${formatDateTime(group.createdOn)}",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              snapshot.data!.totalPay != 0.0
                                                  ? GroupAmountText(
                                                      amount: snapshot
                                                          .data!.totalPay
                                                          .toString(),
                                                      backgroundColor:
                                                          Colors.black54,
                                                      textColor: kTextColor,
                                                      icon: Icons
                                                          .arrow_upward_rounded,
                                                    )
                                                  : const SizedBox(),
                                              snapshot.data!.totalReceive != 0.0
                                                  ? GroupAmountText(
                                                      amount: snapshot
                                                          .data!.totalReceive
                                                          .toString(),
                                                      backgroundColor:
                                                          kPrimaryLightColor,
                                                      textColor: Colors.white70,
                                                      icon: Icons
                                                          .arrow_downward_rounded,
                                                    )
                                                  : const SizedBox(),
                                              const Expanded(
                                                child: SizedBox(),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      trailing: const Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Colors.white,
                                        size: 30.0,
                                      ),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => GroupScreen(
                                              index: index,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          );
                        },
                      ),
                    );
                  }
                }
                return const Expanded(
                  child: Center(
                    child: Text(
                      "NO GROUPS DATA",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateGroupScreen(
                userData: userData,
                fbCurrUser: currentUser,
                db: db,
              ),
            ),
          );
        },
        backgroundColor: kPrimaryLightColor,
        label:
            const Text('Create Group', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
