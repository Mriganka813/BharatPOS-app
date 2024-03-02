

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopos/src/services/billing_service.dart';

import '../../models/input/order.dart';

part 'billing_state.dart';

class BillingCubit extends Cubit<BillingState> {
  BillingCubit() : super(BillingInitial());
  final BillingService _billingService = const BillingService();

  Future<Response> createBillingOrder(Order order) async {
    emit(BillingLoading());

    final response = await _billingService.createBillingOrder(order);
    if((response.statusCode ?? 400) > 300){
      emit(BillingError("Error creating billing order"));
      return response;
    }
    emit(BillingSuccess());
    // getBillingOrders();
    return response;
  }
  Future<Response> updateBillingOrder(Order order) async {
    emit(BillingLoading());

    final response = await _billingService.updateBillingOrder(order);
    if((response.statusCode ?? 400) > 300){
      emit(BillingError("Error creating billing order"));
      return response;
    }
    emit(BillingSuccess());
    // getBillingOrders();
      return response;
  }
  void getBillingOrders() async {
    emit(BillingLoading());
    print("executing get billing orders");
    List<Order> _allBills = [];
    List<dynamic> allBillingOrders = await _billingService.getAllBillingOrder();
    // if((response.statusCode ?? 400) > 300){
    //   emit(BillingError("Error creating billing order"));
    //   return;
    // }
    allBillingOrders.forEach((element) {
      _allBills.add(Order.fromMap(element));
    });
    emit(BillingListRender(bills: _allBills));
  }
  void deleteBillingOrder(String kotId) async {
    emit(BillingLoading());
    final response = await _billingService.deleteBillingOrder(kotId);
    if((response.statusCode ?? 400) > 300){
      emit(BillingError("Error creating billing order"));
      return;
    }
    emit(BillingSuccess());
    // getBillingOrders();

  }
}