import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:varificationtrail2/firebase_options.dart';

// import 'package:camera/camera.dart';
import 'Video.dart';
import 'loginPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth auth = FirebaseAuth.instance;

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(login());
}

class login extends StatelessWidget {
  const login({super.key});

  @override
  Widget build(BuildContext context) {
    return const verifiction();
  }
}
