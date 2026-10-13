import 'dart:io';

import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/styles/decoration.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../screens/common/fullscreen_photo.dart';
import '../screens/common/pdf_view.dart';
import '../source/constant/api.dart';
import '../source/utilities/utils.dart';
import 'custom_loading.dart';

class AudioTile extends StatefulWidget {
  final String audioUrl;

  const AudioTile({
    super.key,
    required this.audioUrl,
  });

  @override
  State<AudioTile> createState() => _AudioTileState();
}

class _AudioTileState extends State<AudioTile> {
  static _AudioTileState? currentlyPlayingTile;

  late final AudioPlayer _player;

  bool _isPlaying = false;
  bool _isLoading = false;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  String? _localAudioPath;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();

    _player.onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() {
        _duration = duration;
      });
    });

    _player.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() {
        _position = position;
      });
    });

    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;

      if (state == PlayerState.playing) {
        setState(() {
          _isPlaying = true;
          _isLoading = false;
        });
      } else if (state == PlayerState.paused) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
        });
      } else if (state == PlayerState.stopped ||
          state == PlayerState.completed) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
          _position = Duration.zero;
        });

        if (currentlyPlayingTile == this) {
          currentlyPlayingTile = null;
        }
      }
    });
  }

  String formatTime(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  /// Local phone path-ah nu check pannum
  bool _isLocalPath(String s) {
    return s.startsWith('/storage/') ||
        s.startsWith('/data/') ||
        s.startsWith('/sdcard/') ||
        s.startsWith('file://');
  }

  /// Content-type la irundhu extension kandupidikkum
  String _extensionFor(http.Response response) {
    final type = (response.headers['content-type'] ?? '').toLowerCase();
    if (type.contains('mpeg') || type.contains('mp3')) return 'mp3';
    if (type.contains('wav')) return 'wav';
    if (type.contains('aac')) return 'aac';
    if (type.contains('ogg')) return 'ogg';
    if (type.contains('webm')) return 'webm';
    return 'm4a';
  }

  /// Server la file ready aagala na retry pannum
  Future<http.Response> _getWithRetry(Uri uri) async {
    http.Response? last;

    for (int i = 0; i < 4; i++) {
      try {
        final res = await http.get(
          uri,
          headers: {
            'Accept': 'audio/*,*/*',
            // Token venum na inga add pannunga:
            // 'Authorization': 'Bearer $token',
          },
        );

        last = res;

        debugPrint("Audio download try ${i + 1}: status ${res.statusCode}, "
            "type ${res.headers['content-type']}, bytes ${res.bodyBytes.length}");

        if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
          return res;
        }
      } catch (e) {
        debugPrint("Audio download try ${i + 1} error: $e");
      }

      await Future.delayed(const Duration(seconds: 1));
    }

    throw Exception(
      'Audio not available. Last status: ${last?.statusCode}',
    );
  }

  Future<String> _resolveAudioPath() async {
    String raw = widget.audioUrl.trim();

    // 1) URL ullaye local path irundha (…get_files.php?path=/storage/...)
    if (raw.contains('path=/storage/') || raw.contains('path=/data/')) {
      raw = raw.split('path=').last;
    }

    // 2) Local file na direct-ah play
    if (_isLocalPath(raw)) {
      final String localPath =
      raw.startsWith('file://') ? raw.replaceFirst('file://', '') : raw;

      final File localFile = File(localPath);

      if (await localFile.exists() && await localFile.length() > 0) {
        debugPrint("Playing local file: $localPath");
        return localPath;
      }

      throw Exception('Local audio file not found: $localPath');
    }

    // 3) Already download pannirundha reuse
    if (_localAudioPath != null) {
      final file = File(_localAudioPath!);
      if (await file.exists()) {
        return _localAudioPath!;
      }
    }

    // 4) Server la irundhu download
    final Directory tempDir = await getTemporaryDirectory();
    final Uri uri = Uri.parse(raw);

    debugPrint("Downloading audio: $raw");

    final response = await _getWithRetry(uri);

    final String ext = _extensionFor(response);

    final String filePath =
        '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.$ext';

    final File file = File(filePath);

    await file.writeAsBytes(response.bodyBytes, flush: true);

    final int fileSize = await file.length();

    if (fileSize == 0) {
      throw Exception('Saved audio file is empty');
    }

    _localAudioPath = filePath;

    debugPrint("Audio saved: $filePath ($fileSize bytes)");

    return filePath;
  }

  Future<void> _togglePlayPause() async {
    if (_isLoading) return;

    try {
      if (_isPlaying) {
        await _player.pause();

        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
        return;
      }

      // Already load aagi paused la irundha resume mattum
      if (_player.state == PlayerState.paused) {
        await _player.resume();
        currentlyPlayingTile = this;
        return;
      }

      if (currentlyPlayingTile != null && currentlyPlayingTile != this) {
        await currentlyPlayingTile!._stopPlayer();
      }

      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      debugPrint("Audio URL: ${widget.audioUrl}");

      final String localPath = await _resolveAudioPath();

      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.play(DeviceFileSource(localPath));

      currentlyPlayingTile = this;

      if (mounted) {
        setState(() {
          _isPlaying = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Audio play error: $e");

      currentlyPlayingTile = null;

      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
          _position = Duration.zero;
        });

        utils.showErrorToast(
          context: context,
        );
      }
    }
  }

  Future<void> _stopPlayer() async {
    try {
      await _player.stop();

      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
          _position = Duration.zero;
        });
      }
    } catch (e) {
      debugPrint("Audio stop error: $e");
    }
  }

  @override
  void dispose() {
    if (currentlyPlayingTile == this) {
      currentlyPlayingTile = null;
    }

    _player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int maxSeconds = _duration.inSeconds;

    final double currentSeconds = _position.inSeconds
        .clamp(
      0,
      maxSeconds > 0 ? maxSeconds : 1,
    )
        .toDouble();

    return Row(
      children: [
        InkWell(
          onTap: _togglePlayPause,
          child: _isLoading
              ? const Padding(
            padding: EdgeInsets.all(5),
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          )
              : Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            size: 32,
            color: colorsConst.primary,
          ),
        ),
        SizedBox(
          width: 100,
          child: Slider(
            value: currentSeconds,
            max: maxSeconds > 0 ? maxSeconds.toDouble() : 1,
            onChanged: _duration == Duration.zero
                ? null
                : (value) async {
              final Duration position = Duration(
                seconds: value.toInt(),
              );

              await _player.seek(position);
            },
          ),
        ),
        Text(
          _isPlaying ? formatTime(_position) : formatTime(_duration),
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class ShowNetWrKImg extends StatefulWidget {
  final String img;

  const ShowNetWrKImg({
    super.key,
    required this.img,
  });

  @override
  State<ShowNetWrKImg> createState() => _ShowNetWrKImgState();
}

class _ShowNetWrKImgState extends State<ShowNetWrKImg> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        utils.navigatePage(
          context,
              () => FullScreen(
            image: widget.img,
            isNetwork: true,
          ),
        );
      },
      child: CachedNetworkImage(
        imageUrl: '$imageFile?path=${widget.img}',
        fit: BoxFit.cover,
        imageBuilder: (
            context,
            imageProvider,
            ) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
        errorWidget: (
            context,
            url,
            error,
            ) {
          return Icon(
            Icons.error,
            color: colorsConst.litGrey,
            size: 20,
          );
        },
        placeholder: (
            context,
            url,
            ) {
          return const Loading(
            size: 10,
          );
        },
      ),
    );
  }
}

class ShowNetWrKPdf extends StatefulWidget {
  final String img;

  const ShowNetWrKPdf({
    super.key,
    required this.img,
  });

  @override
  State<ShowNetWrKPdf> createState() => _ShowNetWrKPdfState();
}

class _ShowNetWrKPdfState extends State<ShowNetWrKPdf> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewPage(
              pdfPath: '$imageFile?path=${widget.img}',
            ),
          ),
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: customDecoration.baseBackgroundDecoration(
          color: Colors.white,
          borderColor: Colors.grey.shade200,
          radius: 10,
        ),
        child: Icon(
          Icons.picture_as_pdf_outlined,
          color: colorsConst.primary,
          size: 30,
        ),
      ),
    );
  }
}