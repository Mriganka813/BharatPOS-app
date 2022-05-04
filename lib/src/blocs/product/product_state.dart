part of 'product_cubit.dart';

@immutable
abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductsListRender extends ProductState {}

class CreateProductSuccess extends ProductState {}

class ProductError extends ProductState {}
