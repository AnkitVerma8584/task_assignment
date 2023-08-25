import 'package:black_coffer/pages/auth/otp_screen.dart';
import 'package:black_coffer/util/common.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user.dart';
import '../home/home_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> isUploading = ValueNotifier(false);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onNextClicked() {
    if (_formKey.currentState!.validate()) {
      String phone = "+91${_controller.text}";
      registerUser(isUploading, phone, context);
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
                  Text(
                    "Welcome",
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 70),
                  PhoneInputField(controller: _controller),
                  const SizedBox(height: 30),
                  ValueListenableBuilder(
                      valueListenable: isUploading,
                      builder: (context, value, widget) {
                        if (value) {
                          return const Align(
                              child: CircularProgressIndicator.adaptive());
                        } else {
                          return widget!;
                        }
                      },
                      child: NextButton(onPress: onNextClicked))
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

Future<void> registerUser(ValueNotifier<bool> isUploading, String mobile,
    BuildContext context) async {
  isUploading.value = true;
  FirebaseAuth auth = FirebaseAuth.instance;
  var nav = Navigator.of(context);

  MaterialPageRoute getRoute(MyUser user) =>
      MaterialPageRoute(builder: (context) => HomeScreen(user: user));
  kIsWeb
      ? Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => OtpScreen(
                  verificationId: "verificationId", phoneNumber: mobile)))
      : auth.verifyPhoneNumber(
          phoneNumber: mobile,
          timeout: const Duration(minutes: 2),
          verificationCompleted: (authCredential) async {
            var result = await auth.signInWithCredential(authCredential);
            User? user = result.user;
            if (user != null) {
              nav.pop();
              MyUser myUser =
                  MyUser(uid: user.uid, phoneNumber: user.phoneNumber!);
              nav.push(getRoute(myUser));
            }
            isUploading.value = false;
          },
          verificationFailed: (error) {
            var snackBar = SnackBar(
              content: Text(error.toString()),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            isUploading.value = false;
          },
          codeSent: (verificationId, forceResendingToken) {
            isUploading.value = false;
            nav.pop();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => OtpScreen(
                        verificationId: verificationId, phoneNumber: mobile)));
          },
          codeAutoRetrievalTimeout: (_) {});
}
