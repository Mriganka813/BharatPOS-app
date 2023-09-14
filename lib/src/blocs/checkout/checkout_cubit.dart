import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:shopos/src/models/input/order_input.dart';
import 'package:shopos/src/services/purchase.dart';
import 'package:shopos/src/services/sales.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(CheckoutInitial());

  Future<void> createSalesOrder(OrderInput input, String invoiceNum) async {
    emit(CheckoutLoading());
    try {
      await SalesService.createSalesOrder(input, invoiceNum);
      emit(CheckoutSuccess());
    } on DioError catch (_) {
      emit(CheckoutError("Something went wrong"));
      return;
    }
  }

  Future<void> createPurchaseOrder(OrderInput input, String invoiceNum) async {
    emit(CheckoutLoading());
    try {
      await PurchaseService.createPurchaseOrder(input, invoiceNum);
      emit(CheckoutSuccess());
    } on DioError catch (_) {
      emit(CheckoutError("Purchase order creation failed"));
      return;
    }
  }
}
