import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopos/src/blocs/specific%20party/specific_party_state.dart';
import 'package:shopos/src/models/specific_party.dart';
import 'package:shopos/src/services/specific_party.dart';

class SpecificPartyCubit extends Cubit<SpecificPartyState> {
  final List<SpecificParty> _specificsaleParties = [];
  final List<SpecificParty> _specificpurchaseParties = [];
  final SpecificPartyService _partyService = SpecificPartyService();

  SpecificPartyCubit() : super(SpecificPartyInitial());

  void getInitialCreditHistory(String id) async {
    emit(SpecificPartyLoading());
    try {
      final sales = await _partyService.getSalesCreditHistory(id);
      _specificsaleParties.clear();
      _specificpurchaseParties.clear();
      _specificsaleParties.addAll(sales);
      emit(SpecificPartyListRender(sales));
    } catch (err) {
      log("$err");
      SpecificPartyError("Error fetching parties");
    }
  }

  void getInitialpurchasedHistory(String id) async {
    emit(SpecificPartyLoading());
    try {
      final purchase = await _partyService.getpurchaseCreditHistory(id);
      _specificsaleParties.clear();
      _specificpurchaseParties.clear();
      _specificpurchaseParties.addAll(purchase);
      emit(SpecificPartyListRender(purchase));
    } catch (err) {
      log("$err");
      SpecificPartyError("Error fetching parties");
    }
  }
}
