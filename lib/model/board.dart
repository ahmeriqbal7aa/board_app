import 'package:firebase_database/firebase_database.dart';

class Board {
  String key;
  String subject;
  String body;

  // Constructor
  Board(this.subject, this.body);
  //TODO Receiving Data
  // Get data from snapshot
  Board.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        subject = snapshot.value['subject'],
        body = snapshot.value['body'];
  //TODO Sending Data
  // A method that set the data
  toJson() {
    return {'subject': subject, 'body': body};
  }
}
