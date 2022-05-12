import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:magicstep/src/models/input/order_input.dart';
import 'package:magicstep/src/services/sales.dart';
import 'package:meta/meta.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(CheckoutInitial());

  Future<void> createSalesOrder(OrderInput input) async {
    emit(CheckoutLoading());
    try {
      final response = await SalesService.createSalesOrder(input);
      emit(CheckoutSuccess());
    } on DioError catch (err) {
      log(err.message);
      emit(CheckoutError(err.response?.data['message']));
      return;
    }
  }
}
