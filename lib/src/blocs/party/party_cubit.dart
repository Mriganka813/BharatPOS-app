import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:shopos/src/models/input/party_input.dart';
import 'package:shopos/src/models/order.dart';
import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/services/party.dart';

part 'party_state.dart';

class PartyCubit extends Cubit<PartyState> {
  final List<Party> _parties = [];
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

  ///
  void getCustomerParties({String? searchQuery}) async {
    try {
      final sales = await _partyService.getCreditSaleParties();
      emit(CreditPartiesListRender(parties: sales));
    } catch (err) {
      emit(PartyError("Error getting parties"));
    }
  }

  ///
  void getSupplierParties({String? searchQuery}) async {
    try {
      final sales = await _partyService.getCreditPurchaseParties();
      emit(CreditPartiesListRender(parties: sales));
    } catch (err) {
      emit(PartyError("Error getting parties"));
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

    return emit(PartySuccess());
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
