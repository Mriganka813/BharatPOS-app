import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:shopos/src/models/input/order.dart';
import 'package:shopos/src/services/SalesReturn.dart';
import 'package:shopos/src/services/estimate.dart';
import 'package:shopos/src/services/purchase.dart';
import 'package:shopos/src/services/sales.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(CheckoutInitial());

  Future<int?> getSalesNum() async {
    try {
      Map<String, dynamic> salesNumMap = await SalesService.getNumberOfSales();
      return Future<int?>.value(salesNumMap["numSales"]);
    } on DioError catch (_) {
      emit(CheckoutError("Something went wrong"));
      return null;
    }
  }
  Future<int?> getEstimateNum() async {
    try {
      Map<String, dynamic> EstimatesNumMap = await EstimateService.getNumberOfEstimates();
      return Future<int?>.value(EstimatesNumMap["numEstimates"]);
    } on DioError catch (_) {
      emit(CheckoutError("Something went wrong"));
      return null;
    }
  }
  Future<int?> getPurchasesNum() async {
    try {
      Map<String, dynamic> purchasesNumMap = await PurchaseService.getNumberOfPurchases();
      return Future<int?>.value(purchasesNumMap["numPurchases"]);
    } on DioError catch (_) {
      emit(CheckoutError("Something went wrong"));
      return null;
    }
  }

  Future<void> createEstimateOrder(Order input, String estimateNum) async {
    emit(CheckoutLoading());
    try{
      await EstimateService.createEstimateOrder(input, estimateNum);
      emit(CheckoutSuccess());
    }catch (_) {
      emit(CheckoutError("Something went wrong"));
      return;
    }
  }
  Future<void> updateEstimateOrder(Order input) async {
    emit(CheckoutLoading());
    try{
      await EstimateService.updateEstimateOrder(input);
      emit(CheckoutSuccess());
    }catch (_) {
      emit(CheckoutError("Something went wrong"));
      return;
    }
  }
  Future<void> convertEstimateToSales(Order input, String invoiceNum) async {
    emit(CheckoutLoading());
    try{
      await EstimateService.updateEstimateOrder(input);
      await EstimateService.convertEstimateToSales(input, invoiceNum);
      emit(CheckoutSuccess());
    }catch (_) {
      emit(CheckoutError("Something went wrong"));
      return;
    }
  }
  Future<void> createSalesOrder(Order input, String invoiceNum) async {
    emit(CheckoutLoading());
    try {
      await SalesService.createSalesOrder(input, invoiceNum);
      emit(CheckoutSuccess());
    } on DioError catch (_) {
      emit(CheckoutError("Something went wrong"));
      return;
    }
  }

  Future<void> createPurchaseOrder(Order input, String invoiceNum) async {
    emit(CheckoutLoading());
    try {
      await PurchaseService.createPurchaseOrder(input, invoiceNum);
      emit(CheckoutSuccess());
    } on DioError catch (_) {
      emit(CheckoutError("Purchase order creation failed"));
      return;
    }
  }


   Future<void> createSalesReturn(Order input, String invoiceNum,String total) async {
    emit(CheckoutLoading());
    try {
      await SalesReturnService.createSalesReturnOrder(input, invoiceNum,total);
      emit(CheckoutSuccess());
    } on DioError catch (_) {
      emit(CheckoutError("Purchase order creation failed"));
      return;
    }
  }
}
