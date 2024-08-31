import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split/Controller/user_database_controller.dart';
import 'package:split/Controller/group_database_controller.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Model/friend_data_model.dart';
import 'package:split/Model/group_model.dart';
import 'package:split/Model/user_data_model.dart';
import 'package:split/Screens/Welcome/login_screen.dart';
import 'package:split/Screens/Welcome/registration_screen.dart';
import 'package:split/Screens/Welcome/welcome_screen.dart';
import 'package:split/Screens/decision_tree.dart';
import 'package:split/Screens/Main/Home/home_screen.dart';
import 'package:split/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>(
          create: (context) => FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        StreamProvider<UserData>(
          create: (context) {
            var user = Provider.of<User?>(context, listen: false);
            if (user != null) {
              return UserDBController().getUserData(user.uid);
            }
            return Stream.value(UserData(name: "Unknown"));
          },
          initialData: UserData(name: "Unknown"),
        ),
        StreamProvider<List<FriendDataModel>>(
          create: (context) {
            var user = Provider.of<User?>(context, listen: false)?.uid;
            if (user != null) {
              return UserDBController().streamUsers(user);
            }
            return Stream.value([]);
          },
          initialData: const [],
        ),
        StreamProvider<List<Group>>(
          create: (context) {
            var user = Provider.of<User?>(context, listen: false)?.uid;
            if (user != null) {
              return GroupDBController().streamGroups(user);
            }
            return Stream.value([]);
          },
          initialData: const [], // Ensures the UI has an initial empty list to work with
          catchError: (context, error) {
            debugPrint("Error in StreamProvider: $error");
            return [];
          },
        ),
      ],
      child: MaterialApp(
        title: 'SPLIT',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(
          useMaterial3: true,
        ).copyWith(
          scaffoldBackgroundColor: kPrimaryColor,
        ),
        initialRoute: DecisionTree.id,
        routes: {
          DecisionTree.id: (context) => const DecisionTree(),
          WelcomeScreen.id: (context) => const WelcomeScreen(),
          LoginScreen.id: (context) => const LoginScreen(),
          RegistrationScreen.id: (context) => const RegistrationScreen(),
          HomeScreen.id: (context) => const HomeScreen(),
        },
      ),
    );
  }
}
