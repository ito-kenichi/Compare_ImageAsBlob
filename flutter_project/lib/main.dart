import 'package:flutter/material.dart';
import 'dart:typed_data';
import './database_helper.dart';
import './ImageData.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final dbHelper = DatabaseHelper.instance;

  Future<List<Imagedata>> images;

  String DecoImage;
  Uint8List _bytesImage;

  Future<List<Imagedata>> fetchImageFromDatabase() async {
    try{
      images = dbHelper.getMyImage();
    }catch(e){
      print(e.toString());
      print("ERROR!");
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('FutureBuilder Demo'),
        ),
        body: Center(
            child: FutureBuilder<List<Imagedata>>(
                future: fetchImageFromDatabase(),
                builder: (context, snapshot) {

                  if (snapshot.hasData) {
                    return new Image.memory(snapshot.data[0].image);
                  } else {
                    return new Text("ERROR!");
                  }
                }
            )
        ),
    );
  }
}
