enum KioskLang { id, en }

class KioskStrings {
  const KioskStrings(this.lang);

  final KioskLang lang;

  bool get isId => lang == KioskLang.id;

  String get brand => 'KUTUKU';
  String get helloWelcome =>
      isId ? 'Halo, selamat datang di KUTUKU' : 'Hello, Welcome to KUTUKU';
  String get whatToday =>
      isId ? 'Mau apa hari ini?' : 'What do you want today?';
  String get checkIn => isId ? 'Check In' : 'Check In';
  String get register => isId ? 'Daftar' : 'Register';
  String get needHelp => isId ? 'Butuh bantuan?' : 'Need help?';
  String get systemReady => isId ? 'Sistem siap' : 'System Ready';
  String get systemOffline => isId ? 'Sistem offline' : 'System Offline';
  String get systemProcessing => isId ? 'Memproses' : 'Processing';
  String get systemError => isId ? 'Terjadi masalah' : 'Error';
  String get tapCard =>
      isId ? 'Tempel kartu RFID Anda' : 'Tap your RFID card';
  String get holdCard =>
      isId ? 'Dekatkan kartu ke pembaca' : 'Hold your card near the reader';
  String get waitingCard => isId ? 'Menunggu kartu...' : 'Waiting for card...';
  String get checkingCard =>
      isId ? 'Memeriksa kartu Anda...' : 'Checking your card...';
  String get pleaseWait => isId ? 'Mohon tunggu' : 'Please wait';
  String get cancel => isId ? 'Batal' : 'Cancel';
  String get continueLabel => isId ? 'Lanjut' : 'Continue';
  String get welcomeBack => isId ? 'Selamat datang kembali' : 'Welcome back';
  String get memberId => 'Member ID';
  String get cardReady =>
      isId ? 'Kartu Anda siap digunakan.' : 'Your card is ready.';
  String get cardNotRegistered =>
      isId ? 'Kartu belum terdaftar' : 'Card not registered';
  String get cardNotRegisteredBody => isId
      ? 'Kartu RFID ini belum terhubung ke akun member.'
      : 'This RFID card is not connected to a member account yet.';
  String get registerNow => isId ? 'Daftar sekarang' : 'Register now';
  String get createAccount =>
      isId ? 'Buat akun Anda' : 'Create your account';
  String get whatName => isId ? 'Siapa nama Anda?' : 'What is your name?';
  String get fullName => isId ? 'Nama lengkap' : 'Full name';
  String get contactInfo =>
      isId ? 'Informasi kontak' : 'Contact information';
  String get whatPhone =>
      isId ? 'Nomor telepon atau email Anda?' : 'What is your phone or email?';
  String get phone => isId ? 'Nomor telepon' : 'Phone number';
  String get email => 'Email';
  String get reviewInfo =>
      isId ? 'Periksa data Anda' : 'Review your information';
  String get createAccountCta =>
      isId ? 'Buat akun' : 'Create account';
  String get back => isId ? 'Kembali' : 'Back';
  String stepOf(int n, int total) =>
      isId ? '$n dari $total' : '$n of $total';
  String get confirmPresence =>
      isId ? 'Mari konfirmasi kehadiran Anda' : "Let's confirm you're here";
  String get needPhoto => isId
      ? 'Kami butuh foto singkat untuk memastikan Anda benar-benar di sini.'
      : 'We need a quick photo to confirm your presence.';
  String get lookAtCamera =>
      isId ? 'Hadap ke kamera.' : 'Please look at the camera.';
  String get takePhoto => isId ? 'Ambil foto Anda' : 'Take your photo';
  String get keepFace =>
      isId ? 'Pastikan wajah ada di dalam bingkai.' : 'Keep your face inside the frame.';
  String get photoOk => isId ? 'Foto ini sudah oke?' : 'Is this photo okay?';
  String get usePhoto => isId ? 'Gunakan foto' : 'Use photo';
  String get retake => isId ? 'Ambil ulang' : 'Retake';
  String get confirmingPresence =>
      isId ? 'Mengonfirmasi kehadiran...' : 'Confirming your presence...';
  String get checkingIn => isId ? 'Sedang check-in...' : 'Checking you in...';
  String get awardingPoints =>
      isId ? 'Menambahkan poin...' : 'Adding your points...';
  String get checkedIn => isId ? 'Anda sudah check-in!' : "You're checked in!";
  String welcomeName(String name) =>
      isId ? 'Selamat datang, $name.' : 'Welcome, $name.';
  String get youEarned => isId ? 'Anda mendapatkan' : 'You earned';
  String get points => isId ? 'POIN' : 'POINTS';
  String get yourTotal => isId ? 'Total Anda' : 'Your total';
  String get thanksVisit =>
      isId ? 'Terima kasih sudah berkunjung!' : 'Thanks for visiting!';
  String get done => isId ? 'Selesai' : 'Done';
  String get alreadyCheckedIn =>
      isId ? 'Anda sudah check-in' : "You're already checked in";
  String get alreadyCheckedInBody => isId
      ? 'Anda sudah check-in di lokasi ini hari ini. Poin tambahan tidak ditambahkan.'
      : 'You have already checked in at this location today. No additional points were added.';
  String get backHome => isId ? 'Kembali ke awal' : 'Back to home';
  String get somethingWrong =>
      isId ? 'Terjadi kendala' : 'Something went wrong';
  String get couldNotCheckIn => isId
      ? 'Check-in belum bisa diselesaikan. Silakan coba lagi.'
      : "We couldn't complete your check-in. Please try again.";
  String get tryAgain => isId ? 'Coba lagi' : 'Try again';
  String get connectionUnavailable =>
      isId ? 'Koneksi tidak tersedia' : 'Connection unavailable';
  String get cannotReach => isId
      ? 'Kiosk tidak dapat terhubung ke server saat ini. Coba lagi nanti.'
      : 'The kiosk cannot reach the server right now. Please try again later.';
  String get retry => isId ? 'Coba lagi' : 'Retry';
  String get cameraUnavailable =>
      isId ? 'Kamera tidak tersedia' : 'Camera unavailable';
  String get cameraUnavailableBody => isId
      ? 'Kami tidak dapat mengakses kamera. Pastikan kamera tidak dipakai aplikasi lain.'
      : "We couldn't access the camera. Please make sure the camera is not being used by another app.";
  String get sessionExpired => isId ? 'Sesi berakhir' : 'Session expired';
  String get sessionExpiredBody => isId
      ? 'Demi privasi Anda, sesi ini telah ditutup.'
      : 'For your privacy, this session has been closed.';
  String get startAgain => isId ? 'Mulai lagi' : 'Start again';
  String get helpTitle => isId ? 'Bantuan' : 'Help';
  String get helpBody => isId
      ? '1. Tempel kartu RFID pada pembaca.\n2. Member: foto, lalu check-in dan poin.\n3. Kartu baru: daftar, lalu foto kehadiran.\n4. Pastikan wajah terlihat di kamera.'
      : '1. Tap your RFID card on the reader.\n2. Members: take a photo, then check in for points.\n3. New cards: register, then take a presence photo.\n4. Keep your face inside the camera frame.';
  String get preparingCamera =>
      isId ? 'Menyiapkan kamera...' : 'Preparing camera...';
  String get capture => isId ? 'Mengambil' : 'Capture';
  String get nameRequired => isId ? 'Nama wajib diisi' : 'Name is required';
  String get contactRequired => isId
      ? 'Isi nomor telepon atau email'
      : 'Enter a phone number or email';
  String get phoneShort =>
      isId ? 'Nomor telepon terlalu pendek' : 'Phone number is too short';
  String get emailInvalid => isId ? 'Email tidak valid' : 'Email is not valid';
  String get rfidInactive =>
      isId ? 'Kartu RFID ini tidak aktif.' : 'This RFID card is inactive.';
  String get rfidInvalid =>
      isId ? 'Kartu tidak dikenali. Tempel ulang.' : 'This card could not be read. Please tap again.';
  String get lookupTimeout => isId
      ? 'Waktu habis. Tempel kartu Anda lagi.'
      : 'This is taking too long. Please tap your card again.';
  String get genericError => isId
      ? 'Terjadi kendala. Silakan coba lagi.'
      : 'Something went wrong. Please try again.';
  String get networkError => isId
      ? 'Tidak dapat terhubung ke server.'
      : 'Could not connect to the server.';
  String get checkInFailed =>
      isId ? 'Check-in belum berhasil.' : 'Check-in could not be completed.';
  String get bootConnecting =>
      isId ? 'Menghubungkan ke server...' : 'Connecting to the server...';
  String get bootConfig =>
      isId ? 'Memeriksa pengaturan...' : 'Checking configuration...';
  String get bootReady => isId ? 'Siap' : 'Ready';
  String get bootFailed =>
      isId ? 'Server belum siap' : 'Server is not ready';
}
