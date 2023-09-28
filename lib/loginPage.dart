import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:varificationtrail2/Video.dart';

class verifiction extends StatefulWidget {
  const verifiction({super.key});

  @override
  State<verifiction> createState() => _verifictionState();
}

class _verifictionState extends State<verifiction> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: homepage());
  }
}

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  String verificationIdRecived = "";
  bool otpcodeVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("verification"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 100,
            child: Image.asset('assets/Logo.jpeg'),
          ),
          Container(
            child: TextField(
              controller: phoneController,
              decoration:
                  const InputDecoration(labelText: "Enter Mobile number"),
              keyboardType: TextInputType.number,
            ),
          ),
          Visibility(
            visible: otpcodeVisible,
            child: TextField(
              controller: otpController,
              decoration: const InputDecoration(labelText: "OTP"),
              keyboardType: TextInputType.number,
            ),
          ),
          TextButton(
            onPressed: () {
              if (otpcodeVisible) {
                verifyotp();
              } else {
                verifyNumber();
              }
            },
            child: Text(otpcodeVisible ? "login" : "verify"),
          ),
        ],
      ),
    );
  }

  void verifyNumber() {
    auth.verifyPhoneNumber(
      phoneNumber: '+91${phoneController.text}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth
            .signInWithCredential(credential)
            .then((value) => {print("success")});
      },
      verificationFailed: (FirebaseAuthException exeception) {
        print(exeception.message);
      },
      codeSent: (String verificationId, int? forceResendingToken) {
        verificationIdRecived = verificationId;
        otpcodeVisible = true;
        setState(() {});
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void verifyotp() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationIdRecived, smsCode: otpController.text);
    await auth.signInWithCredential(credential).then((value) {
      Navigator.push(
          context, MaterialPageRoute(builder: ((context) => const intiCam())));
    });
  }
}
