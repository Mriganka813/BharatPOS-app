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
  final List<Order> _salesOrders = [];
  final List<Order> _purchaseOrders = [];
  PageMeta _salesPageMeta = PageMeta();
  PageMeta _purchasePageMeta = PageMeta();

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

  /// Fetch purchase and sales orders
  void getOrders() async {
    try {
      _salesOrders.addAll(await _getSalesOrders());
      _purchaseOrders.addAll(await _getPurchaseOrders());
      emit(OrdersListRender(
        salesOrders: _salesOrders,
        purchaseOrders: _purchaseOrders,
      ));
    } catch (err) {
      emit(PartyError(err.toString()));
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

  ///
  Future<List<Order>> _getSalesOrders() async {
    final nextPage = _salesPageMeta.nextPage;
    if (nextPage == null) {
      return [];
    }
    final res = await _ordersService.getSalesOrders(nextPage);
    _salesPageMeta = PageMeta.fromMap(res.data['meta']);
    final data = res.data['salesOrders'];
    return List.generate(data.length, (int index) {
      return Order.fromMap(data[index]);
    });
  }

  ///
  Future<List<Order>> _getPurchaseOrders() async {
    final nextPage = _purchasePageMeta.nextPage;
    if (nextPage == null) {
      return [];
    }
    final res = await _ordersService.getPurchaseOrders(nextPage);
    _purchasePageMeta = PageMeta.fromMap(res.data['meta']);
    final data = res.data['purchaseOrders'];
    return List.generate(data.length, (int index) {
      return Order.fromMap(data[index]);
    });
  }
}
