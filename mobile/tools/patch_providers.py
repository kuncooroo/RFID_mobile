from pathlib import Path
import re

root = Path(r'C:\laragon\www\rfid\mobile')

def ensure_import(text: str, statement: str) -> str:
    if statement in text:
        return text
    lines = text.splitlines(keepends=True)
    last_import = 0
    for i, line in enumerate(lines):
        if line.startswith('import '):
            last_import = i
    lines.insert(last_import + 1, statement + '\n')
    return ''.join(lines)

patches = [
    # auth
    dict(
        path='lib/features/auth/providers/auth_providers.dart',
        imports=[
            "import '../../../src/network/api_client.dart';",
            "import '../repository/remote_auth_repository.dart';",
        ],
        old='  return LocalAuthRepository(storage: ref.watch(secureStorageServiceProvider));',
        new='''  return RemoteAuthRepository(
    api: ref.watch(apiClientProvider),
    storage: ref.watch(secureStorageServiceProvider),
  );''',
    ),
    # splash
    dict(
        path='lib/features/splash/providers/splash_providers.dart',
        imports=[
            "import '../../../src/network/api_client.dart';",
            "import '../repository/remote_splash_repository.dart';",
        ],
        old_re=r'return LocalSplashRepository\([\s\S]*?\);',
        new='''return RemoteSplashRepository(
    api: ref.watch(apiClientProvider),
    storage: ref.watch(secureStorageServiceProvider),
  );''',
    ),
    # home
    dict(
        path='lib/features/home/providers/home_providers.dart',
        imports=[
            "import '../../../src/network/api_client.dart';",
            "import '../repository/remote_home_repository.dart';",
        ],
        old='  return LocalHomeRepository();',
        new='  return RemoteHomeRepository(api: ref.watch(apiClientProvider));',
    ),
    # catalog
    dict(
        path='lib/features/catalog/providers/catalog_providers.dart',
        imports=[
            "import '../../../src/network/api_client.dart';",
            "import '../repository/remote_catalog_repository.dart';",
        ],
        old='  return LocalCatalogRepository();',
        new='  return RemoteCatalogRepository(api: ref.watch(apiClientProvider));',
    ),
    # product
    dict(
        path='lib/features/product/providers/product_providers.dart',
        imports=[
            "import '../../../src/network/api_client.dart';",
            "import '../repository/remote_product_repository.dart';",
        ],
        old='  return LocalProductRepository();',
        new='  return RemoteProductRepository(api: ref.watch(apiClientProvider));',
    ),
    # store
    dict(
        path='lib/features/store/providers/store_providers.dart',
        imports=[
            "import '../../../src/network/api_client.dart';",
            "import '../repository/remote_store_repository.dart';",
        ],
        old='  return LocalStoreRepository();',
        new='  return RemoteStoreRepository(api: ref.watch(apiClientProvider));',
    ),
    # search
    dict(
        path='lib/features/search/providers/search_providers.dart',
        imports=[
            "import '../../../src/network/api_client.dart';",
            "import '../../../src/storage/secure_storage_service.dart';",
            "import '../repository/remote_search_repository.dart';",
        ],
        old='  return LocalSearchRepository();',
        new='''  return RemoteSearchRepository(
    api: ref.watch(apiClientProvider),
    storage: ref.watch(secureStorageServiceProvider),
  );''',
    ),
    # cart
    dict(
        path='lib/features/cart/providers/cart_providers.dart',
        imports=[
            "import '../../../src/network/api_client.dart';",
            "import '../repository/remote_cart_repository.dart';",
        ],
        old='  return LocalCartRepository();',
        new='  return RemoteCartRepository(api: ref.watch(apiClientProvider));',
    ),
    # favorites
    dict(
        path='lib/features/favorites/providers/favorites_providers.dart',
        imports=[
            "import '../../../src/network/api_client.dart';",
            "import '../repository/remote_favorites_repository.dart';",
        ],
        old='  return LocalFavoritesRepository();',
        new='  return RemoteFavoritesRepository(api: ref.watch(apiClientProvider));',
    ),
    # checkout
    dict(
        path='lib/features/checkout/providers/checkout_providers.dart',
        imports=[
            "import '../../../src/network/api_client.dart';",
            "import '../repository/remote_checkout_repository.dart';",
        ],
        old='  return LocalCheckoutRepository();',
        new='  return RemoteCheckoutRepository(api: ref.watch(apiClientProvider));',
    ),
    # orders
    dict(
        path='lib/features/orders/providers/orders_providers.dart',
        imports=[
            "import '../../../src/network/api_client.dart';",
            "import '../repository/remote_orders_repository.dart';",
        ],
        old='  return LocalOrdersRepository();',
        new='  return RemoteOrdersRepository(api: ref.watch(apiClientProvider));',
    ),
    # messaging
    dict(
        path='lib/features/messaging/providers/messaging_providers.dart',
        imports=[
            "import '../../../src/network/api_client.dart';",
            "import '../repository/remote_messaging_repository.dart';",
        ],
        old='  return LocalMessagingRepository();',
        new='  return RemoteMessagingRepository(api: ref.watch(apiClientProvider));',
    ),
    # notifications
    dict(
        path='lib/features/notifications/providers/notifications_providers.dart',
        imports=[
            "import '../../../src/network/api_client.dart';",
            "import '../repository/remote_notifications_repository.dart';",
        ],
        old='  return LocalNotificationsRepository();',
        new='  return RemoteNotificationsRepository(api: ref.watch(apiClientProvider));',
    ),
    # shell
    dict(
        path='lib/features/shell/providers/shell_providers.dart',
        imports=[
            "import '../../../src/network/api_client.dart';",
            "import '../repository/remote_shell_repository.dart';",
        ],
        old='  return LocalShellRepository();',
        new='  return RemoteShellRepository(api: ref.watch(apiClientProvider));',
    ),
    # profile
    dict(
        path='lib/features/profile/providers/profile_providers.dart',
        imports=[
            "import '../../../src/network/api_client.dart';",
            "import '../repository/remote_profile_repository.dart';",
        ],
        old_re=r'final user = ref\n[\s\S]*?return LocalProfileRepository\([\s\S]*?\);',
        new='''return RemoteProfileRepository(
    api: ref.watch(apiClientProvider),
  );''',
    ),
]

for patch in patches:
    path = root / patch['path']
    text = path.read_text(encoding='utf-8')
    for imp in patch['imports']:
        text = ensure_import(text, imp)
    if 'old_re' in patch:
        text2, n = re.subn(patch['old_re'], patch['new'], text, count=1)
        if n != 1:
            raise SystemExit(f'Regex replace failed for {path}: {n}')
        text = text2
    else:
        if patch['old'] not in text:
            raise SystemExit(f'Needle not found in {path}: {patch["old"]!r}')
        text = text.replace(patch['old'], patch['new'], 1)
    path.write_text(text, encoding='utf-8')
    print('patched', path.relative_to(root))

# RFID provider
rfid = root/'lib/features/rfid/providers/rfid_providers.dart'
text = rfid.read_text(encoding='utf-8')
text = ensure_import(text, "import '../../../src/network/api_client.dart';")
text = ensure_import(text, "import '../repository/remote_rfid_repository.dart';")
if 'USE_MOCK_RFID' not in text:
    text = text.replace(
        "final rfidRepositoryProvider = Provider<RfidRepository>(\n  (ref) => MockRfidRepository(),\n);",
        '''const bool kUseMockRfidRepository = bool.fromEnvironment(
  'USE_MOCK_RFID',
  defaultValue: false,
);

final rfidRepositoryProvider = Provider<RfidRepository>((ref) {
  if (kUseMockRfidRepository) {
    return MockRfidRepository();
  }
  return RemoteRfidRepository(api: ref.watch(apiClientProvider));
});'''
    )
rfid.write_text(text, encoding='utf-8')
print('patched', rfid.relative_to(root))
print('done')
