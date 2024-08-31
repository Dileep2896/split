import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Model/user_data_model.dart';
import 'package:split/Screens/Main/Friends/top_navigation_bar.dart';
import 'package:split/Screens/Main/Home/home_screen.dart';
import 'package:split/Screens/Main/profile_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);

    List friendRequests = userData.friendsRequests ?? [];
    bool isFriendRequest = friendRequests.isNotEmpty;

    return Scaffold(
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15.0,
            vertical: 25,
          ),
          child: GNav(
            backgroundColor: Colors.black,
            activeColor: kTextColor,
            color: kTextColor,
            selectedIndex: currentPageIndex,
            tabBackgroundColor: kSecondaryColor,
            padding: const EdgeInsets.all(16),
            gap: 10,
            onTabChange: (value) {
              setState(() {
                currentPageIndex = value;
              });
            },
            tabs: [
              const GButton(
                icon: Icons.home,
                text: "Home",
              ),
              GButton(
                leading: isFriendRequest
                    ? const Badge(
                        backgroundColor: Colors.tealAccent,
                        child: Icon(
                          Icons.favorite,
                          color: kTextColor,
                        ),
                      )
                    : null,
                icon: Icons.favorite,
                text: "Friends",
              ),
              const GButton(
                icon: Icons.person,
                text: "Profile",
              ),
            ],
          ),
        ),
      ),
      body: [
        const HomeScreen(),
        const TopNavigationBar(),
        const ProfileScreen(),
      ][currentPageIndex],
    );
  }
}
