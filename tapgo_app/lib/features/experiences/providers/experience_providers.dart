import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src/network/api_client.dart';
import '../../../src/network/dio_provider.dart';
import '../repository/experience_repository.dart';

final experienceRepositoryProvider = Provider<ExperienceRepository>((ref) {
  return ExperienceRepository(
    api: ref.watch(apiClientProvider),
    dio: ref.watch(dioProvider),
  );
});
