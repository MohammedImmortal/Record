import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:avatar_glow/avatar_glow.dart';

class Record extends StatefulWidget {
  const Record({Key? key}) : super(key: key);

  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> {
  String statusText = "";
  bool isRecording = false;
  RecordStatus _status = RecordStatus.IDEL;
  RecordStatus get status => _status;
  String? recordFilePath = '';
  int i = 0;

  Future startRecord() async {
    statusText = "Recording...";
    _status = RecordStatus.RECORDING;
    recordFilePath = await getFilePath();
    RecordMp3.instance.start(recordFilePath!, (type) {
      statusText = "Record error--->$type";
    });
  }

  Future stopRecord() async {
    if (_status == RecordStatus.RECORDING) {
      statusText = "Record Saved in $recordFilePath";
      RecordMp3.instance.stop();
      _status = RecordStatus.IDEL;
    }
  }

  Future toggleRecord() async {
    if (_status == RecordStatus.IDEL) {
      isRecording = true;
      await startRecord();
    } else {
      isRecording = false;
      await stopRecord();
    }
  }

  Future playRecord() async {
    if (recordFilePath != null &&
        _status == RecordStatus.IDEL &&
        File(recordFilePath!).existsSync()) {
      statusText = 'Playing Record';
      AudioPlayer audioPlayer = AudioPlayer();
      audioPlayer.play(recordFilePath!, isLocal: true);
    }
  }

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    final directory = Directory(sdPath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return sdPath + "/test_${i++}.mp3";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Example App'),
          centerTitle: true,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AvatarGlow(
          animate: isRecording,
          glowColor: Theme.of(context).primaryColor,
          endRadius: 80.0,
          duration: const Duration(milliseconds: 1500),
          repeatPauseDuration: const Duration(milliseconds: 100),
          repeat: true,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {});
              toggleRecord();
            },
            child: Icon(isRecording ? Icons.stop : Icons.mic),
          ),
        ),
        body: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  elevation: MaterialStateProperty.all(5),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                ),
                child: const Text("Play"),
                onPressed: () async {
                  setState(() {});
                  playRecord();
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Text(
                  statusText,
                  style: const TextStyle(color: Colors.red, fontSize: 20),
                ),
              ),
            ],
          ),
        ));
  }
}
