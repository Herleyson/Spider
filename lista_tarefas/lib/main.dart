import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';



void main() {


  runApp(MaterialApp(
    home: Splash(),
  ));
}



class App extends StatelessWidget {
  //making list of pages needed to pass in IntroViewsFlutter constructor.
  final pages = [
    PageViewModel(
      pageColor: Colors.redAccent,
      iconImageAssetPath: "Images/agenda.png",
      body: Text(
        'Com grandes poderes vêm grandes responsabilidades',
      ),
      title: Text('Spiderman'),
      mainImage: Image.asset(
        'Images/agenda.png',
        height: 285.0,
        width: 285.0,
        alignment: Alignment.center,
      ),
      textStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
    ),
    PageViewModel(
      pageColor: Colors.black54,
      iconImageAssetPath: "Images/agenda.png",
      body: Text(
        'Em homegagem ao grande heroi',
      ),
      title: Text('Stan Lee'),
      mainImage: Image.asset(
        'Images/stan.jpg',
        height: 800.0,
        width: 800.0,
        alignment: Alignment.center,
      ),
      textStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
    ),
  ];

  @override
  Widget build(BuildContext context) {


      return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tela de Introdução', //title of app
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ), //ThemeData
      home: Builder(
        builder: (context) => IntroViewsFlutter(
          pages,
          onTapDoneButton: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Home(),
              ), //MaterialPageRoute
            );
          },
          showSkipButton:
          true, //Whether you want to show the skip button or not.
          pageButtonTextStyles: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ), //IntroViewsFlutter
      ), //Builder
    ); //Material App
  }
}























class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {


  final dateFormat = DateFormat("dd.MM.yyyy 'as' HH:mm");
  DateTime date;

  final _toDoController = TextEditingController();
  final _dateController = TextEditingController();


  List _toDoList = [];

  List _tarefas = ["Salvar o mundo", "Estudar", "Trabalhar", "Piadas",];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentTarefa;

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();

    _dropDownMenuItems = getDropDownMenuItems();
    _currentTarefa = _dropDownMenuItems[0].value;

    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }


  void changedDropDownItem(String selectedCity) {
    setState(() {
      _currentTarefa = selectedCity;
    });
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String tarefa in _tarefas) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
      items.add(new DropdownMenuItem(
          value: tarefa,
          child: new Text(tarefa)
      ));
    }
    return items;
  }

  void _addToDo() {
    try {
      setState(() {
        Map<String, dynamic> newToDo = Map();
        newToDo["title"] =
            _toDoController.text + " " + dateFormat.format(date) + "  //" +
                _currentTarefa;
        _toDoController.text = "";
        _dateController.text = "";

        newToDo["ok"] = false;
        _toDoList.add(newToDo);

        _saveData();
      });
    } catch (e) {

    }
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _toDoList.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });

      _saveData();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Lista do Spider"),
          backgroundColor: Colors.red,
          centerTitle: true,


        ),
        body: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("Images/spider5.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child:


          Column(
            children: <Widget>[

              Container(
                padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: TextField(
                          controller: _toDoController,
                          decoration: InputDecoration(
                              labelText: "Nova Tarefa",
                              labelStyle: TextStyle(color: Colors.white)
                          ),
                          style: TextStyle(color: Colors.white),
                        )
                    ),
                    RaisedButton(
                      color: Colors.red,
                      child: Text("ADD"),
                      textColor: Colors.blue,
                      onPressed: _addToDo,
                    )
                  ],
                ),
              ), Container(
                padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),

                child: Row(
                    children: <Widget>[
                      Expanded(
                        child: DateTimePickerFormField(
                          controller: _dateController,
                          format: dateFormat,

                          decoration: InputDecoration(
                              labelText: 'Data',
                              labelStyle: TextStyle(color: Colors.white)

                          ),
                          style: TextStyle(color: Colors.white),

                          onChanged: (dt) => setState(() => date = dt),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.fromLTRB(10.0, 27.0, 7.0, 1.0),
                          child:
                          Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Colors.blue,
                            ),
                            child: DropdownButton(
                              value: _currentTarefa,
                              items: _dropDownMenuItems,


                              style: TextStyle(color: Colors.white),

                              onChanged: changedDropDownItem,

                            ),
                          )
                      )
                    ]
                ),

              ),


              Expanded(
                child: RefreshIndicator(onRefresh: _refresh,
                  child: ListView.builder(
                      padding: EdgeInsets.only(top: 10.0),
                      itemCount: _toDoList.length,
                      itemBuilder: buildItem

                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime
          .now()
          .millisecondsSinceEpoch
          .toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white,),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(
          _toDoList[index]["title"], style: TextStyle(color: Colors.white),),

        value: _toDoList[index]["ok"],

        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["ok"] ?
          Icons.check : Icons.error),),
        onChanged: (c) {
          setState(() {
            _toDoList[index]["ok"] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
            action: SnackBarAction(label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _toDoList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                }),
            duration: Duration(seconds: 2),
          );

          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);

    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

}

class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<Splash> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new Home()));
    } else {
      prefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new App()));
    }
  }

  @override
  void initState() {
    super.initState();
      checkFirstSeen();

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Text('Carregando...'),
      ),
    );
  }
}