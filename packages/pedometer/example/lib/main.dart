import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pedometer/pedometer.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;

  Duration duration = Duration();
  late Timer timer;
  late TextEditingController textEditingController;

  String _status = '?', _steps = '?', _cals = '?';
  int countSec = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
      _cals = (calculateCals(int.parse(_steps), 175)) as String;
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
      /*if (_status == 'walking') {
        stopTimer();
      }*/
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    stopTimer();
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    stopTimer();
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timerCountUp));
  }

  void timerCountUp(_) {
    setState(() {
      final seconds = duration.inSeconds + 1;
      duration = Duration(seconds: seconds);
    });
  }

  void stopTimer() {
    duration = Duration();
    setState(() {
      timer.cancel();
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
    startTimer();

    if (!mounted) return;
  }

  double calculateCals(int _steps, int weight) {
    // return (0.045 * _steps); <-- Calculate calories burnt without weight & height involved
    double M = 0.1 * ((_steps / 1312.3359801) / duration.inSeconds) +
        3.5; // Calculate the walking metabolic average
    return 5 *
        duration.inSeconds *
        ((M * weight) /
            1000); // Calculate the total burn of calories using metabolic avg
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pedometer example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Steps taken:',
                style: TextStyle(fontSize: 30),
              ),
              Text(
                _steps,
                style: TextStyle(fontSize: 60),
              ),
              Divider(
                height: 100,
                thickness: 0,
                color: Colors.white,
              ),
              TextField(
                controller: textEditingController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Your Weight',
                ),
              ),
              Divider(
                height: 100,
                thickness: 0,
                color: Colors.white,
              ),
              Text(
                'Pedestrian status:',
                style: TextStyle(fontSize: 30),
              ),
              Icon(
                _status == 'walking'
                    ? Icons.directions_walk
                    : _status == 'stopped'
                        ? Icons.accessibility_new
                        : Icons.error,
                size: 100,
              ),
              Center(
                child: Text(
                  _status,
                  style: _status == 'walking' || _status == 'stopped'
                      ? TextStyle(fontSize: 30)
                      : TextStyle(fontSize: 20, color: Colors.red),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
