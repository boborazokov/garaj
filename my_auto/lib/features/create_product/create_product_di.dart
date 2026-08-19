import 'package:my_auto/features/create_product/bloc/create_product_bloc.dart';
import 'package:my_auto/features/create_product/data/repositories/create_product_repository_impl.dart';
import 'package:my_auto/features/create_product/domain/repositories/create_product_repository.dart';

CreateProductRepository createProductRepository() =>
    CreateProductRepositoryImpl();

CreateProductBloc createProductBloc({required CreateProductRepository repo}) =>
    CreateProductBloc(repository: repo);
