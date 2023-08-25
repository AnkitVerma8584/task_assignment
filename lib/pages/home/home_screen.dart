import 'package:black_coffer/models/post.dart';
import 'package:black_coffer/pages/auth/login_screen.dart';
import 'package:black_coffer/pages/home/widgets/post_card.dart';
import 'package:black_coffer/pages/upload/upload_screen.dart';
import 'package:black_coffer/services/location/current_location.dart';
import 'package:black_coffer/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user.dart';
import '../../services/firestore_repository.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key, required this.user});
  final MyUser user;
  final ValueNotifier<int> index = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Hello ${user.phoneNumber},",
            style: GoogleFonts.dmSerifText(),
            textScaleFactor: 0.8,
          ),
          actions: [
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
        body: const HomeContent(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            child: const Icon(Icons.add),
            onPressed: () async {
              var address = await getCurrentLocation();
              if (address.isEmpty) {
                var snackBar = const SnackBar(
                  showCloseIcon: true,
                  content: Text("Failed to fetch location. Try again."),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            UploadScreen(location: address, user: user)));
              }
            }),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          clipBehavior: Clip.antiAlias,
          child: ValueListenableBuilder(
            valueListenable: index,
            builder: ((context, isSelected, child) {
              return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                        onPressed: () {
                          index.value = 0;
                        },
                        child: Text("Explore",
                            style: GoogleFonts.poppins(
                                fontWeight: isSelected == 0
                                    ? FontWeight.w800
                                    : FontWeight.w200,
                                color: isSelected == 0
                                    ? Colors.blue
                                    : getColors(context).primary))),
                    const SizedBox(width: 10),
                    TextButton(
                        onPressed: () {
                          index.value = 1;
                        },
                        child: Text("Library",
                            style: GoogleFonts.poppins(
                                fontWeight: isSelected == 1
                                    ? FontWeight.w800
                                    : FontWeight.w200,
                                color: isSelected == 1
                                    ? Colors.blue
                                    : getColors(context).primary)))
                  ]);
            }),
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _controller = TextEditingController();
  List<Post> posts = [];
  final List<Post> allPosts = [];

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void filterSearchResults(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        posts = allPosts;
      } else {
        posts = allPosts
            .where((item) =>
                item.videoTitle.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            keyboardType: TextInputType.text,
            onChanged: (value) => filterSearchResults(value),
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Search for any video title...",
                prefixIcon: Icon(CupertinoIcons.search, size: 16)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getPostStreams(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }
                var newPosts = snapshot.data!.docs.reversed
                    .map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  return Post.fromJson(data);
                }).toList();

                if (newPosts.isEmpty) {
                  return const Center(child: Text("No posts available"));
                }
                allPosts.clear();
                allPosts.addAll(newPosts);
                if (_controller.text.trim().isEmpty) {
                  posts = allPosts;
                } else {
                  posts = allPosts
                      .where((item) => item.videoTitle
                          .toLowerCase()
                          .contains(_controller.text.toLowerCase()))
                      .toList();
                }
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) => PostCard(post: posts[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
