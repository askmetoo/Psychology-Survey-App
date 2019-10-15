import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application/Http.dart';
import 'Config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// TODO : Make the surveys their own buttons instead of just listing them.

class Survey_List extends StatefulWidget {
  final Config config;

  String surveyName;
  String surveyDescription;
  String surveyVersion;

  Survey_List({
    this.surveyName,
    this.surveyDescription,
    this.surveyVersion,
    Key key,
    @required this.config
  }) : super (key: key);
  @override
  _SurveyListState createState() => _SurveyListState();
}

class _SurveyListState extends State<Survey_List> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Surveys"),
      ),
      body: new Container(
        child: new FutureBuilder (
          future: getSurveys(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return new ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  print(snapshot.data[index].surveyName);
                  return new ListTile(
                    title: new Text(snapshot.data[index].surveyName)
                  );
                },
              );
            }
            else{
              return new Container(
                child: new Center(
                  child: new Text("Loading...")
                )
              );
            }
          },
        ),
      ),
    );
  }
}
