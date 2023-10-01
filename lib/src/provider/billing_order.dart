import 'package:flutter/material.dart';
import 'package:shopos/src/models/input/order_input.dart';

class Billing with ChangeNotifier {
  // List<OrderInput> _orderInput = [];
  // List<OrderType> _ordertype = [];

  Map<String, OrderInput> _salesBilling = {};

  Map<String, OrderInput> get salesBilling {
    return {..._salesBilling};
  }

  Map<String, OrderInput> _purchaseBilling = {};

  Map<String, OrderInput> get purchaseBilling {
    return {..._purchaseBilling};
  }

  void addSalesBill(OrderInput input, String orderId) {
    if (_salesBilling.containsKey(orderId)) {
      //.... change quantity
      _salesBilling.update(
          orderId,
          (existingOrder) => OrderInput(
              orderItems: existingOrder.orderItems,
              modeOfPayment: existingOrder.modeOfPayment,
              party: existingOrder.party,
              user: existingOrder.user));
    } else {
      _salesBilling.putIfAbsent(
          orderId,
          () => OrderInput(
                orderItems: input.orderItems,
                modeOfPayment: input.modeOfPayment,
                party: input.party,
                user: input.user,
              ));
    }
    notifyListeners();
  }

  void addPurchaseBill(OrderInput input, String orderId) {
    if (_purchaseBilling.containsKey(orderId)) {
      //.... change quantity
      _purchaseBilling.update(
          orderId,
          (existingOrder) => OrderInput(
              orderItems: existingOrder.orderItems,
              modeOfPayment: existingOrder.modeOfPayment,
              party: existingOrder.party,
              user: existingOrder.user));
    } else {
      _purchaseBilling.putIfAbsent(
          orderId,
          () => OrderInput(
                orderItems: input.orderItems,
                modeOfPayment: input.modeOfPayment,
                party: input.party,
                user: input.user,
              ));
    }
    notifyListeners();
  }

  void removeSalesBillItems(String orderId) {
    _salesBilling.remove(orderId);
    notifyListeners();
  }

  void removePurchaseBillItems(String prodId) {
    _purchaseBilling.remove(prodId);
    notifyListeners();
  }

  // void addOrderInputItem(OrderInput input, OrderType orderType) {
  //   _orderInput.add(input);
  //   _ordertype.add(orderType);
  //   notifyListeners();
  // }

  // void removeBill(OrderInput input, OrderType orderType) {
  //   int inputIdx = _orderInput.indexWhere((element) => element == input);

  //   _orderInput.removeAt(inputIdx);
  //   _ordertype.removeAt(inputIdx);
  //   notifyListeners();
  // }

  // List<OrderInput> getAllOrderInput() {
  //   return _orderInput.reversed.toList();
  // }

  // List<OrderType> getAllOrderType() {
  //   return _ordertype.reversed.toList();
  // }
}
