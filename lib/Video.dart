import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:varificationtrail2/feed.dart';

List<CameraDescription> camCount = [];
bool _isvideoSelected = false;

CameraController? controller;
List<File> allFileList = [];
List<Map<int, dynamic>> fileNames = [];

void upload(String picturesDir) async {
  // refrence
  Reference referenceroot = FirebaseStorage.instance.ref();
  Reference referenceDirImg = referenceroot.child("Images");

  Reference referencetoupload =
      referenceDirImg.child(DateTime.now().millisecondsSinceEpoch.toString());
  try {
    await referencetoupload.putFile(File(picturesDir));
    // print(referencetoupload.getDownloadURL());
  } catch (e) {
    print("Error in uploading $e");
  }
}

Future<void> saveImageToDeviceStorage(XFile imageFile) async {
  try {
    final appDir = await getApplicationDocumentsDirectory();

    final fileName = DateTime.now().toIso8601String() + '.jpg';
    final savedImage = File('${appDir.path}/$fileName');

    // final picturesDir = await getExternalStorageDirectory();
    // return savedImage.path;
    upload(savedImage.path);
    print("Image saved to: ${savedImage.path}");
  } catch (e) {
    // return "nothing";
    print("Error saving image: $e");
  }
}

// strt video
Future<void> startVideoRecording() async {
  print("Recording started");
  final CameraController? cameraController = controller;
  if (controller!.value.isRecordingVideo) {
    // A recording has already started, do nothing.
    return;
  }
  try {
    await cameraController!.startVideoRecording();
    // setState(() {
    //   _isvideoSelected = true;
    //   print(_isRecordingInProgress);
    // });
  } on CameraException catch (e) {
    print('Error starting to record video: $e');
  }
}

// stop video
Future<XFile?> stopVideoRecording() async {
  if (!controller!.value.isRecordingVideo) {
    // Recording is already is stopped state
    return null;
  }
  try {
    XFile file = await controller!.stopVideoRecording();
    // setState(() {
    //   _isRecordingInProgress = false;
    //   print(_isRecordingInProgress);
    // });
    return file;
  } on CameraException catch (e) {
    print('Error stopping video recording: $e');
    return null;
  }
}

class intiCam extends StatefulWidget {
  const intiCam({super.key});

  @override
  State<intiCam> createState() => _intiCamState();
}

class _intiCamState extends State<intiCam> {
  //variables

  bool _isRearCameraSelected = true;
  bool _cameraini = false;
  FlashMode? _currentFlashMode;
  XFile? image;

//checkingcameras
  void camcount() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      // camcount is camers
      camCount = await availableCameras();
      return onNewCameraSelected(camCount[1]);
    } on CameraException catch (e) {
      print('Error in fetching the cameras: $e');
    }
  }

//initilising camera
  void onNewCameraSelected(CameraDescription cameraDescription) async {
    _currentFlashMode = controller?.value.flashMode;
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }
    try {
      _currentFlashMode = controller!.value.flashMode;
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }
    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _cameraini = controller!.value.isInitialized;
      });
    }
  }

//taking iamges
  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController!.value.isTakingPicture) {
      return null;
    }
    try {
      final image = await cameraController.takePicture();
      upload(image.path);
      return XFile(image.path);
    } on CameraException catch (e) {
      print('Error occurred while taking picture: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("appbar"),
          ),
          bottomNavigationBar: Container(
            child: Row(children: [
              Expanded(
                child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => Feed()),
                      );
                    },
                    icon: Icon(Icons.home)),
              ),
              Expanded(
                child: IconButton(
                    onPressed: () {
                      camcount();
                    },
                    icon: Icon(Icons.camera)),
              ),
            ]),
          ),
          body: _cameraini
              ? Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.6 / controller!.value.aspectRatio,
                      child: controller!.buildPreview(),
                    ),
                    InkWell(
                      onTap: () async {
                        setState(() {
                          _cameraini = false;
                        });
                        onNewCameraSelected(
                          camCount[_isRearCameraSelected ? 1 : 0],
                        );

                        setState(() {
                          _isRearCameraSelected = !_isRearCameraSelected;
                        });
                      },
                      child: Icon(
                        Icons.flip_camera_android,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () async {
                            setState(() {
                              _currentFlashMode = FlashMode.off;
                            });
                            await controller!.setFlashMode(
                              FlashMode.off,
                            );
                          },
                          child: Icon(
                            Icons.flash_off,
                            color: _currentFlashMode == FlashMode.off
                                ? Colors.amber
                                : Colors.red,
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            setState(() {
                              _currentFlashMode = FlashMode.auto;
                            });
                            await controller!.setFlashMode(
                              FlashMode.auto,
                            );
                          },
                          child: Icon(
                            Icons.flash_auto,
                            color: _currentFlashMode == FlashMode.auto
                                ? Colors.amber
                                : Colors.red,
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            setState(() {
                              _currentFlashMode = FlashMode.torch;
                            });
                            await controller!.setFlashMode(
                              FlashMode.torch,
                            );
                          },
                          child: Icon(
                            Icons.highlight,
                            color: _currentFlashMode == FlashMode.torch
                                ? Colors.amber
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),

                    // Click trigger
                    InkWell(
                      onTap: () async {
                        XFile? rawImage = await takePicture();
                        await saveImageToDeviceStorage(rawImage!);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.circle,
                            color: _isvideoSelected ? Colors.red : Colors.black,
                            size: 80,
                          ),
                          Icon(
                            Icons.circle,
                            color: _isvideoSelected ? Colors.red : Colors.white,
                            size: 65,
                          ),
                        ],
                      ),
                    ),

                    //image or video
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              if (_isvideoSelected) {
                                setState(() {
                                  _isvideoSelected = false;
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  _isvideoSelected ? Colors.red : Colors.amber,
                            ),
                            child: Text('IMAGE'),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              if (!_isvideoSelected) {
                                setState(() {
                                  _isvideoSelected = true;
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  _isvideoSelected ? Colors.amber : Colors.red,
                            ),
                            child: Text('VIDEO'),
                          ),
                        ),
                      ],
                    )
                  ],
                )
              : Container(),
        ),
      ),
    );
  }
}
