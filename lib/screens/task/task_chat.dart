import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/task_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../../../component/custom_appbar.dart';
import '../../../component/custom_loading.dart';
import '../../../component/custom_text.dart';
import '../../../model/customer/customer_report_model.dart';
import '../../../source/constant/colors_constant.dart';
import '../../../source/constant/local_data.dart';
import '../../../source/styles/styles.dart';
import '../../../source/utilities/utils.dart';
import '../../../view_model/customer_provider.dart';
import 'package:provider/provider.dart';
import '../../component/audio_player.dart';
import '../../source/constant/api.dart';
import '../../source/constant/assets_constant.dart';

class TaskChat extends StatefulWidget {
  final String taskId;
  final String assignedId;
  final String assignedName;
  final String name;
  final bool isVisit;
  final String? createdBy;
  final String date1;
  final String date2;
  final String type;
  final int index;

  const TaskChat({
    super.key,
    required this.taskId,
    required this.assignedId,
    required this.name,
    required this.isVisit,
    this.createdBy,
    required this.assignedName,
    required this.date1,
    required this.date2,
    required this.type,
    required this.index,
  });

  @override
  State<TaskChat> createState() => _TaskChatState();
}

class _TaskChatState extends State<TaskChat>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  final AudioRecorder _audioRecorder = AudioRecorder();

  /// Recorded audio preview mattum indha player use pannum.
  /// Chat la irukkura audio ellam AudioTile handle pannum.
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isRecording = false;
  String? recordedPath;

  Duration duration = Duration.zero;
  Timer? timer;

  // Recorded audio preview state
  Duration totalDuration = Duration.zero;
  Duration currentPosition = Duration.zero;
  bool isPlaying = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final custProvider =
      Provider.of<CustomerProvider>(context, listen: false);

      custProvider.disPoint.clear();

      if (widget.isVisit == true) {
        custProvider.getComments(widget.taskId);
      } else {
        custProvider.getTaskComments(widget.taskId);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<TaskProvider>(context, listen: false).scrollToBottom();
      });
    });

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    animation =
        Tween<double>(begin: 0.5, end: 1.5).animate(animationController);

    /// Recorded preview listeners (oru thadava mattum)
    _audioPlayer.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() {
        totalDuration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() {
        currentPosition = p;
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        isPlaying = false;
        currentPosition = Duration.zero;
      });
    });

    super.initState();
  }

  Future<void> startRecording() async {
    final status = await Permission.microphone.request();

    if (status.isGranted) {
      // App temp folder (permission issue varaadhu)
      final dir = await getTemporaryDirectory();

      final String path =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      debugPrint("Recording started: $path");

      setState(() {
        isRecording = true;
        duration = Duration.zero;
      });

      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() {
          duration += const Duration(seconds: 1);
        });
      });
    } else {
      if (mounted) {
        utils.showWarningToast(
          context,
          text: "Microphone permission required",
        );
      }
    }
  }

  Future<void> stopRecording() async {
    timer?.cancel();

    // stop() complete aagura varai wait pannanum
    final path = await _audioRecorder.stop();

    if (path != null) {
      final File file = File(path);
      final bool exists = await file.exists();
      final int size = exists ? await file.length() : 0;

      debugPrint("Recorded path: $path");
      debugPrint("Recorded size: $size");

      if (!exists || size == 0) {
        setState(() {
          isRecording = false;
          recordedPath = null;
        });

        if (mounted) {
          utils.showWarningToast(
            context,
            text: "Recording failed, try again",
          );
        }
        return;
      }

      await _audioPlayer.stop();

      await _audioPlayer.setSource(
        DeviceFileSource(path),
      );

      final dur = await _audioPlayer.getDuration();

      setState(() {
        isRecording = false;
        recordedPath = path;
        duration = dur ?? Duration.zero;
        totalDuration = dur ?? Duration.zero;
        currentPosition = Duration.zero;
        isPlaying = false;
      });
    } else {
      setState(() {
        isRecording = false;
      });
    }
  }

  Future<void> togglePlayRecorded() async {
    if (recordedPath == null) return;

    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (currentPosition == Duration.zero) {
        // Mudinjirundha / start la irundhu play
        await _audioPlayer.play(DeviceFileSource(recordedPath!));
      } else {
        await _audioPlayer.resume();
      }
    }

    setState(() {});
  }

  String formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes);
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    timer?.cancel();
    animationController.dispose();
    _myFocusScopeNode.dispose();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  /// Local phone path-ah nu check
  bool _isLocalAudioPath(String s) {
    return s.startsWith('/storage/') ||
        s.startsWith('/data/') ||
        s.startsWith('/sdcard/') ||
        s.startsWith('file://');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CustomerProvider, TaskProvider>(
      builder: (context, custProvider, taskProvider, _) {
        var webWidth = MediaQuery.of(context).size.width * 0.5;
        var phoneWidth = MediaQuery.of(context).size.width * 0.9;

        return FocusScope(
          node: _myFocusScopeNode,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: const Color(0xffEAEAEA),
              appBar: PreferredSize(
                  preferredSize: const Size(300, 60),
                  child: CustomAppbar(
                    text: widget.assignedName.toString() == ""
                        ? widget.name
                        : widget.assignedName,
                  )),

              /// BOTTOM INPUT
              bottomSheet: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (recordedPath == null && isRecording == false)
                      SizedBox(
                        width: kIsWeb
                            ? webWidth / 1
                            : MediaQuery.of(context).size.width * 0.63,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          controller: custProvider.disPoint,
                          decoration: customStyle.inputDecoration(
                            text: "Type a comment",
                            fieldClr: Colors.white,
                            radius: 50,
                          ),
                        ),
                      ),
                    if (kIsWeb) 10.width,
                    if (!kIsWeb && recordedPath == null && !isRecording)
                      IconButton(
                        icon: const Icon(
                          Icons.mic,
                          color: Colors.green,
                        ),
                        onPressed: () async {
                          if (isRecording) {
                            await stopRecording();
                          } else {
                            await startRecording();
                          }
                        },
                      ),
                    if (isRecording)
                      Row(
                        children: [
                          CustomText(
                            text: taskProvider
                                .formatDuration2(duration.inSeconds),
                            colors: Colors.red,
                            isBold: true,
                          ),
                          10.width,
                          const CustomText(
                            text: "Recording...",
                          ),
                          50.width,
                        ],
                      ),

                    if (recordedPath != null && !isRecording)
                      Container(
                        height: 40,
                        width: phoneWidth / 1.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 30,
                                color: Colors.green,
                              ),
                              onPressed: togglePlayRecorded,
                            ),
                            Expanded(
                              child: Slider(
                                activeColor: Colors.green,
                                inactiveColor: Colors.grey.shade300,
                                value: currentPosition.inSeconds
                                    .toDouble()
                                    .clamp(
                                  0,
                                  totalDuration.inSeconds.toDouble() == 0
                                      ? 1
                                      : totalDuration.inSeconds.toDouble(),
                                ),
                                min: 0,
                                max: totalDuration.inSeconds.toDouble() == 0
                                    ? 1
                                    : totalDuration.inSeconds.toDouble(),
                                onChanged: (value) async {
                                  final position =
                                  Duration(seconds: value.toInt());
                                  await _audioPlayer.seek(position);

                                  setState(() {
                                    currentPosition = position;
                                  });
                                },
                              ),
                            ),
                            Text(
                              "${formatTime(currentPosition)} / "
                                  "${formatTime(totalDuration)}",
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                      ),

                    if (recordedPath != null)
                      IconButton(
                        icon: SvgPicture.asset(
                          assets.deleteValue,
                          width: 20,
                          height: 20,
                        ),
                        onPressed: () async {
                          await _audioPlayer.stop();
                          setState(() {
                            recordedPath = null;
                            totalDuration = Duration.zero;
                            currentPosition = Duration.zero;
                          });
                        },
                      ),

                    SizedBox(
                      height: 45,
                      width: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                          backgroundColor:
                          isRecording ? Colors.red : colorsConst.primary,
                          elevation: 2,
                        ),
                        onPressed: () async {
                          _myFocusScopeNode.unfocus();

                          if (isRecording) {
                            await stopRecording();
                            return;
                          }

                          if (custProvider.disPoint.text.trim().isEmpty &&
                              recordedPath == null) {
                            utils.showWarningToast(
                              context,
                              text: "Type a comment or record audio",
                            );
                            return;
                          }

                          // Preview play aagitu irundha niruthu
                          await _audioPlayer.stop();

                          debugPrint("Sending audio path: $recordedPath");

                          if (widget.isVisit == true) {
                            await custProvider.addComment(
                              context: context,
                              visitId: widget.taskId.toString(),
                              companyName: widget.name,
                              companyId: "",
                              numberList: [],
                              taskId: "0",
                              createdBy: widget.createdBy.toString(),
                              assignedId: widget.assignedId.toString(),
                              path: recordedPath ?? "",
                            );
                          } else {
                            await custProvider.tComment(
                              context: context,
                              taskId: widget.taskId.toString(),
                              assignedId: widget.assignedId.toString(),
                              path: recordedPath ?? "",
                              index: widget.index,
                            );
                          }

                          if (!mounted) return;

                          setState(() {
                            recordedPath = null;
                            totalDuration = Duration.zero;
                            currentPosition = Duration.zero;
                          });
                        },
                        child: Icon(
                          isRecording ? Icons.stop : Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// CHAT BODY
              body: custProvider.refresh == false
                  ? const Loading()
                  : custProvider.customerReport.isEmpty
                  ? const Center(
                child: CustomText(
                  text: "No Comments Found",
                  size: 15,
                ),
              )
                  : Center(
                child: SizedBox(
                  width: kIsWeb ? webWidth : phoneWidth,
                  child: ListView.builder(
                    controller: taskProvider.scrollController,
                    padding:
                    const EdgeInsets.fromLTRB(10, 10, 10, 80),
                    physics: const BouncingScrollPhysics(),
                    itemCount: custProvider.customerReport.length,
                    itemBuilder: (context, index) {
                      CustomerReportModel data =
                      custProvider.customerReport[index];

                      bool isSender = data.createdBy.toString() ==
                          localData.storage.read("id").toString();

                      String doc =
                          data.documents?.toString().trim() ?? "";

                      bool isAudio = doc.isNotEmpty &&
                          (doc.toLowerCase().endsWith(".m4a") ||
                              doc.toLowerCase().endsWith(".mp3") ||
                              doc.toLowerCase().endsWith(".wav"));

                      String audioUrl = doc;

                      // Local file (just record panni send panna) na direct path,
                      // illana server URL
                      final bool isLocalAudio =
                          data.isLocal == true ||
                              _isLocalAudioPath(audioUrl);

                      final String finalAudioUrl = isLocalAudio
                          ? audioUrl
                          : '$imageFile?path=$audioUrl';

                      return Align(
                        alignment: isSender
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: IntrinsicWidth(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                              MediaQuery.of(context).size.width *
                                  0.70,
                            ),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSender
                                    ? const Color(0xFFDCF8C6)
                                    : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12),
                                  topRight: const Radius.circular(12),
                                  bottomLeft: isSender
                                      ? const Radius.circular(12)
                                      : Radius.zero,
                                  bottomRight: isSender
                                      ? Radius.zero
                                      : const Radius.circular(12),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.08),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!isSender)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 4),
                                      child: Row(
                                        children: [
                                          Text(
                                            data.firstname.toString(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight:
                                              FontWeight.w600,
                                              color:
                                              Color(0xFF0D47A1),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "( ${data.role} )",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors
                                                  .grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  /// AUDIO UI
                                  if (isAudio)
                                    AudioTile(
                                      key: ValueKey(
                                          '${data.createdTs}_$audioUrl'),
                                      audioUrl: finalAudioUrl,
                                    )
                                  else
                                    Text(
                                      data.comments.toString(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),

                                  const SizedBox(height: 6),

                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        DateFormat('hh:mm a').format(
                                          DateTime.parse(
                                              data.createdTs
                                                  .toString()),
                                        ),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      if (data.isLocal == true)
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(
                                              left: 4),
                                          child: Icon(
                                            Icons.schedule,
                                            size: 12,
                                            color:
                                            Colors.grey.shade600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}