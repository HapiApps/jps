import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/task_provider.dart';
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

import '../../source/constant/api.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/styles/decoration.dart';

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
  });

  @override
  State<TaskChat> createState() => _TaskChatState();
}

class _TaskChatState extends State<TaskChat> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isRecording = false;
  String? recordedPath;

  Duration duration = Duration.zero;
  Timer? timer;

  // 🔥 Player state for recorded audio preview
  Duration totalDuration = Duration.zero;
  Duration currentPosition = Duration.zero;
  bool isPlaying = false;

  // 🔥 currently playing chat audio
  String? playingUrl;
  Duration networkTotal = Duration.zero;
  Duration networkCurrent = Duration.zero;
  bool networkPlaying = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final custProvider = Provider.of<CustomerProvider>(context, listen: false);

      custProvider.disPoint.clear();

      if (widget.isVisit == true) {
        await custProvider.getComments(widget.taskId);
      } else {
        await custProvider.getTaskComments(widget.taskId);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<TaskProvider>(context, listen: false).scrollToBottom();
      });
    });

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    animation = Tween<double>(begin: 0.5, end: 1.5).animate(animationController);

    /// 🔥 Duration Fix (Recorded Preview)
    _audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        totalDuration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        currentPosition = p;
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    /// 🔥 Duration Fix (Network Audio inside Chat)
    _audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        networkTotal = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        networkCurrent = p;
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        networkPlaying = state == PlayerState.playing;
      });
    });

    super.initState();
  }

  Future<void> startRecording() async {
    final status = await Permission.microphone.request();

    if (status.isGranted) {
      String path =
          '/storage/emulated/0/Download/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(),
        path: path,
      );

      setState(() {
        isRecording = true;
        duration = Duration.zero;
      });

      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          duration += const Duration(seconds: 1);
        });
      });
    } else {
      print("Permission denied");
    }
  }

  Future<void> stopRecording() async {
    timer?.cancel();

    final path = await _audioRecorder.stop();
    print("Recorded Path: $path");

    if (path != null) {
      setState(() {
        isRecording = false;
        recordedPath = path;
        currentPosition = Duration.zero;
        totalDuration = Duration.zero;
      });

      // 🔥 duration fetch fix
      await _audioPlayer.setSource(DeviceFileSource(path));
      await _audioPlayer.resume();
      await Future.delayed(const Duration(milliseconds: 200));
      await _audioPlayer.pause();
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
      await _audioPlayer.play(DeviceFileSource(recordedPath!));
    }
  }

  Future<void> playNetworkAudio(String url) async {
    try {
      if (playingUrl == url && networkPlaying) {
        await _audioPlayer.pause();
        return;
      }

      playingUrl = url;
      networkCurrent = Duration.zero;
      networkTotal = Duration.zero;

      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      print("Audio play error => $e");
    }
  }

  String formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes);
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    animationController.dispose();
    _myFocusScopeNode.dispose();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
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
            child: WillPopScope(
              onWillPop: () async {
                Navigator.pop(context, true);
                return false;
              },
              child: Scaffold(
                backgroundColor: const Color(0xffEAEAEA),
                appBar: PreferredSize(
                  preferredSize: const Size(300, 60),
                  child: localData.storage.read("role").toString() == "1"
                      ? CustomAppbar(
                    callback: () {
                      Navigator.pop(context, true);
                    },
                    text: widget.assignedName.toString(),
                  )
                      : CustomAppbar(
                    text: widget.name.toString(),
                    callback: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ),

                /// 🔥 BOTTOM INPUT
                bottomSheet: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (recordedPath == null && isRecording == false)
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.63,
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

                      IconButton(
                        icon: Icon(
                          isRecording ? Icons.stop : Icons.mic,
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
                        Text(
                          "${duration.inSeconds}s Recording...",
                          style: const TextStyle(color: Colors.red),
                        ),

                      if (recordedPath != null && !isRecording)
                        Container(
                          height: 40,
                          width: phoneWidth / 2,
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
                                  value: currentPosition.inSeconds.toDouble(),
                                  min: 0,
                                  max: totalDuration.inSeconds.toDouble() == 0
                                      ? 1
                                      : totalDuration.inSeconds.toDouble(),
                                  onChanged: (value) async {
                                    final position =
                                    Duration(seconds: value.toInt());
                                    await _audioPlayer.seek(position);
                                  },
                                ),
                              ),

                              Text(
                                formatTime(currentPosition),
                                style: const TextStyle(fontSize: 12),
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
                          onPressed: () {
                            setState(() {
                              recordedPath = null;
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
                            backgroundColor: colorsConst.primary,
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
                              );
                            }

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

                /// 🔥 CHAT BODY
                body: custProvider.refresh == false
                    ? const Loading()
                    : custProvider.customerReport.isEmpty
                    ? const Center(
                  child: CustomText(
                    text: "No Comments Found",
                    size: 15,
                  ),
                )
                    : ListView.builder(
                  controller: taskProvider.scrollController,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
                  physics: const BouncingScrollPhysics(),
                  itemCount: custProvider.customerReport.length,
                  itemBuilder: (context, index) {
                    CustomerReportModel data =
                    custProvider.customerReport[index];

                    bool isSender = data.createdBy.toString() ==
                        localData.storage.read("id").toString();

                    bool isAudio = data.documents != null &&
                        data.documents.toString().isNotEmpty &&
                        data.documents.toString().endsWith(".m4a");

                    String audioUrl =
                        "$imageFile?path=${data.documents}";

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
                                horizontal: 12, vertical: 10),
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
                                  color:
                                  Colors.black.withOpacity(0.08),
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
                                            color: Color(0xFF0D47A1),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          "( ${data.role} )",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color:
                                            Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                /// 🔥 AUDIO MESSAGE UI
                                if (isAudio)
                                  Container(
                                    height: 45,
                                    width: 240,
                                    padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            (playingUrl == audioUrl &&
                                                networkPlaying)
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.green,
                                          ),
                                          onPressed: () {
                                            playNetworkAudio(
                                                audioUrl.toString());
                                          },
                                        ),
                                        Expanded(
                                          child: Slider(
                                            activeColor: Colors.green,
                                            inactiveColor: Colors
                                                .grey.shade300,
                                            value: (playingUrl ==
                                                audioUrl &&
                                                networkTotal
                                                    .inSeconds >
                                                    0)
                                                ? networkCurrent
                                                .inSeconds
                                                .toDouble()
                                                .clamp(
                                                0,
                                                networkTotal
                                                    .inSeconds
                                                    .toDouble())
                                                : 0,
                                            min: 0,
                                            max: (playingUrl ==
                                                audioUrl &&
                                                networkTotal
                                                    .inSeconds >
                                                    0)
                                                ? networkTotal
                                                .inSeconds
                                                .toDouble()
                                                : 1,
                                            onChanged: (value) async {
                                              if (playingUrl ==
                                                  audioUrl) {
                                                await _audioPlayer.seek(
                                                    Duration(
                                                        seconds: value
                                                            .toInt()));
                                              }
                                            },
                                          ),
                                        ),
                                        Text(
                                          (playingUrl == audioUrl)
                                              ? formatTime(
                                              networkCurrent)
                                              : "00:00",
                                          style: const TextStyle(
                                              fontSize: 11),
                                        ),
                                        const SizedBox(width: 5),
                                      ],
                                    ),
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
                                          DateTime.parse(data.createdTs
                                              .toString())),
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
        );
      },
    );
  }
}