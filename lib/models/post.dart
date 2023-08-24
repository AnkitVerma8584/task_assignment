class Post {
  final String userId,
      videoTitle,
      videoDescription,
      videoCategory,
      videoUrl,
      videoLocation;

  Post({
    required this.userId,
    required this.videoTitle,
    required this.videoDescription,
    required this.videoCategory,
    required this.videoUrl,
    required this.videoLocation,
  });

  toJson() {
    return {
      "userId": userId,
      "videoTitle": videoTitle,
      "videoDescription": videoDescription,
      "videoCategory": videoCategory,
      "videoUrl": videoUrl,
      "videoLocation": videoLocation
    };
  }

  factory Post.fromJson(Map<String, dynamic> data) {
    return Post(
        userId: data['userId'],
        videoTitle: data['videoTitle'],
        videoDescription: data['videoDescription'],
        videoCategory: data['videoCategory'],
        videoUrl: data['videoUrl'],
        videoLocation: data['videoLocation']);
  }
}
