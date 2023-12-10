import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_project/postData.dart';
import 'package:webrtc_project/screens/checkRoom.dart';
import 'package:webrtc_project/screens/signal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("WebRTC Project"),
        actions: [
          IconButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const CheckRoom(),
                  ),
                );
              },
              icon: const Icon(Icons.person))
        ],
      ),
      body: Column(
        children: [
         const  SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  signaling.openUserMedia(_localRenderer, _remoteRenderer);
                },
                child: const Text("Open camera & microphone"),
              ),
             const  SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () async {
                  var res = await showPopOut(h, w);
                  print(res);
                  if (res !='') {
                    roomId = await signaling.createRoom(_remoteRenderer);
                    textEditingController.text = roomId!;
                    await PostData.postUserInfotoFirebase(res,roomId!);
                    setState(() {});
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("No room created"),
                      duration: Duration(seconds: 1),
                    ));
                  }
                },
                child: const Text("Create room"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Add roomId
                  print(textEditingController.text.trim());
                  signaling.joinRoom(
                    textEditingController.text.trim(),
                    _remoteRenderer,
                  );
                },
                child: const Text("Join room"),
              ),
              const SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  signaling.hangUp(_localRenderer);
                  setState(() {
                    textEditingController.clear();
                  });
                },
                child:const  Text("Hangup"),
              )
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white)),
                      height: h * 0.5,
                      width: w * 0.47,
                      child: RTCVideoView(_localRenderer, mirror: true)),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white)),
                      height: h * 0.5,
                      width: w * 0.47,
                      child: RTCVideoView(_remoteRenderer)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const   Text(
                  "Room ID:   ",
                  style: TextStyle(color: Colors.white),
                ),
                Flexible(
                  child: TextFormField(
                    style:const  TextStyle(color: Colors.white),
                    controller: textEditingController,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8)
        ],
      ),
    );
  }

  Future<dynamic> showPopOut(var height, var width) async {
    String userInput = '';
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              insetPadding: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: DecoratedBox(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4D4D4D),
                      width: 1,
                    ),
                    color: Colors.white),
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24.0, horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Create a unique name for your room\n so that others can see it.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: width * 0.8,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                   const  BorderRadius.all(Radius.circular(10.0)),
                                border: Border.all(color: Colors.white)),
                            child: TextFormField(
                              onChanged: (value) {
                                userInput = value;
                              },
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(10.0),
                                hintText: 'Type Your Rooms Name ',
                                border: InputBorder.none,
                              ),

                              // validator: (value) {
                              //   if (value?.toLowerCase() == 'delete') {
                              //     return 'Please type "delete" to confirm';
                              //   }
                              //   return null;
                              // },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height * 0.04,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                if (userInput.isNotEmpty || userInput != '') {
                                  Navigator.pop(context, userInput);
                                }
                              },
                              child:const Text(
                                'Create Room',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ));
        });
  }
}
