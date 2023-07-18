import 'package:noise_meter/noise_meter.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class NoiseMeterUi extends StatefulWidget {
  const NoiseMeterUi({super.key});

  @override
  _NoiseMeterUiState createState() => _NoiseMeterUiState();
}

class _NoiseMeterUiState extends State<NoiseMeterUi> {
  bool _isRecording = false;
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? _noiseMeter;

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter(onError);
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    super.dispose();
  }

  void onData(NoiseReading noiseReading) {
    setState(() {
      _latestReading = noiseReading;
      if (!_isRecording) _isRecording = true;
    });
  }

  void onError(Object error) {
    print(error);
    _isRecording = false;
  }

  void start() {
    try {
      _noiseSubscription = _noiseMeter?.noise.listen(onData);
    } catch (err) {
      print(err);
    }
  }

  void stop() {
    try {
      _noiseSubscription?.cancel();
      setState(() {
        _isRecording = false;
      });
    } catch (err) {
      print(err);
    }
  }

  List<Widget> getContent() => <Widget>[
        Container(
            margin: const EdgeInsets.all(25),
            child: Column(children: [
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: Text(_isRecording ? "Mic: ON" : "Mic: OFF",
                    style: const TextStyle(fontSize: 25, color: Colors.blue)),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: Text(
                  'Noise: ${_latestReading?.meanDecibel} dB',
                ),
              ),
              Container(
                child: Text(
                  'Max: ${_latestReading?.maxDecibel} dB',
                ),
              )
            ])),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noise'),
      ),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: getContent())),
      floatingActionButton: FloatingActionButton(
          backgroundColor: _isRecording ? Colors.red : Colors.green,
          onPressed: _isRecording ? stop : start,
          child: _isRecording ? const Icon(Icons.stop) : const Icon(Icons.mic)),
    );
  }
}
