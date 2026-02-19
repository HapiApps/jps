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

// class _AudioTileState extends State<AudioTile> {
//   final AudioPlayer _player = AudioPlayer();
//   bool _isPlaying = false;
//   bool _isLoading = false;
//
//   @override
//   void dispose() {
//     _player.dispose();
//     super.dispose();
//   }
//
//   void _togglePlayPause() async {
//     if (_isPlaying) {
//       await _player.pause();
//       setState(() {
//         _isPlaying = false;
//       });
//     } else {
//       setState(() {
//         _isLoading = true;
//       });
//
//       try {
//         await _player.play(UrlSource(widget.audioUrl));
//         setState(() {
//           _isPlaying = true;
//         });
//       } catch (e) {
//         debugPrint("Audio play error: $e");
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//
//       _player.onPlayerComplete.listen((event) {
//         setState(() {
//           _isPlaying = false;
//         });
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
class GlobalAudioPlayer {
  static final AudioPlayer _player = AudioPlayer();
  static AudioPlayer get player => _player;
}


class _AudioTileState extends State<AudioTile> {
  static _AudioTileState? currentlyPlayingTile;

  final AudioPlayer _player = GlobalAudioPlayer.player;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void dispose() {
    if (currentlyPlayingTile == this) {
      currentlyPlayingTile = null;
    }
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() {
        _isPlaying = false;
        currentlyPlayingTile = null;
      });
    } else {
      setState(() {
        _isLoading = true;
      });

      // Stop previously playing tile
      if (currentlyPlayingTile != null && currentlyPlayingTile != this) {
        await _player.stop();
        currentlyPlayingTile!._setNotPlaying();
      }

      try {
        await _player.play(UrlSource(widget.audioUrl));
        setState(() {
          _isPlaying = true;
          currentlyPlayingTile = this;
        });

        _player.onPlayerComplete.listen((event) {
          if (mounted) {
            setState(() {
              _isPlaying = false;
              currentlyPlayingTile = null;
            });
          }
        });
      } catch (e) {
        debugPrint("Audio play error: $e");
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _setNotPlaying() {
    if (mounted) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: customDecoration.baseBackgroundDecoration(
        color: Colors.white,
        radius: 10,
        borderColor: colorsConst.litGrey,
      ),
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: _togglePlayPause,
        child: _isLoading
            ? const Loading()
            : Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow_outlined,
          color: _isPlaying ? colorsConst.greyClr : colorsConst.primary,
          size: 30,
        ),
      ),
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
