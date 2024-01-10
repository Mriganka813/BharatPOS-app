import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/input/order.dart';
import '../pages/checkout.dart';
import 'api_v1.dart';

class EstimateService{
  const EstimateService();

  static Future<Response> createEstimateOrder(Order orderItemInput, String estimateNum) async {
    print("line 12 in estimate.dart");
    print(orderItemInput.toMap(OrderType.estimate).toString());
    print("end---");
    final response = await ApiV1Service.postRequest(
      '/estimate/new',
      data: {
        'orderItems': orderItemInput.orderItems?.map((e) => e.toSaleMap()).toList(),
        'reciverName': orderItemInput.reciverName,
        'businessName': orderItemInput.businessName,
        'businessAddress': orderItemInput.businessAddress,
        'gst': orderItemInput.gst,
        'estimateNum': estimateNum
      },
    );
    if(kDebugMode){
      print("----line 29 in estimate.dart");
      print(response.data);
    }
    return response;
  }
  static Future<Response> convertEstimateToSales(Order orderItemInput, String invoiceNum) async {
    print("line 35 in estimate.dart");
    print(orderItemInput.party?.id);
    print(orderItemInput.objId);
    final response = await ApiV1Service.postRequest(
      '/estimate/${orderItemInput.objId}',
      data: {
        'modeOfPayment': orderItemInput.modeOfPayment,
        'invoiceNum': invoiceNum,
        'party': orderItemInput.party?.id,
      },
    );
    if(kDebugMode){
      print("----line 44 in estimate.dart");
      print(response.data);
    }
    return response;
  }
  static Future<Response> updateEstimateOrder(Order orderItemInput) async {
    print("line 52 in estimate.dart");
    print(orderItemInput.objId);
    final response = await ApiV1Service.putRequest(
      '/estimate/${orderItemInput.objId}',
      data: {
        'orderItems': orderItemInput.orderItems?.map((e) => e.toSaleMap()).toList(),
        'reciverName': orderItemInput.reciverName,
        'businessName': orderItemInput.businessName,
        'businessAddress': orderItemInput.businessAddress,
        'gst': orderItemInput.gst,
        'estimateNum': orderItemInput.estimateNum
      },
    );
    if(kDebugMode){
      print("----line 62 in estimate.dart");
      print(response.data);
    }
    return response;
  }
  static Future<Map<String, dynamic>> getNumberOfEstimates() async {
    final response = await ApiV1Service.getRequest('/estimatesNum');
    return response.data;
  }
  static Future<Map<String, dynamic>> getEstimate(String estimateNum) async {
    final response = await ApiV1Service.getRequest('/estimate/$estimateNum');
    return response.data;
  }

}