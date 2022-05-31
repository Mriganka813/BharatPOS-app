// ignore_for_file: file_names, camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, avoid_types_as_parameter_names

import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class payChat extends StatefulWidget {
  static const String routeName = '/Specific_party';
  payChat({Key? key}) : super(key: key);

  @override
  State<payChat> createState() => _payChatState();
}

class _payChatState extends State<payChat> {
  var MoneyList = [];

  TextEditingController value = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // print(i);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Amit Kumar\n+91-6000637319",
                    style: TextStyle(color: Colors.black),
                  ),
                  // const SizedBox(
                  //   width: 100,
                  // ),
                  IconButton(
                      onPressed: () {},
                      splashRadius: 20,
                      icon: const Icon(
                        Icons.more_vert,
                        size: 25,
                        color: Colors.black,
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: SingleChildScrollView(
          reverse: true,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: MoneyList.length,
            itemBuilder: (BuildContext context, int index) {
              if (MoneyList[index][0] == "Red") {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 15),
                      child: Container(
                        child: currentdate(),
                      ),
                    ),
                    ListTile(
                      trailing: Container(
                        height: 50,
                        width: 111,
                        child: Card(
                          clipBehavior: Clip.hardEdge,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black, width: 0.5),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              MoneyList[index][1],
                              style: TextStyle(color: Colors.red, fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else if (MoneyList[index][0] == "Green") {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 15),
                      child: Container(
                        child: currentdate(),
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        height: 50,
                        width: 111,
                        child: Card(
                          clipBehavior: Clip.hardEdge,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black, width: 0.5),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              MoneyList[index][1],
                              style:
                                  TextStyle(color: Colors.green, fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Text("");
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Container(
          height: 120,
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            reverse: true,
            padding: EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Balance Due",
                        textScaleFactor: 1.7,
                      ),
                      Text(
                        "500",
                        textScaleFactor: 1.7,
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 50,
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () {
                          modelOpen(context, "Green");
                        },
                        child: Text(
                          "Received",
                          style: TextStyle(
                              color: Color.fromRGBO(32, 150, 82, 100)),
                          textScaleFactor: 1.7,
                        ),
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )),
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromRGBO(148, 255, 194, 100)),
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () {
                          modelOpen(context, "Red");
                        },
                        child: Text(
                          "Given",
                          style: TextStyle(color: Colors.red),
                          textScaleFactor: 1.7,
                        ),
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )),
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromRGBO(255, 209, 209, 10)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  modelOpen(context, Key) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Enter Amount",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        controller: value,
                        decoration: InputDecoration(hintText: "₹"),
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          MoneyList.add([Key, value.text]);
                          value.clear();
                        });
                        Navigator.pop(context);
                      },
                      child: Text("Confirm"))
                ],
              ),
            ),
          );
        });
  }

  currentdate() {
    var dt = DateTime.now();
    var datereq = DateFormat.MMMM().format(dt);
    return Text(
      dt.day.toString() + " " + datereq + ", " + dt.year.toString(),
      style: TextStyle(color: Colors.black45),
    );
  }
}
