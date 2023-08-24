import 'dart:developer';
import 'package:black_coffer/pages/auth/otp_screen.dart';
import 'package:black_coffer/util/common.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user.dart';
import '../home/home_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onNextClicked() {
    if (_formKey.currentState!.validate()) {
      String phone = "+91${_controller.text}";
      registerUser(phone, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Hero(
                      tag: "logo",
                      child: Image.asset(
                        getAppLogo(context),
                        height: getHeight(context) * 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Welcome",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  PhoneInputField(controller: _controller),
                  const SizedBox(height: 30),
                  NextButton(onPress: onNextClicked),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required TextEditingController controller,
  }) : _controller = controller;

  final TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: 10,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.phone,
      controller: _controller,
      autofocus: true,
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          label: Text("Mobile Number"),
          hintText: "Enter your mobile number",
          prefix: Text("+91 ")),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Required*";
        }
        if (value.length < 10 || int.tryParse(value) == null) {
          return "Invalid phone number";
        }
        return null;
      },
    );
  }
}

class NextButton extends StatelessWidget {
  const NextButton({
    super.key,
    required this.onPress,
  });

  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8)),
        child: TextButton(
            onPressed: onPress,
            child: Text(
              "Next",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary),
            )));
  }
}

Future<void> registerUser(String mobile, BuildContext context) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  var nav = Navigator.of(context);

  MaterialPageRoute getRoute(MyUser user) =>
      MaterialPageRoute(builder: (context) => HomeScreen(user: user));
  kIsWeb
      ? auth.signInWithPhoneNumber(mobile)
      : auth.verifyPhoneNumber(
          phoneNumber: mobile,
          timeout: const Duration(minutes: 2),
          verificationCompleted: (authCredential) async {
            log("LIB: auth done");
            var result = await auth.signInWithCredential(authCredential);
            User? user = result.user;
            if (user != null) {
              nav.pop();
              MyUser myUser =
                  MyUser(uid: user.uid, phoneNumber: user.phoneNumber!);
              nav.push(getRoute(myUser));
            } else {
              log("LIB: Error");
            }
          },
          verificationFailed: (error) {
            log("LIB:${error.toString()}");
          },
          codeSent: (verificationId, forceResendingToken) {
            log("LIB: CODE SEND $verificationId");
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => OtpScreen(verificationId: verificationId)));
          },
          codeAutoRetrievalTimeout: (s) {
            log("LIB: CODE AUTO : $s");
          });
}
