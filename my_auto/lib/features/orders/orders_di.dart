import 'package:my_auto/core/services/graphql/index.dart';

import 'data/datasources/orders_local_datasource.dart';
import 'data/datasources/orders_remote_datasource.dart';
import 'data/repositories/orders_repository_impl.dart';
import 'domain/repositories/orders_repository.dart';

late final OrdersRepository ordersRepository;

void initializeOrdersRepository() {
  ordersRepository = OrdersRepositoryImpl(
    remote: OrdersRemoteDataSource(GraphQLConfig.client()),
    local: OrdersLocalDataSource(),
  );
}
