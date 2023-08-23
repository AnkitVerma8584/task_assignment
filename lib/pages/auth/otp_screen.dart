import 'package:black_coffer/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import '../../models/user.dart';
import '../../services/user_repository.dart';
import '../../util/common.dart';
import '../home/home_screen.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key, required this.verificationId});
  final String verificationId;

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
                    height: getHeight(context) * 0.4,
                  ),
                ),
              ),
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
            ],
          ),
        ),
      ),
    );
  }
}
