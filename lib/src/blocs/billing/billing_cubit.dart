

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopos/src/services/billing_service.dart';

import '../../models/input/order.dart';

part 'billing_state.dart';

class BillingCubit extends Cubit<BillingState> {
  BillingCubit() : super(BillingInitial());
  final BillingService _billingService = const BillingService();

  searchByTableNo(String tableNum) async {
    // emit(BillingLoading());
    List<Order> _allBills = [];
    List<dynamic> allBillingOrders = await _billingService.getAllBillingOrder();
    allBillingOrders.forEach((element) {
      _allBills.add(Order.fromMap(element));
    });
    List<Order> searchedOrders = [];
    _allBills.forEach((element) {
      if(element.tableNo.trim() == tableNum.trim()){
        searchedOrders.add(element);
      }
    });
    emit(BillingListRender(bills: searchedOrders));
  }
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

    List<Order> _allQrBills = [];
    List<dynamic> allQrBillingOrders = await _billingService.getAllQrOrder();
    allQrBillingOrders.forEach((element) {
      _allQrBills.add(Order.fromMap(element,));
    });
    emit(BillingQrDialog(qrOrders: _allQrBills));

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
  // void getQrOrders() async {
  //   emit(BillingLoading());
  //   List<Order> _allQrBills = [];
  //   List<dynamic> allQrBillingOrders = await _billingService.getAllQrOrder();
  //   allQrBillingOrders.forEach((element) {
  //     _allQrBills.add(Order.fromMap(element,));
  //   });
  //   emit(BillingQrDialog(qrOrders: _allQrBills));
  //
  // }
  void deleteQrOrder(String kotid) async {
    emit(BillingLoading());
    final response = await _billingService.deleteQrOrder(kotid);
    if((response.statusCode ?? 400) > 300){
      emit(BillingError("Error creating billing order"));
      return;
    }
    emit(BillingSuccess());
    // getBillingOrders();
  }
  void acceptQrOrder(String id, Order order) async {
    emit(BillingLoading());
    final response = await _billingService.acceptAddQrOrder(id,order);
    if((response.statusCode ?? 400) > 300){
      emit(BillingError("Error creating billing order"));
      return;
    }
    emit(BillingSuccess());
    // getBillingOrders();
  }
}