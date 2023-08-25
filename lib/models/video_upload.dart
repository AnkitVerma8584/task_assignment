class VideoUploadState {
  final String message;
  final double progress;
  final String videoPath;
  final bool isError, isSuccess, isIdle, isUploading;
  VideoUploadState({
    required this.message,
    required this.progress,
    required this.videoPath,
    required this.isIdle,
    required this.isError,
    required this.isSuccess,
    required this.isUploading,
  });
}

var idleState = VideoUploadState(
  message: "No video selected",
  videoPath: "",
  progress: 0.0,
  isIdle: true,
  isError: false,
  isSuccess: false,
  isUploading: false,
);

uploadState(String message, double progress, String videoPath) =>
    VideoUploadState(
      message: message,
      videoPath: videoPath,
      progress: progress,
      isIdle: false,
      isError: false,
      isSuccess: false,
      isUploading: true,
    );

successState(String videoPath) => VideoUploadState(
      message: "Post uploaded successfully",
      videoPath: videoPath,
      progress: 100.0,
      isIdle: false,
      isError: false,
      isSuccess: true,
      isUploading: false,
    );

errorState(String videoPath, String error) => VideoUploadState(
      message: error,
      videoPath: videoPath,
      progress: 0.0,
      isIdle: false,
      isError: true,
      isSuccess: false,
      isUploading: false,
    );
