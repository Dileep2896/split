import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Model/user_data_model.dart';
import 'package:split/Screens/Main/Friends/friends_list_screen.dart';
import 'package:split/Screens/Main/Friends/friends_request_screen.dart';

class TopNavigationBar extends StatelessWidget {
  const TopNavigationBar({super.key});

  static const String id = "top_navigation_bar";

  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);

    List friends = userData.friendsRequests ?? [];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kSecondaryColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          shadowColor: kPrimaryColor,
          title: const Text(
            "FRIENDS",
            style: kTitleTextStyle,
          ),
          bottom: TabBar(
            dividerColor: kPrimaryColor,
            indicatorColor: kPrimaryLightColor,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              color: kTextColor,
            ),
            tabs: [
              const Tab(
                child: Text(
                  "Friend List",
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Friend Request",
                    ),
                    SizedBox(
                      width: friends.isEmpty ? 0 : 10,
                    ),
                    friends.isEmpty
                        ? const SizedBox()
                        : CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.greenAccent,
                            child: Text(
                              friends.length.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                          )
                  ],
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FriendsListScreen(),
            FriendsRequestScreen(),
          ],
        ),
      ),
    );
  }
}
