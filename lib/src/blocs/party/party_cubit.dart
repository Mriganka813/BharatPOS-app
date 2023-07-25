import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:shopos/src/models/input/party_input.dart';
import 'package:shopos/src/models/order.dart';
import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/services/party.dart';

part 'party_state.dart';

class PartyCubit extends Cubit<PartyState> {
  final List<Party> _saleParties = [];
  final List<Party> _purchaseParties = [];
  final PartyService _partyService = const PartyService();

  ///
  PartyCubit() : super(PartyInitial());

  /// Create a new party
  void createParty(PartyInput p) async {
    emit(PartyLoading());
    try {
      final response = await _partyService.createParty(p);
      if ((response.statusCode ?? 400) > 300) {
        emit(PartyError("Error creating party"));
        return;
      }
    } on DioError {
      emit(PartyError("Error creating party"));
    }
    emit(PartySuccess());
    return;
  }

  /// Get the intial credit parties
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

  /// Get my parties
  Future<void> getMyParties() async {
    emit(PartyLoading());
    try {
      final response = await _partyService.getParties();
      final parties = List.generate(
        response.data['allParty'].length,
        (i) => Party.fromMap(response.data['allParty'][i]),
      );
      return emit(PartyListRender(parties));
    } catch (err) {
      emit(PartyError("Error fetching parties"));
    }
  }

  /// Delete a party
  void deleteParty(Party p) async {
    final response = await _partyService.deleteParty(p);
    if ((response.statusCode ?? 400) > 300) {
      emit(PartyError("Error deleting party"));
      return;
    }
    getInitialCreditParties();
  }

  /// Update party
  void updateParty(PartyInput p) async {
    final response = await _partyService.updateParty(p);
    if ((response.statusCode ?? 400) > 300) {
      emit(PartyError("Error updating party"));
      return;
    }
    return emit(PartySuccess());
  }

  ///

}
