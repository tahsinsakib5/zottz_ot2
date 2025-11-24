import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:zottz_otone/device_scan_activity.dart';

// import 'device_scan_activity.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playWelcomeSound();
    _navigateToNextScreen();
  }

  Future<void> _playWelcomeSound() async {
    await _audioPlayer.play(AssetSource('welcome.mp3'));
  }

  void _navigateToNextScreen() {
    Future.delayed(Duration(seconds:3), () {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => DeviceScanActivity()),
      // );
    });
  } 

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
 return Scaffold(
  backgroundColor: Colors.white,
 body: Center(
    child: Lottie.asset('assets/bluetooth.json'),
  ),
);
  }
}