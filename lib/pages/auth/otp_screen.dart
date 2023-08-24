import 'package:black_coffer/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import '../../models/user.dart';
import '../../services/firestore_repository.dart';
import '../../util/common.dart';
import '../home/home_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class OtpScreen extends StatelessWidget {
  const OtpScreen(
      {super.key, required this.verificationId, required this.phoneNumber});
  final String verificationId, phoneNumber;

  MaterialPageRoute getRoute(MyUser user) =>
      MaterialPageRoute(builder: (context) => HomeScreen(user: user));

  Future verify(String sms, BuildContext context) async {
    AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: sms);
    FirebaseAuth auth = FirebaseAuth.instance;
    var result = await auth.signInWithCredential(credential);
    User? user = result.user;
    if (user != null) {
      MyUser myUser = MyUser(uid: user.uid, phoneNumber: user.phoneNumber!);
      saveUser(myUser);
      Navigator.pop(context);
      Navigator.push(context, getRoute(myUser));
    } else {
      printLog("Error user null");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "An otp has been sent to your mobile number : $phoneNumber",
                  style: GoogleFonts.poppins(),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              OTPTextField(
                length: 6,
                width: MediaQuery.of(context).size.width,
                fieldWidth: 50,
                otpFieldStyle: OtpFieldStyle(
                  borderColor: getColors(context).primary,
                  focusBorderColor: getColors(context).primary,
                  enabledBorderColor: getColors(context).secondary,
                ),
                style: const TextStyle(fontSize: 16),
                textFieldAlignment: MainAxisAlignment.center,
                spaceBetween: 5,
                fieldStyle: FieldStyle.box,
                onCompleted: (pin) async {
                  await verify(pin, context);
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Spacer(),
                  const Text("Did not receive otp yet?"),
                  GestureDetector(
                    onTap: () {
                      registerUser(phoneNumber, context);
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 16),
                      child: Text("Resend"),
                    ),
                  ),
                  const Spacer(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> registerUser(String mobile, BuildContext context) async {
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
          },
          verificationFailed: (error) {
            var snackBar = SnackBar(
              content: Text(error.toString()),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          codeSent: (verificationId, forceResendingToken) {
            const snackBar = SnackBar(
              content: Text('An otp has been sent'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          codeAutoRetrievalTimeout: (_) {});
}
