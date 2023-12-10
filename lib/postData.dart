import 'package:cloud_firestore/cloud_firestore.dart';

class PostData {
  static postUserInfotoFirebase(String name, String roomid) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('userRoom').doc();

    Map<String, dynamic> roomWithData = {
      '_id': roomid,
      'roomName': name,
      'roomId': roomid
    };
    await roomRef.set(roomWithData);
  }
}

class getData {
  static Stream<QuerySnapshot<Map<String, dynamic>>>getDataFromFirebase() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return db.collection('userRoom').snapshots();
  }
}
