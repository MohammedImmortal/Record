import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:record_mp3/record_mp3.dart';

class Record extends StatefulWidget {
  const Record({Key? key}) : super(key: key);

  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> {
  String statusText = "";
  bool isRecord = false;
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
      setState(() {});
    });
  }

  Future stopRecord() async {
    if (_status == RecordStatus.RECORDING) {
      statusText = "Record Saved in $recordFilePath";
      RecordMp3.instance.stop();
      _status = RecordStatus.IDEL;
      setState(() {});
    }
  }

/*
  Future toggleRecord() async {
    if (isRecord == true) {
      await stopRecord();
    } else {
      await startRecord();
    }
  }
*/

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
                      'Start',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                onTap: () async {
                  setState(() {});
                  startRecord();
                },
              ),
            ),
            Expanded(
              child: GestureDetector(
                child: Container(
                  height: 48.0,
                  decoration: BoxDecoration(color: Colors.blue.shade300),
                  child: const Center(
                    child: Text(
                      'Play',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                onTap: () async {
                  setState(() {});
                  playRecord();
                },
              ),
            ),
            Expanded(
              child: GestureDetector(
                child: Container(
                  height: 48.0,
                  decoration: BoxDecoration(color: Colors.green.shade300),
                  child: const Center(
                    child: Text(
                      'Stop',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {});
                  stopRecord();
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Text(
            statusText,
            style: const TextStyle(color: Colors.red, fontSize: 20),
          ),
        ),
      ]),
    );
  }
}
