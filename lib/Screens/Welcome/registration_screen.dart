import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:split/Controller/authentication_controller.dart';
import 'package:split/Controller/auth_fields_controller.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Screens/Welcome/login_screen.dart';
import 'package:split/Widgets/custom_button.dart';
import 'package:split/Widgets/custom_text_field.dart';
import 'package:split/main.dart';

final _formKey = GlobalKey<FormState>();

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  static const String id = "registration_screen";

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String? email;
  String? password;
  String? name;

  bool isVisiblePass = false;
  bool showSpinner = false;
  bool isError = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  void toggleVisibility() {
    isVisiblePass = !isVisiblePass;
  }

  void goToDecisionTree() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyApp(),
      ),
    );
  }

  void setSpinner(bool spinner) {
    setState(() {
      showSpinner = spinner;
    });
  }

  void setError(bool error) {
    setState(() {
      isError = error;
    });
  }

  String? authResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: showSpinner
            ? const SpinKitChasingDots(
                color: kSecondaryColor,
              )
            : Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "REGISTRATION",
                        textAlign: TextAlign.center,
                        style: kTitleTextStyle,
                      ),
                      kWidgetHeightGap,
                      CustomTextField(
                        onChanged: (value) {
                          name = value;
                        },
                        controller: nameController,
                        hintText: "Name",
                        validator: (nameVal) => nameVal!.length < 3
                            ? "name should be atleast 3 characters"
                            : null,
                      ),
                      kWidgetHeightGap,
                      CustomTextField(
                        onChanged: (value) {
                          email = value;
                        },
                        controller: emailController,
                        hintText: "Email ID",
                        validator: validateEmail,
                        keyBoardType: TextInputType.emailAddress,
                      ),
                      kWidgetHeightGap,
                      CustomTextField(
                        onChanged: (value) {
                          password = value;
                        },
                        controller: passwordController,
                        hintText: "Password",
                        obscureText: !isVisiblePass,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              toggleVisibility();
                            });
                          },
                          icon: Icon(
                            isVisiblePass
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: kPrimaryLightColor,
                          ),
                        ),
                        validator: (passVal) => passVal!.length < 3
                            ? "password should be atleast 3 characters"
                            : null,
                      ),
                      isError
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                authResult!,
                                style: TextStyle(
                                  color: Colors.red[200],
                                ),
                              ),
                            )
                          : const SizedBox(),
                      kWidgetHeightGap,
                      CustomButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setSpinner(true);
                            authResult = await Authentication()
                                .registerUser(email!, password!, name!);
                            if (authResult == null) {
                              setError(false);
                              goToDecisionTree();
                            } else {
                              setError(true);
                            }
                            setSpinner(false);
                          }
                        },
                        title: "Register",
                      ),
                      Row(
                        children: [
                          const Text(
                            "Already a user?",
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, LoginScreen.id);
                            },
                            style: TextButton.styleFrom(
                              overlayColor: const Color(0x00000000),
                            ),
                            child: const Text(
                              "Log in",
                              style: kDefaultTextStyle,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
