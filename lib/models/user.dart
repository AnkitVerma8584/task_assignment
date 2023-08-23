class MyUser {
  final String uid;
  final String phoneNumber;

  MyUser({required this.uid, required this.phoneNumber});

  toJson() {
    return {"uid": uid, "phoneNumber": phoneNumber};
  }
}
