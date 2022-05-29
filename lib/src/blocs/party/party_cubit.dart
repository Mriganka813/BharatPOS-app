import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:magicstep/src/models/input/party_input.dart';
import 'package:magicstep/src/models/order.dart';
import 'package:magicstep/src/models/page_meta.dart';
import 'package:magicstep/src/models/party.dart';
import 'package:magicstep/src/services/auth.dart';
import 'package:magicstep/src/services/orders.dart';
import 'package:magicstep/src/services/party.dart';
import 'package:meta/meta.dart';

part 'party_state.dart';

class PartyCubit extends Cubit<PartyState> {
  final PageMeta _salesPageMeta = PageMeta();
  final PageMeta _purchasePageMeta = PageMeta();
  final List<Party> _saleParties = [];
  final List<Party> _purchaseParties = [];

  ///
  static const OrdersService _ordersService = OrdersService();

  ///
  PartyCubit() : super(PartyInitial());
  final PartyService _partyService = const PartyService();

  void createParty(PartyInput p) async {
    emit(PartyLoading());
    try {
      final response = await _partyService.createParty(p);
      if ((response.statusCode ?? 400) > 300) {
        emit(PartyError("Error creating party"));
        return;
      }
      const AuthService().saveCookie(response);
    } on DioError {
      emit(PartyError("Error creating party"));
    }
    emit(PartySuccess());
    return;
  }

  void getInitialCreditParties() async {
    emit(PartyLoading());
    try {
      final sales = await _partyService.getCreditSaleParties();
      final purchase = await _partyService.getCreditPurchaseParties();
      _saleParties.clear();
      _purchaseParties.clear();
      _saleParties.addAll(sales);
      _purchaseParties.addAll(purchase);
      emit(CreditPartiesListRender(
        purchaseParties: _purchaseParties,
        saleParties: _saleParties,
      ));
    } catch (err) {
      log("$err");
      PartyError("Error fetching parties");
    }
  }

  void getMyParties() async {
    emit(PartyLoading());
    final response = await _partyService.getParties();
    if ((response.statusCode ?? 400) > 300) {
      emit(PartyError("Error fetching parties"));
      return;
    }
    final parties = List.generate(
      response.data['allParty'].length,
      (i) => Party.fromMap(response.data['allParty'][i]),
    );
    return emit(PartyListRender(parties));
  }

  void deleteParty(Party p) async {
    final response = await _partyService.deleteParty(p);
    if ((response.statusCode ?? 400) > 300) {
      emit(PartyError("Error deleting party"));
      return;
    }

    return emit(PartySuccess());
  }

  void updateParty(PartyInput p) async {
    final response = await _partyService.updateParty(p);
    if ((response.statusCode ?? 400) > 300) {
      emit(PartyError("Error updating party"));
      return;
    }
    return emit(PartySuccess());
  }
}
