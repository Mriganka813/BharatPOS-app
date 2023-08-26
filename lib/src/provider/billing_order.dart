import 'package:flutter/material.dart';
import 'package:shopos/src/models/input/order_input.dart';
import 'package:shopos/src/pages/checkout.dart';

class Billing with ChangeNotifier {
  List<OrderInput> _orderInput = [];
  List<OrderType> _ordertype = [];

  void addOrderInputItem(OrderInput input, OrderType orderType) {
    _orderInput.add(input);
    _ordertype.add(orderType);
    notifyListeners();
  }

  List<OrderInput> getAllOrderInput() {
    return _orderInput;
  }

  List<OrderType> getAllOrderType() {
    return _ordertype;
  }
}
