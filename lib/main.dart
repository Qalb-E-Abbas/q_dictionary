import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _url = "https://owlbot.info/api/v4/dictionary/";
  String _token = "42402fea131e3ad70e1f73ea559114701ba1974c";

  TextEditingController _controller = TextEditingController();

  StreamController _streamController;
  Stream _stream;

  Timer _debounce;

  _search() async {
    if (_controller.text == null || _controller.text.length == 0) {
      _streamController.add(null);
      return;
    }

    //waiting is when we r searching so it must shows spinner etc to let us know that it is working
    _streamController.add("waiting"); //just below this is bcz it gets data from user(whatevr he types)

    Response response = await get(_url + _controller.text.trim(), headers: {"Authorization": "Token " + _token}); // this rule is specified in dic website
    _streamController.add(json.decode(response.body));
  }


  @override
  void initState() {
    super.initState();

    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Q-Dictionary", style: TextStyle(fontWeight: FontWeight.bold),),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(80.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 50.0,

                    margin: const EdgeInsets.only(top: 20.0, left: 15.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 2.0,
                          spreadRadius: 5.0,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(

                        style: TextStyle(color: Colors.black),
                        onChanged: (String text) {

                          // users type so timer is active. this is used to search for itsel insted of pressing the search icon
                          if (_debounce?.isActive ?? false) _debounce.cancel();
                          _debounce = Timer(const Duration(milliseconds: 1000), () {
                            _search();
                          });
                        },
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Search for a word",
                          hintStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0,),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 35.0,
                  ),
                  onPressed: () {
                    _search();
                  },
                )
              ],
            ),
          ),
        ),
        body: Container(
          margin: EdgeInsets.all(15.0),

          child: StreamBuilder(
            stream: _stream,
            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Center(
                  child: Text('Please, Search', style: (TextStyle(fontSize: 20.0)),),
                );
              }

              if (snapshot.data == "waiting") {
                return Center(
                  child: CircularProgressIndicator(backgroundColor: Colors.red,),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data["definitions"].length, // will gv d length of data which we want to display

                itemBuilder: (BuildContext context, int index) {
                  return ListBody(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 30.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.black,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white,
                                spreadRadius: 5.0,
                                blurRadius: 2.0,
                              )
                            ]
                        ),
                        child: ListTile(
                          // if the word we r searching for has image already in system so show
                          leading: snapshot.data["definitions"][index]["image_url"] == null ? null : CircleAvatar(
                            backgroundImage: NetworkImage(snapshot.data["definitions"][index]["image_url"]),
                          ),

                          title: Text(_controller.text.trim() + " (" + snapshot.data["definitions"][ index] ["type"] + ")", style:
                          TextStyle(color: Colors.white, fontSize: 25.0),),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(snapshot.data["definitions"][index]["definition"], style:
                        TextStyle( fontSize: 25.0),),
                      )
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
