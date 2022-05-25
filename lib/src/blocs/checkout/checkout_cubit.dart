import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:magicstep/src/models/input/order_input.dart';
import 'package:magicstep/src/services/purchase.dart';
import 'package:magicstep/src/services/sales.dart';
import 'package:meta/meta.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(CheckoutInitial());

  Future<void> createSalesOrder(OrderInput input) async {
    emit(CheckoutLoading());
    try {
      await SalesService.createSalesOrder(input);
      emit(CheckoutSuccess());
    } on DioError catch (_) {
      emit(CheckoutError("Something went wrong"));
      return;
    }
  }

  Future<void> createPurchaseOrder(OrderInput input) async {
    emit(CheckoutLoading());
    try {
      await PurchaseService.createPurchaseOrder(input);
      emit(CheckoutSuccess());
    } on DioError catch (_) {
      emit(CheckoutError("Purchase order creation failed"));
      return;
    }
  }
}
