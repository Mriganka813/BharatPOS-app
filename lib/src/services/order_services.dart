import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shopos/src/models/online_order.dart';
import 'package:shopos/src/models/order.dart';

// import 'api_v1.dart';
import 'package:shopos/src/services/api_v1.dart';

import '../utils.dart';

class OrderServices {
  //const OrderServices()

  static Future<List<OnlineOrder>> orderHistory() async {
    final response = await ApiV1Service.getRequest('/myorders');
    return (response.data as List)
        .map((e) => OnlineOrder.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
