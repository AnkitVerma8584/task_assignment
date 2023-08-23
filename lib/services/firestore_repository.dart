import 'package:black_coffer/models/post.dart';
import 'package:black_coffer/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../util/common.dart';

final db = FirebaseFirestore.instance;

saveUser(MyUser user) async {
  final docRef = db.collection('users').doc(user.uid);
  await docRef.set(user.toJson()).then((value) => printLog("User created"),
      onError: (e) =>
          printLog("Some error in user creation : ${e.toString()}"));
}

savePost(Post post) async {
  final docRef = db.collection('posts').doc("${post.userId}_$getTimeStamp()");
  await docRef.set(post.toJson()).then((value) => printLog("Post submitted"),
      onError: (e) => printLog("Some error in post : ${e.toString()}"));
}
