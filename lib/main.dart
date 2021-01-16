import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:board_app/model/board.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePaeState createState() => _HomePaeState();
}

class _HomePaeState extends State<HomePage> {
  // here we create a list that save board result/messages
  List<Board> boardMessages = List();
  // here we made a board object to access its functions
  Board board;
  // here we made database object to set and get data
  final FirebaseDatabase db = FirebaseDatabase.instance;
  // here we made a "formKey" to validate and fetch Board_Form using key easily
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DatabaseReference databaseReference;
  @override
  //TODO initState Method
  void initState() {
    super.initState();
    board = Board("", "");
    databaseReference = db.reference().child('board_app');
    databaseReference.onChildAdded.listen(_onEntryAdded);
    databaseReference.onChildChanged.listen(_onEntryChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Board App'),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 0,
            child: Center(
              child: Form(
                key: formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: [
                    ListTile(
                      leading: Icon(Icons.subject),
                      title: TextFormField(
                        initialValue: "",
                        onSaved: (val) => board.subject = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.message),
                      title: TextFormField(
                        initialValue: "",
                        onSaved: (val) => board.body = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    FlatButton(
                      onPressed: () => handleSubmit(),
                      child: Text('Post'),
                      color: Colors.blue,
                    )
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            child: FirebaseAnimatedList(
              query: databaseReference,
              // here "_" underscore mean "context"
              itemBuilder: (_, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                    ),
                    title: Text(boardMessages[index].subject),
                    subtitle: Text(boardMessages[index].body),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  //TODO CallBack Methods in initState
  void _onEntryAdded(Event event) {
    setState(() {
      boardMessages.add(Board.fromSnapshot(event.snapshot));
    });
  }

  void _onEntryChanged(Event event) {
    var oldEntry = boardMessages.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    // setState method is use to update/send data again to the snapshot
    setState(() {
      boardMessages[boardMessages.indexOf(oldEntry)] =
          Board.fromSnapshot(event.snapshot);
    });
  }

  // TODO FlatButton onPressed's Method
  void handleSubmit() {
    final FormState form = formKey.currentState;
    // validate() is a bool type function
    if (form.validate()) {
      form.save();
      form.reset();
      // Save form's data to database
      databaseReference.push().set(board.toJson());
    }
  }
}
