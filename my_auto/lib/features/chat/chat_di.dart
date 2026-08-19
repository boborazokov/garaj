import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/chat/data/security/chat_db_key_service.dart';

import 'data/datasources/chat_local_datasource.dart';
import 'data/datasources/chat_remote_datasource.dart';
import 'data/datasources/chat_upload_datasource.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'domain/repositories/chat_repository.dart';

late final ChatRepository chatRepository;

void initializeChatRepository() {
  chatRepository = ChatRepositoryImpl(
    remote: ChatRemoteDataSource(GraphQLConfig.client()),
    local: InMemoryChatLocalDataSource(),
    uploads: ChatUploadDataSource(),
  );
}

/// Wipe chat encryption key + in-memory cache on logout.
Future<void> clearChatSessionData() async {
  await ChatDbKeyService.destroyKey();
  await chatRepository.clearSessionCaches();
}
