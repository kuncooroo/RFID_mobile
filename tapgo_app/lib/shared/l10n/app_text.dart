import 'package:flutter/widgets.dart';

/// UI copy that follows the language saved in profile settings.
class AppText {
  const AppText(this.code);

  final String code;

  bool get isId => code == 'id';

  String t(String en, String id) => isId ? id : en;

  String get home => t('Home', 'Beranda');
  String get myOrder => t('My Order', 'Pesanan');
  String get favorite => t('Favorite', 'Favorit');
  String get myProfile => t('My Profile', 'Profil');
  String get experiences => t('Experiences', 'Experience');
  String get linkCard => t('Link card', 'Hubungkan kartu');
  String get editProfile => t('Edit Profile', 'Ubah profil');
  String get changePassword => t('Change Password', 'Ubah kata sandi');
  String get notifications => t('Notifications', 'Notifikasi');
  String get messages => t('Messages', 'Pesan');
  String get language => t('Language', 'Bahasa');
  String get security => t('Security', 'Keamanan');
  String get helpSupport => t('Help & Support', 'Bantuan');
  String get account => t('ACCOUNT', 'AKUN');
  String get preferences => t('PREFERENCES', 'PREFERENSI');
  String get support => t('SUPPORT', 'BANTUAN');
  String get getStarted => t('Get Started', 'Mulai');
  String get shopSmarter => t('Shop smarter.\nLive better.', 'Belanja lebih mudah.\nHidup lebih nyaman.');
  String get shopSmarterBody => t(
    'Discover curated fashion, trusted stores, and seamless checkout in one place.',
    'Temukan produk pilihan, toko terpercaya, dan checkout yang praktis dalam satu aplikasi.',
  );
  String get onboarding1Title => t(
    'Various Collections Of The Latest Products',
    'Koleksi produk terbaru',
  );
  String get onboarding1Body => t(
    'Browse new arrivals and find pieces that fit your style.',
    'Lihat produk baru dan temukan yang sesuai dengan gayamu.',
  );
  String get onboarding2Title => t(
    'Complete Collection Of Top Products',
    'Koleksi produk unggulan',
  );
  String get onboarding2Body => t(
    'Save favorites and come back to them any time.',
    'Simpan favorit dan buka lagi kapan saja.',
  );
  String get onboarding3Title => t(
    'Find The Best Choice For You',
    'Temukan pilihan terbaik',
  );
  String get onboarding3Body => t(
    'Pay in rupiah and keep your gate visits in one account.',
    'Bayar dengan rupiah dan simpan kunjungan gerbang di akun yang sama.',
  );
  String get emptyCartTitle => t('Your cart is empty', 'Keranjang masih kosong');
  String get emptyCartBody => t(
    'Find something you love and add it to your cart.',
    'Cari produk yang kamu suka, lalu masukkan ke keranjang.',
  );
  String get emptyFavoritesTitle => t('No favorites yet', 'Belum ada favorit');
  String get emptyFavoritesBody => t(
    'Tap the heart on products to save them here.',
    'Ketuk hati pada produk untuk menyimpannya di sini.',
  );
  String get emptyOrdersTitle => t('No orders yet', 'Belum ada pesanan');
  String get emptyOrdersBody => t(
    'Your active and past orders will appear here.',
    'Pesanan aktif dan riwayat pesanan akan muncul di sini.',
  );
  String get emptyHistoryTitle => t('No order history', 'Belum ada riwayat pesanan');
  String get emptyHistoryBody => t(
    'Your past orders will show up here.',
    'Pesanan yang sudah selesai akan muncul di sini.',
  );
  String get emptySearchTitle => t('No results found', 'Tidak ada hasil');
  String get emptySearchBody => t(
    'Try a different keyword or adjust your filters.',
    'Coba kata kunci lain atau ubah filter.',
  );
  String get emptyMessagesTitle => t('No messages yet', 'Belum ada pesan');
  String get emptyMessagesBody => t(
    'Start a conversation with a store to ask about products or orders.',
    'Mulai percakapan dengan toko untuk bertanya tentang produk atau pesanan.',
  );
  String get emptyNotificationsTitle => t('No notifications', 'Belum ada notifikasi');
  String get emptyNotificationsBody => t(
    'Updates about orders, chats, and offers will show up here.',
    'Update pesanan, chat, dan penawaran akan muncul di sini.',
  );
  String get emptyVisitsTitle => t('No visits yet', 'Belum ada kunjungan');
  String get emptyVisitsBody => t(
    'A successful gate tap with your card and balance shows up here.',
    'Tap kartu yang berhasil di gerbang akan muncul di sini.',
  );
  String get startShopping => t('Start Shopping', 'Mulai belanja');
  String get exploreProducts => t('Explore Products', 'Lihat produk');
  String get shopNow => t('Shop Now', 'Belanja sekarang');
  String get browseHome => t('Browse Home', 'Ke beranda');
  String get languageHint => t(
    'Choose your preferred language for the app.',
    'Pilih bahasa yang ingin dipakai di aplikasi.',
  );

  static AppText of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_AppTextScope>();
    return scope?.text ?? const AppText('en');
  }
}

class AppTextScope extends StatelessWidget {
  const AppTextScope({super.key, required this.text, required this.child});

  final AppText text;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _AppTextScope(text: text, child: child);
  }
}

class _AppTextScope extends InheritedWidget {
  const _AppTextScope({required this.text, required super.child});

  final AppText text;

  @override
  bool updateShouldNotify(_AppTextScope oldWidget) => oldWidget.text.code != text.code;
}
