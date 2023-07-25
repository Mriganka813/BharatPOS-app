part of 'product_cubit.dart';

@immutable
abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductsListRender extends ProductState {
  final List<Product> products;
  ProductsListRender(this.products);
}

class ProductLoading extends ProductState {}

class ProductCreated extends ProductState {}

class ProductCreationFailed extends ProductState {}

class gstincludeoptionenable extends ProductState {}

class calculateallgst extends ProductState {}

class ProductsError extends ProductState {
  final String message;
  ProductsError(this.message);
}
