import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:glider/repositories/api_repository.dart';
import 'package:glider/repositories/auth_repository.dart';
import 'package:glider/repositories/search_api_repository.dart';
import 'package:glider/repositories/storage_repository.dart';
import 'package:glider/repositories/web_repository.dart';
import 'package:glider/repositories/website_repository.dart';
import 'package:glider/utils/cache_interceptor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Provider<Dio> _dioProvider = Provider<Dio>(
  (_) {
    final Dio dio = Dio();
    dio.interceptors
      ..add(CacheInterceptor())
      ..add(RetryInterceptor(dio: dio));
    return dio;
  },
);

final FutureProvider<SharedPreferences> _sharedPreferences =
    FutureProvider<SharedPreferences>(
  (_) => SharedPreferences.getInstance(),
);

final Provider<FlutterSecureStorage> _secureStorageProvider =
    Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

final Provider<ApiRepository> apiRepositoryProvider = Provider<ApiRepository>(
  (Ref ref) => ApiRepository(
    ref.read(_dioProvider),
  ),
);

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
  (Ref ref) => AuthRepository(
    ref.read(websiteRepositoryProvider),
    ref.read(storageRepositoryProvider),
  ),
);

final Provider<SearchApiRepository> searchApiRepositoryProvider =
    Provider<SearchApiRepository>(
  (Ref ref) => SearchApiRepository(
    ref.read(_dioProvider),
  ),
);

final Provider<StorageRepository> storageRepositoryProvider =
    Provider<StorageRepository>(
  (Ref ref) => StorageRepository(
    ref.read(_secureStorageProvider),
    ref.read(_sharedPreferences.future),
  ),
);

final Provider<WebRepository> webRepositoryProvider = Provider<WebRepository>(
  (Ref ref) => WebRepository(
    ref.read(_dioProvider),
  ),
);

final Provider<WebsiteRepository> websiteRepositoryProvider =
    Provider<WebsiteRepository>(
  (Ref ref) => WebsiteRepository(
    ref.read(_dioProvider),
  ),
);
