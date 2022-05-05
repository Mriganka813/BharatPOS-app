part of 'product_cubit.dart';

@immutable
abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductsListRender extends ProductState {
  final List<Product> products;
  ProductsListRender(this.products);
}

class ProductCreated extends ProductState {}

class ProductCreationFailed extends ProductState {}

class ProductsError extends ProductState {
  final String message;
  ProductsError(this.message);
}
