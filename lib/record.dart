import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:permission_handler/permission_handler.dart';

class Record extends StatefulWidget {
  const Record({Key? key}) : super(key: key);

  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> {
  String statusText = "";
  bool isComplete = false;
  bool isRecord = false;
  String? recordFilePath = '';
  int i = 0;

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      statusText = "Recording...";
      recordFilePath = await getFilePath();
      isComplete = false;
      RecordMp3.instance.start(recordFilePath!, (type) {
        statusText = "Record error--->$type";
        setState(() {});
      });
    } else {
      statusText = "No microphone permission";
    }
    setState(() {});
  }

  Future stopRecord() async {
    bool s = RecordMp3.instance.stop();
    if (s) {
      statusText = "Record complete";
      isComplete = true;
      setState(() {});
    }
  }

  Future toggleRecord() async {
    if (isRecord == true) {
      await startRecord();
    } else {
      await stopRecord();
    }
  }

  Future play() async {
    if (recordFilePath != null && File(recordFilePath!).existsSync()) {
      AudioPlayer audioPlayer = AudioPlayer();
      audioPlayer.play(recordFilePath!, isLocal: true);
    }
  }

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
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
      body: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                child: Container(
                  height: 48.0,
                  decoration: BoxDecoration(color: Colors.red.shade300),
                  child: const Center(
                    child: Text(
                      'start',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                onTap: () async {
                  setState(() {
                    isRecord = true;
                  });

                  toggleRecord();
                },
              ),
            ),
            /*
              Expanded(
                child: GestureDetector(
                  child: Container(
                    height: 48.0,
                    decoration: BoxDecoration(color: Colors.blue.shade300),
                    child: Center(
                      child: Text(
                        RecordMp3.instance.status == RecordStatus.PAUSE
                            ? 'resume'
                            : 'pause',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  onTap: () {
                    pauseRecord();
                  },
                ),
              ),*/
            Expanded(
              child: GestureDetector(
                child: Container(
                  height: 48.0,
                  decoration: BoxDecoration(color: Colors.green.shade300),
                  child: const Center(
                    child: Text(
                      'stop',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    isRecord = false;
                  });
                  toggleRecord();
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            statusText,
            style: const TextStyle(color: Colors.red, fontSize: 20),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            play();
          },
          child: Container(
            margin: const EdgeInsets.only(top: 30),
            alignment: AlignmentDirectional.center,
            width: 100,
            height: 50,
            child: isComplete && recordFilePath != null
                ? const Text(
                    "play",
                    style: TextStyle(color: Colors.red, fontSize: 20),
                  )
                : Container(),
          ),
        ),
      ]),
    );
  }
/*
  Future pauseRecord() async {
    if (RecordMp3.instance.status == RecordStatus.PAUSE) {
      bool s = RecordMp3.instance.resume();
      if (s) {
        statusText = "Recording...";
        setState(() {});
      }
    } else {
      bool s = RecordMp3.instance.pause();
      if (s) {
        statusText = "Recording pause...";
        setState(() {});
      }
    }
  }

  Future resumeRecord() async {
    bool s = RecordMp3.instance.resume();
    if (s) {
      statusText = "Recording...";
      setState(() {});
    }
  }*/
}
