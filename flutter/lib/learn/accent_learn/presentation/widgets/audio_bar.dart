import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saera/learn/accent_learn/data/line_controller.dart';

import 'package:saera/style/color.dart';
import 'package:saera/style/font.dart';

import 'package:get/get.dart';

class AudioBar extends StatefulWidget {

  final String recordPath;
  final bool isRecording;
  final bool isAccent;

  const AudioBar({Key? key, required this.recordPath, required this.isRecording, required this.isAccent}) : super(key: key);

  @override
  State<AudioBar> createState() => _AudioBarState();
}

String formatTime(Duration duration){
  String twoDigits(int n) => n.toString().padLeft(2, '0');

  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));

  return [
    minutes,
    seconds,
  ].join(":");
}


class _AudioBarState extends State<AudioBar> {

  bool _isPlaying = false;

  AudioPlayer audioPlayer = AudioPlayer();

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  String url = '';

  final LineController _lineController = Get.find();

  @override
  void initState(){
    super.initState();

    setAudio();

    //listen to states
    audioPlayer.onPlayerStateChanged.listen((state) {
      if(this.mounted){
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // listen to audio duration
    audioPlayer.onDurationChanged.listen((newDuration) {
      if(this.mounted){
        setState(() {
          duration = newDuration;
        });
        if(widget.isRecording){
          _lineController.rsetting(newDuration.inMicroseconds.toDouble());
          _lineController.rpositionChanged(0.0);
        }
        else{
          _lineController.setting(newDuration.inMicroseconds.toDouble());
          _lineController.positionChanged(0.0);
        }
      }
    });

    //listen to audio position
    audioPlayer.onPositionChanged.listen((newPosition) {
      if(this.mounted){
        setState(() {
          position = newPosition;
          if(widget.isRecording){
            _lineController.rpositionChanged(newPosition.inMicroseconds.toDouble());
          }
          else{
            _lineController.positionChanged(newPosition.inMicroseconds.toDouble());
          }
        });
      }
    });

    audioPlayer.onPlayerComplete.listen((event) {
      if(this.mounted){
        setState(() {
          position = Duration.zero;
          if(widget.isRecording){
            _lineController.rpositionChanged(0.0);
          }
          else{
            _lineController.positionChanged(0.0);
          }
          setAudio();
        });
      }
    });

  }

  Future setAudio() async {
    if(widget.isRecording){
      audioPlayer.setSource(DeviceFileSource(widget.recordPath));
    }else{
      audioPlayer.setSource(DeviceFileSource(widget.recordPath));
    }
  }

  @override
  void dispose(){

    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 2.0, right: 16.0, top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () async {
              if(_isPlaying){
                await audioPlayer.pause();
              }
              else{
                await audioPlayer.resume();
              }
            },
            icon: _isPlaying ?
            SvgPicture.asset(
                (){
                  if(widget.isAccent){
                    return 'assets/icons/stop.svg';
                  }
                  return 'assets/icons/stop_pronounce.svg';
                }(),
                fit: BoxFit.scaleDown,
            )
                :
            SvgPicture.asset(
                  (){
                if(widget.isAccent){
                  return 'assets/icons/play.svg';
                }
                  return 'assets/icons/play_pronounce.svg';
                }(),
                fit: BoxFit.scaleDown,
            ),
            iconSize: 32,
          ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 5.0),
                child: Text(formatTime(position),
                  style: TextStyles.small66TextStyle,
                ),
              ),
              SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                    trackHeight: 5.0,
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 5.0),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 200,
                    child: Slider(
                      min: 0,
                      max: duration.inMicroseconds.toDouble(),
                      value: position.inMicroseconds.toDouble(),
                      activeColor: widget.isAccent ? ColorStyles.saeraPink.withOpacity(0.4) : ColorStyles.saeraOlive2.withOpacity(0.4),
                      inactiveColor: Color(0xffE7E7E7),
                      onChanged: (value) async {
                        final position = Duration(microseconds: value.toInt());
                        await audioPlayer.seek(position);
                        if(widget.isRecording){
                          _lineController.rpositionChanged(position.inMicroseconds.toDouble());
                        }
                        else{
                          _lineController.positionChanged(position.inMicroseconds.toDouble());
                        }
                        await audioPlayer.resume();
                      },
                    ),
                  )
              ),
              Container(
                margin: const EdgeInsets.only(left: 5.0),
                child: duration.inSeconds == 0.0 ?
                const Text("00:01",
                  style: TextStyles.small66TextStyle,
                )
                    :
                Text(formatTime(duration),
                  style: TextStyles.small66TextStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}