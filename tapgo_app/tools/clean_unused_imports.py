from pathlib import Path

root = Path(r'C:\laragon\www\rfid\mobile')
unused = [
    ('lib/features/auth/providers/auth_providers.dart', "import '../repository/local_auth_repository.dart';\n"),
    ('lib/features/cart/providers/cart_providers.dart', "import '../repository/local_cart_repository.dart';\n"),
    ('lib/features/catalog/providers/catalog_providers.dart', "import '../repository/local_catalog_repository.dart';\n"),
    ('lib/features/checkout/providers/checkout_providers.dart', "import '../repository/local_checkout_repository.dart';\n"),
    ('lib/features/favorites/providers/favorites_providers.dart', "import '../repository/local_favorites_repository.dart';\n"),
    ('lib/features/home/providers/home_providers.dart', "import '../repository/local_home_repository.dart';\n"),
    ('lib/features/messaging/providers/messaging_providers.dart', "import '../repository/local_messaging_repository.dart';\n"),
    ('lib/features/notifications/providers/notifications_providers.dart', "import '../repository/local_notifications_repository.dart';\n"),
    ('lib/features/orders/providers/orders_providers.dart', "import '../repository/local_orders_repository.dart';\n"),
    ('lib/features/product/providers/product_providers.dart', "import '../repository/local_product_repository.dart';\n"),
    ('lib/features/profile/providers/profile_providers.dart', "import '../../../src/storage/secure_storage_service.dart';\n"),
    ('lib/features/profile/providers/profile_providers.dart', "import '../repository/local_profile_repository.dart';\n"),
    ('lib/features/search/providers/search_providers.dart', "import '../repository/local_search_repository.dart';\n"),
    ('lib/features/shell/providers/shell_providers.dart', "import '../repository/local_shell_repository.dart';\n"),
    ('lib/features/splash/providers/splash_providers.dart', "import '../repository/local_splash_repository.dart';\n"),
    ('lib/features/store/providers/store_providers.dart', "import '../repository/local_store_repository.dart';\n"),
]

for rel, line in unused:
    path = root/rel
    text = path.read_text(encoding='utf-8')
    if line in text:
        path.write_text(text.replace(line, ''), encoding='utf-8')
        print('removed', rel, line.strip())
    else:
        print('missing', rel, line.strip())
