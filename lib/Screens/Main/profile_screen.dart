import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Model/user_data_model.dart';
import 'package:split/Screens/Welcome/welcome_screen.dart';
import 'package:split/Widgets/app_bar_pay_details.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);
    FirebaseAuth auth = FirebaseAuth.instance;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    userData.name.toUpperCase(),
                    style: kTitleTextStyle.copyWith(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    userData.email!,
                  ),
                  kWidgetHeightGap,
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
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  auth.signOut();
                  Navigator.pushReplacementNamed(context, WelcomeScreen.id);
                },
                child: const Text('SIGN OUT'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
