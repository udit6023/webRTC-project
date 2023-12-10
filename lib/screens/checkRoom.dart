import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webrtc_project/postData.dart';

class CheckRoom extends StatefulWidget {
  const CheckRoom({super.key});

  @override
  State<CheckRoom> createState() => _CheckRoomState();
}

class _CheckRoomState extends State<CheckRoom> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Room"),
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: getData.getDataFromFirebase(),
            builder: (
              BuildContext context,
              AsyncSnapshot snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }
              if (snapshot.hasError) {
                return const Text("Something went wrong");
              }

              final data = snapshot.data?.docs;
              // print('${jsonEncode(data[0].data())}');
              

              if (data.isNotEmpty) {
                return ListView.builder(
                    reverse: false,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                  leading: Text(data[index]['roomName'],style: TextStyle(fontSize: 18),),
                  title: Text(data[index]['roomId']),
                  trailing: GestureDetector(
                      onLongPress: () {
                        Clipboard.setData(new ClipboardData(text: data[index]['roomId']))
                            .then((value) => {});
                      },
                      child: Icon(Icons.copy)),
                );
                    });
              } else {
                return const Center(
                    child: Text(
                  "No Room created Yet!! 👀",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ));
              }
            },
          ),
        
        ],
      ),
    );
  }
}
