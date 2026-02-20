import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/styles/decoration.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../screens/common/fullscreen_photo.dart';
import '../source/constant/api.dart';
import '../source/utilities/utils.dart';
import 'custom_loading.dart';

class AudioTile extends StatefulWidget {
  final String audioUrl;
  const AudioTile({super.key, required this.audioUrl});

  @override
  State<AudioTile> createState() => _AudioTileState();
}

class GlobalAudioPlayer {
  static final AudioPlayer _player = AudioPlayer();
  static AudioPlayer get player => _player;
}


// class _AudioTileState extends State<AudioTile> {
//   static _AudioTileState? currentlyPlayingTile;
//
//   final AudioPlayer _player = GlobalAudioPlayer.player;
//   bool _isPlaying = false;
//   bool _isLoading = false;
//
//   @override
//   void dispose() {
//     if (currentlyPlayingTile == this) {
//       currentlyPlayingTile = null;
//     }
//     super.dispose();
//   }
//
//   void _togglePlayPause() async {
//     if (_isPlaying) {
//       await _player.pause();
//       setState(() {
//         _isPlaying = false;
//         currentlyPlayingTile = null;
//       });
//     } else {
//       setState(() {
//         _isLoading = true;
//       });
//
//       // Stop previously playing tile
//       if (currentlyPlayingTile != null && currentlyPlayingTile != this) {
//         await _player.stop();
//         currentlyPlayingTile!._setNotPlaying();
//       }
//
//       try {
//         await _player.play(UrlSource(widget.audioUrl));
//         setState(() {
//           _isPlaying = true;
//           currentlyPlayingTile = this;
//         });
//
//         _player.onPlayerComplete.listen((event) {
//           if (mounted) {
//             setState(() {
//               _isPlaying = false;
//               currentlyPlayingTile = null;
//             });
//           }
//         });
//       } catch (e) {
//         debugPrint("Audio play error: $e");
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     }
//   }
//
//   void _setNotPlaying() {
//     if (mounted) {
//       setState(() {
//         _isPlaying = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: customDecoration.baseBackgroundDecoration(
//         color: Colors.white,
//         radius: 10,
//         borderColor: colorsConst.litGrey,
//       ),
//       padding: const EdgeInsets.all(8),
//       child: InkWell(
//         onTap: _togglePlayPause,
//         child: _isLoading
//             ? const Loading()
//             : Icon(
//           _isPlaying ? Icons.pause : Icons.play_arrow_outlined,
//           color: _isPlaying ? colorsConst.greyClr : colorsConst.primary,
//           size: 30,
//         ),
//       ),
//     );
//   }
// }
///
// class _AudioTileState extends State<AudioTile> {
//   static _AudioTileState? currentlyPlayingTile;
//
//   final AudioPlayer _player = GlobalAudioPlayer.player;
//
//   bool _isPlaying = false;
//   bool _isLoading = false;
//
//   Duration _duration = Duration.zero;
//   Duration _position = Duration.zero;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _player.onDurationChanged.listen((d) {
//       if (mounted) setState(() => _duration = d);
//     });
//
//     _player.onPositionChanged.listen((p) {
//       if (mounted) setState(() => _position = p);
//     });
//
//     _player.onPlayerComplete.listen((event) {
//       if (mounted) {
//         setState(() {
//           _isPlaying = false;
//           _position = Duration.zero;
//           currentlyPlayingTile = null;
//         });
//       }
//     });
//   }
//
//   String formatTime(Duration d) {
//     String two(int n) => n.toString().padLeft(2, '0');
//     return "${two(d.inMinutes)}:${two(d.inSeconds % 60)}";
//   }
//
//   void _togglePlayPause() async {
//     if (_isPlaying) {
//       await _player.pause();
//       setState(() => _isPlaying = false);
//       currentlyPlayingTile = null;
//     } else {
//       setState(() => _isLoading = true);
//
//       if (currentlyPlayingTile != null && currentlyPlayingTile != this) {
//         await _player.stop();
//         currentlyPlayingTile!._setNotPlaying();
//       }
//
//       await _player.play(UrlSource(widget.audioUrl));
//
//       setState(() {
//         _isPlaying = true;
//         currentlyPlayingTile = this;
//         _isLoading = false;
//       });
//     }
//   }
//
//   void _setNotPlaying() {
//     if (mounted) setState(() => _isPlaying = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         // play button
//         InkWell(
//           onTap: _togglePlayPause,
//           child: _isLoading
//               ? Padding(
//                 padding: const EdgeInsets.all(5.0),
//                 child: CircularProgressIndicator(strokeWidth: 2,),
//               )
//               : Icon(
//             _isPlaying ? Icons.pause : Icons.play_arrow,
//             size: 32,
//           ),
//         ),
//         // progress animation
//         Container(
//           width: 100,
//           child: Slider(
//             value: _position.inSeconds.toDouble(),
//             max: _duration.inSeconds.toDouble() == 0
//                 ? 1
//                 : _duration.inSeconds.toDouble(),
//             onChanged: (value) async {
//               final pos = Duration(seconds: value.toInt());
//               await _player.seek(pos);
//             },
//           ),
//         ),
//
//         // seconds text
//         Text(
//           formatTime(_position),
//           style: TextStyle(fontSize: 12),
//         )
//       ],
//     );
//   }
// }
///

// class _AudioTileState extends State<AudioTile> {
//   static _AudioTileState? currentlyPlayingTile;
//
//   final AudioPlayer _player = GlobalAudioPlayer.player;
//
//   bool _isPlaying = false;
//   bool _isLoading = false;
//   bool _isAudioLoaded = false;
//
//   Duration _duration = Duration.zero;
//   Duration _position = Duration.zero;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _loadAudio(); // 👈 duration first load
//
//     _player.onDurationChanged.listen((d) {
//       if (mounted) setState(() => _duration = d);
//     });
//
//     _player.onPositionChanged.listen((p) {
//       if (mounted) setState(() => _position = p);
//     });
//
//     _player.onPlayerComplete.listen((event) {
//       if (mounted) {
//         setState(() {
//           _isPlaying = false;
//           _position = Duration.zero;
//           currentlyPlayingTile = null;
//         });
//       }
//     });
//   }
//
//   /// ✅ Load audio first → get duration
//   Future<void> _loadAudio() async {
//     try {
//       setState(() => _isLoading = true);
//
//       await _player.setSourceUrl(widget.audioUrl);
//
//       final d = await _player.getDuration();
//       if (d != null && mounted) {
//         _duration = d;
//       }
//
//       if (mounted) {
//         setState(() {
//           _isAudioLoaded = true;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       print("Audio load error: $e");
//     }
//   }
//
//   /// time format (mm:ss)
//   String formatTime(Duration d) {
//     String two(int n) => n.toString().padLeft(2, '0');
//     return "${two(d.inMinutes)}:${two(d.inSeconds % 60)}";
//   }
//
//   /// play / pause
//   void _togglePlayPause() async {
//     if (_isPlaying) {
//       await _player.pause();
//       setState(() => _isPlaying = false);
//       currentlyPlayingTile = null;
//     } else {
//       setState(() => _isLoading = true);
//
//       /// stop other tile
//       if (currentlyPlayingTile != null && currentlyPlayingTile != this) {
//         await _player.stop();
//         currentlyPlayingTile!._setNotPlaying();
//       }
//
//       /// always reload audio before play (IMPORTANT FIX)
//       await _player.setSourceUrl(widget.audioUrl);
//
//       await _player.resume();
//
//       setState(() {
//         _isPlaying = true;
//         _isLoading = false;
//         currentlyPlayingTile = this;
//       });
//     }
//   }
//   void _setNotPlaying() {
//     if (mounted) setState(() => _isPlaying = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         /// ▶ play button
//         InkWell(
//           onTap: _togglePlayPause,
//           child: _isLoading
//               ? const Padding(
//             padding: EdgeInsets.all(5),
//             child: SizedBox(
//               height: 20,
//               width: 20,
//               child: CircularProgressIndicator(strokeWidth: 2),
//             ),
//           )
//               : Icon(
//             _isPlaying ? Icons.pause : Icons.play_arrow,
//             size: 32,
//           ),
//         ),
//
//         /// slider
//         SizedBox(
//           width: 100,
//           child: Slider(
//             value: _position.inSeconds.toDouble(),
//             max: _duration.inSeconds == 0
//                 ? 1
//                 : _duration.inSeconds.toDouble(),
//             onChanged: (value) async {
//               final pos = Duration(seconds: value.toInt());
//               await _player.seek(pos);
//             },
//           ),
//         ),
//
//         /// seconds text
//         Text(
//           _isPlaying
//               ? formatTime(_position) // playing time
//               : formatTime(_duration), // total duration first
//           style: const TextStyle(fontSize: 12),
//         ),
//       ],
//     );
//   }
// }
///



class _AudioTileState extends State<AudioTile> {
  /// only one tile play at a time
  static _AudioTileState? currentlyPlayingTile;

  late AudioPlayer _player;

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isAudioLoaded = false;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();

    /// each tile own player (IMPORTANT)
    _player = AudioPlayer();

    /// listeners
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _player.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
          currentlyPlayingTile = null;
        });
      }
    });

    /// load audio → get duration first
    _loadAudio();
  }

  /// load audio and fetch duration
  Future<void> _loadAudio() async {
    try {
      setState(() => _isLoading = true);

      await _player.setSourceUrl(widget.audioUrl);

      final d = await _player.getDuration();
      if (d != null) _duration = d;

      if (mounted) {
        setState(() {
          _isAudioLoaded = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Audio load error: $e");
    }
  }

  /// mm:ss format
  String formatTime(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes)}:${two(d.inSeconds % 60)}";
  }

  /// play / pause
  void _togglePlayPause() async {
    if (!_isAudioLoaded) return;

    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
      currentlyPlayingTile = null;
    } else {
      setState(() => _isLoading = true);

      /// stop other playing tile
      if (currentlyPlayingTile != null && currentlyPlayingTile != this) {
        await currentlyPlayingTile!._player.stop();
        currentlyPlayingTile!._setNotPlaying();
      }

      /// reload source before play (important)
      await _player.setSourceUrl(widget.audioUrl);
      await _player.resume();

      setState(() {
        _isPlaying = true;
        _isLoading = false;
        currentlyPlayingTile = this;
      });
    }
  }

  void _setNotPlaying() {
    if (mounted) setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    _player.dispose(); // very important
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// ▶ play button
        InkWell(
          onTap: _togglePlayPause,
          child: _isLoading
              ? const Padding(
            padding: EdgeInsets.all(5),
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
              : Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            size: 32,
          ),
        ),
        /// progress slider
        SizedBox(
          width: 100,
          child: Slider(
            value: _position.inSeconds
                .clamp(0, _duration.inSeconds)
                .toDouble(),
            max: _duration.inSeconds == 0
                ? 1
                : _duration.inSeconds.toDouble(),
            onChanged: (value) async {
              final pos = Duration(seconds: value.toInt());
              await _player.seek(pos);
            },
          ),
        ),
        /// time text
        Text(
          _isPlaying
              ? formatTime(_position) // running time
              : formatTime(_duration), // total duration first
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class ShowNetWrKImg extends StatefulWidget {
  final String img;
  const ShowNetWrKImg({super.key, required this.img});

  @override
  State<ShowNetWrKImg> createState() => _ShowNetWrKImgState();
}

class _ShowNetWrKImgState extends State<ShowNetWrKImg> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        utils.navigatePage(context, ()=>FullScreen(image: widget.img, isNetwork: true));
      },
      child: CachedNetworkImage(
          imageUrl: '$imageFile?path=${widget.img}',
          fit: BoxFit.cover,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error,color: colorsConst.litGrey,size: 20,),
          placeholder: (context, url) => const Loading(size: 10,)),
    );
  }
}
