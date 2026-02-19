class AddAudioModel {
  String audioPath;
  String time;
  double second;
  bool play;
  Duration position;
  Duration duration;

  AddAudioModel({
    required this.audioPath,
    required this.second,
    required this.time,
    this.play = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  factory AddAudioModel.fromJson(Map<String, dynamic> json) => AddAudioModel(
    time: json["time"],
    audioPath: json["audioPath"],
    second: json["second"],
    play: json["play"],
    position: Duration.zero,
    duration: Duration.zero,
  );

  Map<String, dynamic> toJson() => {
    "time": time,
    "audioPath": audioPath,
    "second": second,
    "play": play,
  };
}
