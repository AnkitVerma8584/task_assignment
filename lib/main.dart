import 'package:black_coffer/models/user.dart';
import 'package:black_coffer/pages/auth/login_screen.dart';
import 'package:black_coffer/pages/home/home_screen.dart';
import 'package:black_coffer/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) {
      runApp(const MyApp());
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  MyUser? getUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return MyUser(uid: "uid", phoneNumber: "User");
    return MyUser(uid: user.uid, phoneNumber: user.phoneNumber!);
  }

  @override
  Widget build(BuildContext context) {
    MyUser? user = getUser();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Assignment',
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: user == null ? const LoginScreen() : HomeScreen(user: user),
    );
  }
}
