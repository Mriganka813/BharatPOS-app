import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PayChat extends StatefulWidget {
  static const String routeName = '/Specific_party';
  const PayChat({Key? key}) : super(key: key);

  @override
  State<PayChat> createState() => _PayChatState();
}

class _PayChatState extends State<PayChat> {
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
                  const Text(
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
            physics: const BouncingScrollPhysics(),
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
                      trailing: SizedBox(
                        height: 50,
                        width: 111,
                        child: Card(
                          clipBehavior: Clip.hardEdge,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Colors.black, width: 0.5),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              MoneyList[index][1],
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 20),
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
                      leading: SizedBox(
                        height: 50,
                        width: 111,
                        child: Card(
                          clipBehavior: Clip.hardEdge,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Colors.black, width: 0.5),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              MoneyList[index][1],
                              style: const TextStyle(
                                  color: Colors.green, fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const Text("");
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Container(
          height: 120,
          width: double.maxFinite,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            reverse: true,
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
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
                    SizedBox(
                      height: 50,
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () {
                          modelOpen(context, "Green");
                        },
                        child: const Text(
                          "Received",
                          style: TextStyle(
                              color: Color.fromRGBO(32, 150, 82, 100)),
                          textScaleFactor: 1.7,
                        ),
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )),
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromRGBO(148, 255, 194, 100)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () {
                          modelOpen(context, "Red");
                        },
                        child: const Text(
                          "Given",
                          style: TextStyle(color: Colors.red),
                          textScaleFactor: 1.7,
                        ),
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )),
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromRGBO(255, 209, 209, 10)),
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
                  const Text("Enter Amount",
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
                        decoration: const InputDecoration(hintText: "₹"),
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
                      child: const Text("Confirm"))
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
      style: const TextStyle(color: Colors.black45),
    );
  }
}
