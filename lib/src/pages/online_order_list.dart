import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/online_order.dart';
import '../services/order_services.dart';
import '../services/order_status.dart';

class OnlineOrderList extends StatefulWidget {
  const OnlineOrderList({Key? key}) : super(key: key);

  static const routeName = '/onlineorder_list';

  @override
  State<OnlineOrderList> createState() => _OnlineOrderListState();
}

class _OnlineOrderListState extends State<OnlineOrderList> {
  var dropdownVal = 'ALL';
  var startDate = 'Start date';
  var endDate = 'End date';

  bool isLoading = false;
  final OrderStatus orderStatus = OrderStatus();
  final OrderServices orderServices = OrderServices();

  List<OnlineOrder> orderHistory = [];
  List<OnlineOrder> pendingData = [];
  List<OnlineOrder> allData = [];
  List<OnlineOrder> dateFilter = [];
  bool checkVisible = true;
  int orderLength = 0;

  getOrderHistory() async {
    setState(() {
      isLoading = true;
    });
    orderHistory = await OrderServices.orderHistory();
    orderHistory = orderHistory.reversed.toList();
    orderLength = orderHistory.length;
    print("history" + orderHistory.length.toString());

    pendingData = orderHistory;
    allData = orderHistory;
    dateFilter = pendingData;

    setState(() {
      isLoading = false;
    });
  }

  orderAccept(String orderId, int index) async {
    setState(() {
      isLoading = true;
    });
    await orderStatus.orderAcceptAll(orderId);
    pendingData.removeAt(index);
    orderHistory.removeWhere((element) => element.orderId == orderId);

    setState(() {
      isLoading = false;
    });
  }

  orderReject(String orderId, int index) async {
    setState(() {
      isLoading = true;
    });
    await orderStatus.orderRejectAll(orderId);
    pendingData.removeAt(index);
    orderHistory.removeWhere((element) => element.orderId == orderId);

    setState(() {
      isLoading = false;
    });
  }

  getItemsLength() {
    for (int i = 0; i < orderHistory.length; i++) {
      List items = orderHistory[i].items!;
      orderLength += items.length;
    }
  }

  @override
  void initState() {
    super.initState();
    getOrderHistory();
    getItemsLength();
  }

  var orderStatusList = [
    'ALL',
    'PENDING',
    'CONFIRMED',
    'ON THE WAY',
    'DELIVERED',
    'COMPLETED',
    'RETURNED',
    'REJECTED',
  ];

  filterData() {
    pendingData = orderHistory
        .where(
            (element) => element.items![0].status == dropdownVal.toLowerCase())
        .toList();

    print("Asd" + pendingData.length.toString());
  }

  dateFilterData() {
    pendingData = dateFilter.where((item) {
      DateTime createdAt =
          DateTime.parse(item.createdAt.toString().substring(0, 10));
      return createdAt
              .isAfter(DateTime.parse(startDate).subtract(Duration(days: 1))) &&
          createdAt.isBefore(
            DateTime.parse(endDate).add(
              Duration(days: 1),
            ),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            size: height / 50,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Order Lists',
          style: TextStyle(
            color: Colors.black,
            fontSize: height / 40,
            fontFamily: 'GilroyBold',
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.blue,
            ))
          : Column(
              children: [
                SizedBox(
                  height: height / 50,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _filterBox(
                      DropdownButton(
                        dropdownColor: Colors.white,
                        underline: const SizedBox(),
                        value: dropdownVal,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: orderStatusList.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Padding(
                              padding: EdgeInsets.only(left: width / 5),
                              child: Text(
                                items,
                                style: TextStyle(
                                    color: Colors.black, fontSize: height / 60),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownVal = newValue!;
                            if (dropdownVal == 'ALL') {
                              checkVisible = true;
                              pendingData = allData;
                              getOrderHistory();
                            } else {
                              if (dropdownVal == "CONFIRMED" ||
                                  dropdownVal == "PENDING")
                                checkVisible = false;
                              else
                                checkVisible = true;
                              filterData();
                            }
                          });
                        },
                      ),
                      height,
                      width,
                    ),
                    SizedBox(
                      height: height / 50,
                    ),
                    Visibility(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101));

                                if (pickedDate != null) {
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);

                                  setState(() {
                                    startDate = formattedDate;
                                    if (startDate != 'Start date' &&
                                        endDate != 'End date') {
                                      dateFilterData();
                                    }
                                  });
                                }
                              },
                              child:
                                  _datepickerWidget(startDate, height, width)),
                          SizedBox(
                            width: width / 20,
                          ),
                          GestureDetector(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101));

                              if (pickedDate != null) {
                                var formattedDate =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);

                                setState(() {
                                  endDate = formattedDate;
                                  if (startDate != 'Start date' &&
                                      endDate != 'End date') {
                                    dateFilterData();
                                  }
                                });
                              }
                            },
                            child: _datepickerWidget(endDate, height, width),
                          ),
                        ],
                      ),
                      visible: checkVisible,
                    )
                  ],
                ),
                SizedBox(
                  height: height / 50,
                ),
                pendingData.isEmpty
                    ? Center(
                        child: Text('No data found!'),
                      )
                    : cardInfo(height, width),
              ],
            ),
    );
  }

  Widget cardInfo(double height, double width) {
    return Expanded(
      child: ListView.builder(
        itemCount: pendingData.length,
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final order = pendingData[index];
          final orderId = order.orderId;
          final date = order.createdAt.toString().substring(0, 10);
          final List<Items> items = pendingData[index].items!;
          int totalAmount = 0;

          for (int i = 0; i < items.length; i++) {
            final qty = items[i].quantity;
            final prodPrice = items[i].productPrice;
            int sum = 0;
            sum += int.parse(qty.toString()) * int.parse(prodPrice.toString());

            totalAmount += sum;
          }

          print(pendingData);

          return Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height / 50,
                    ),
                    Row(
                      children: [
                        Icon(Icons.receipt_long,
                            color: Colors.orange, size: height / 35),
                        SizedBox(width: width / 35),
                        Expanded(
                          child: Text(
                            "#$orderId",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: height / 55,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: width / 20,
                        ),
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: height / 55,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height / 50,
                    ),
                    ListView.builder(
                      itemCount: items.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, i) {
                        final qty = items[i].quantity;
                        final prodName = items[i].productName;
                        final prodPrice = items[i].productPrice;
                        int sum = 0;
                        sum += int.parse(qty.toString()) *
                            int.parse(prodPrice.toString());

                        totalAmount += sum;

                        print(totalAmount);

                        return product(prodName!, qty!, sum, height, width);
                      },
                    ),
                    SizedBox(
                      height: height / 50,
                    ),
                    Row(
                      children: [
                        Spacer(),
                        Text(
                          'Total price: ₹$totalAmount',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: height / 60,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height / 50,
                    ),
                    if (dropdownVal == 'PENDING')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.green),
                            ),
                            onPressed: () async {
                              await _showDialog(orderId!, index);
                            },
                            child: Text('Accept'),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.red),
                            ),
                            onPressed: () => orderReject(orderId!, index),
                            child: Text('Reject'),
                          )
                        ],
                      ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer name :',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: height / 55,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${pendingData[index].addresses!.name}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: height / 55,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        ElevatedButton.icon(
                            icon: Icon(Icons.phone),
                            onPressed: () {
                              int phoneNo =
                                  pendingData[index].addresses!.phoneNumber!;
                              _launchDialer(phoneNo);
                            },
                            label: Text('Call Customer')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _launchDialer(int phoneNo) async {
    var phoneNumber = '+91$phoneNo'; // Replace with your desired phone number

    final uri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  _showDialog(String orderId, int index) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (context) => AlertDialog(
        title: Text('Paid status'),
        content: Text('Please confirm that payment is done?'),
        actions: [
          DialogButton(
              child: Text(
                'Paid',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              ),
              onPressed: () async {
                await orderStatus.isPaid(orderId, "paid");
                orderAccept(orderId, index);
                Navigator.of(context).pop();
              }),
          DialogButton(
              child: Text(
                'Not paid',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              ),
              onPressed: () async {
                await orderStatus.isPaid(orderId, "unpaid");
                orderAccept(orderId, index);
                Navigator.of(context).pop();
              }),
        ],
      ),
    );
  }

  Widget _filterBox(Widget child, var height, var width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: height / 20,
          width: width / 1.6,
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
              border: Border.all(width: 0.5)),
          child: child,
        ),
      ],
    );
  }

  Widget product(String name, int qty, int price, double height, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name,
            style: TextStyle(
              color: Colors.black,
              fontSize: height / 50,
              fontFamily: 'GilroyBold',
            ),
            overflow: TextOverflow.ellipsis,
            softWrap: false),
        SizedBox(
          height: height / 80,
        ),
        Row(
          children: [
            Text(
              'qty: $qty',
              style: TextStyle(
                color: Colors.black,
                fontSize: height / 55,
                fontFamily: 'GilroyMedium',
              ),
            ),
            Spacer(),
            Text(
              'Price: ₹$price',
              style: TextStyle(
                color: Colors.grey,
                fontSize: height / 70,
                fontFamily: 'GilroyMedium',
              ),
            )
          ],
        ),
        SizedBox(
          height: height / 50,
        )
      ],
    );
  }

  Widget _datepickerWidget(String text, double height, double width) {
    return Container(
      height: height / 20,
      width: width / 3.4,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          border: Border.all(width: 0.5)),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey,
          fontFamily: 'GilroyMedium',
          fontSize: height / 55,
        ),
      ),
    );
  }
}
