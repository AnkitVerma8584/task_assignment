class Post {
  final String userId, videoTitle, videoDescription, videoUrl, videoLocation;

  Post({
    required this.userId,
    required this.videoTitle,
    required this.videoDescription,
    required this.videoUrl,
    required this.videoLocation,
  });

  toJson() {
    return {
      "userId": userId,
      "videoTitle": videoTitle,
      "videoDescription": videoDescription,
      "videoUrl": videoUrl,
      "videoLocation": videoLocation
    };
  }
}
