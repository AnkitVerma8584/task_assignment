import 'package:black_coffer/models/post.dart';
import 'package:black_coffer/pages/auth/login_screen.dart';
import 'package:black_coffer/pages/home/widgets/post_card.dart';
import 'package:black_coffer/pages/upload/upload_screen.dart';
import 'package:black_coffer/services/location/current_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/firestore_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user});
  final MyUser user;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: HomeContent(user: user),
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
              children: [Text("Explore"), Text("Lib")]),
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({
    super.key,
    required this.user,
  });

  final MyUser user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(children: [
        Row(
          children: [
            Text("Hello : ${user.phoneNumber}"),
            const Spacer(),
            IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                icon: const Icon(Icons.logout))
          ],
        ),
        const MyPosts()
      ]),
    );
  }
}

class MyPosts extends StatelessWidget {
  const MyPosts({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: getPostStreams(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return PostCard(post: Post.fromJson(data));
            }).toList(),
          );
        },
      ),
    );
  }
}
