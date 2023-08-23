import 'package:black_coffer/pages/auth/login_screen.dart';
import 'package:black_coffer/pages/upload/upload_screen.dart';
import 'package:black_coffer/services/location/current_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user});
  final MyUser user;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            Row(
              children: [
                Text("Hello user : ${user.phoneNumber}"),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                    },
                    icon: const Icon(Icons.logout))
              ],
            )
          ]),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            child: const Icon(Icons.add),
            onPressed: () async {
              var address = await getCurrentLocation();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          UploadScreen(location: address, user: user)));
            }),
        bottomNavigationBar: const BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 10,
          clipBehavior: Clip.antiAlias,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [Text("Explore"), Text("Library")]),
        ),
      ),
    );
  }
}
