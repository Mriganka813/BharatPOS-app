part of 'billing_cubit.dart';

@immutable
abstract class BillingState {}

class BillingInitial extends BillingState {}

class BillingListRender extends BillingState{
  final List<Order> bills;
  BillingListRender({required this.bills});
}

class BillingError extends BillingState {
  final String message;
  BillingError(this.message);
}
class BillingQrDialog extends BillingState {
  final List<Order> qrOrders;
  BillingQrDialog({required this.qrOrders});
}
class BillingLoading extends BillingState {}

class BillingUpdate extends BillingState {}

class BillingQrSuccess extends BillingState {}

class BillingSuccess extends BillingState {}

