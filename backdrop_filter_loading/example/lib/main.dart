import 'package:backdrop_filter_loading/backdrop_filter_loading.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 10), () {
      setState(() {
        loading = false;
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          height: 300,
          width: 250,
          child: BackdropFilterLoading(
            loading: loading,
            child: Image.network('https://picsum.photos/id/237/400/400'),
          ),
        ),
      ),
    );
  }
}
