enum KioskLang { id, en }

class KioskStrings {
  const KioskStrings(this.lang);

  final KioskLang lang;

  bool get isId => lang == KioskLang.id;

  String get brand => 'KUTUKU';

  String get welcomeTo => isId ? 'Halo, selamat datang di KUTUKU' : 'Hello, Welcome to KUTUKU';
  String get whatToday =>
      isId ? 'Mau apa hari ini?' : 'What do you want today?';
  String get tapMemberCard =>
      isId ? 'Tempel Kartu Member' : 'Tap Member Card';
  String get tapMemberCardBody => isId
      ? 'Gunakan kartu member Anda untuk melanjutkan'
      : 'Use your member card to continue';
  String get registerCardTitle => isId ? 'Daftar' : 'Register';
  String get registerCardBody => isId
      ? 'Buat profil member baru'
      : 'Create a new member profile';
  String get tapToCheckIn => tapMemberCardBody;
  String get tapCardHere => isId ? 'TEMPLEK KARTU DI SINI' : 'TAP CARD HERE';
  String get readyToScan => isId ? 'Siap memindai' : 'Ready to scan';
  String get readingCard => isId ? 'Membaca kartu...' : 'Reading card...';
  String get orDivider => isId ? 'Atau' : 'Or';
  String get registerNewMember =>
      isId ? 'Daftar Member Baru' : 'Register New Member';
  String get tapCardFirst => isId
      ? 'Silakan tempel kartu RFID baru Anda.'
      : 'Please tap your new RFID card.';
  String get tapCardAfterName => tapCardFirst;
  String get cardAlreadyRegistered => isId
      ? 'Kartu ini sudah terdaftar pada member lain.'
      : 'This card is already registered to a member.';
  String get needAssistance =>
      isId ? 'Butuh bantuan?' : 'Need help?';
  String get systemReady => isId ? 'Siap memindai' : 'Ready to scan';
  String get systemOffline =>
      isId ? 'Koneksi tidak tersedia' : 'Connection unavailable';
  String get systemProcessing => isId ? 'Memproses' : 'Processing';
  String get systemError => isId ? 'Terjadi masalah' : 'Error';
  String get tapCard =>
      isId ? 'Tempel kartu RFID Anda' : 'Tap your member card';
  String get holdCard =>
      isId ? 'Dekatkan kartu ke pembaca' : 'Hold your card near the reader';
  String get waitingCard => isId ? 'Menunggu kartu...' : 'Waiting for card...';
  String get checkingCard =>
      isId ? 'Memeriksa kartu Anda...' : 'Checking your card...';
  String get keepCardAway => isId
      ? 'Jauhkan kartu dari pembaca.'
      : 'Please keep your card away from the reader.';
  String get scanPageTitleVisit => isId ? 'Scan RFID' : 'RFID Scan';
  String get scanPageTitleRegister =>
      isId ? 'Daftar Member' : 'Register Member';
  String get scanInstructionTitle =>
      isId ? 'Tempelkan kartu RFID Anda' : 'Tap your RFID card';
  String get scanInstructionSubtitle => isId
      ? 'Pastikan kartu dekat dengan RFID reader'
      : 'Keep your card close to the RFID reader';
  String get scanRfidTitle => isId ? 'TEMPLEK KARTU' : 'TAP YOUR CARD';
  String get scanRfidDesc => isId
      ? 'Tempelkan kartu RFID ke reader untuk melanjutkan'
      : 'Hold your RFID card near the reader to continue';
  String get scanReadingTitle => isId ? 'MEMBACA...' : 'READING...';
  String get scanReadingDesc => isId
      ? 'Mohon tetap dekatkan kartu ke reader'
      : 'Please keep the card close to the reader';
  String get usageGuide =>
      isId ? 'Petunjuk Penggunaan' : 'How to use';
  List<String> get scanGuideSteps => isId
      ? const [
          'Dekatkan kartu RFID ke reader.',
          'Tunggu hingga sistem mendeteksi kartu.',
          'Sistem akan memverifikasi UID kartu.',
          'Lanjutkan langkah berikutnya di layar.',
        ]
      : const [
          'Hold your RFID card near the reader.',
          'Wait until the system detects the card.',
          'The system will verify the card UID.',
          'Continue with the next step shown on screen.',
        ];
  String get pleaseWait => isId ? 'Mohon tunggu' : 'Please wait';
  String get cancel => isId ? 'Batal' : 'Cancel';
  String get continueLabel => isId ? 'Lanjut' : 'Continue';
  String get start => isId ? 'Mulai' : 'Start';
  String get welcomeBack => isId ? 'Selamat datang kembali!' : 'Welcome Back!';
  String get memberId => 'Member ID';
  String get newCardDetected =>
      isId ? 'Kartu Baru Terdeteksi' : 'New Card Detected';
  String get newCardBody => isId
      ? 'Kartu ini belum terhubung ke member.\nIngin mendaftarkannya?'
      : "This card isn't connected\nto a member yet.\n\nWould you like to register it?";
  String get register => isId ? 'DAFTAR' : 'REGISTER';
  String get createProfile =>
      isId ? 'Buat Profil Member' : 'Create Your Member Profile';
  String get createProfileBody => isId
      ? 'Kartu sudah diverifikasi. Lanjutkan isi data member Anda.'
      : 'Card verified. Continue with your member details.';
  String get fullName => isId ? 'Nama lengkap' : 'Full Name';
  String get phone => isId ? 'Nomor telepon' : 'Phone Number';
  String get email => 'Email';
  String get contactHint => isId
      ? 'Isi nomor telepon atau email'
      : 'Enter a phone number or email';
  String get continueCta => isId ? 'LANJUT' : 'CONTINUE';
  String get back => isId ? 'Kembali' : 'Back';
  String stepOf(int n, int total) =>
      isId ? '$n dari $total' : '$n of $total';

  String get faceSetupTitle =>
      isId ? 'Siapkan Face ID Anda' : 'Set Up Your Face ID';
  String get faceSetupBody => isId
      ? 'Kami akan mengambil tiga foto singkat\nuntuk membuat identitas member Anda.'
      : "We'll take three quick photos\nto create your member identity.";
  String get faceOnceOnly => isId
      ? 'Ini hanya perlu dilakukan sekali.\nKunjungan berikutnya tidak perlu foto.'
      : "This only needs to be done once.\nYou won't need to take photos\nduring future visits.";
  String get faceRequiredTitle =>
      isId ? 'Face Enrollment Diperlukan' : 'Face Enrollment Required';
  String get faceRequiredBody => isId
      ? 'Akun Anda sudah ada, tetapi foto identitas belum lengkap.'
      : 'Your account exists, but identity photos are not complete yet.';

  String get lookStraight =>
      isId ? 'Lihat Lurus ke Depan' : 'Look Straight Ahead';
  String get lookStraightBody => isId
      ? 'Posisikan wajah di dalam bingkai\ndan lihat langsung ke kamera.'
      : 'Position your face inside the frame\nand look directly at the camera.';
  String get turnFaceRight =>
      isId ? 'Hadapkan Wajah ke Kanan' : 'Turn Your Face Right';
  String get turnFaceRightBody => isId
      ? 'Putar wajah perlahan ke kanan.'
      : 'Slowly turn your face to the right.';
  String get turnFaceLeft =>
      isId ? 'Hadapkan Wajah ke Kiri' : 'Turn Your Face Left';
  String get turnFaceLeftBody => isId
      ? 'Putar wajah perlahan ke kiri.'
      : 'Slowly turn your face to the left.';
  String get poseFront => isId ? 'DEPAN' : 'FRONT';
  String get poseRight => isId ? 'KANAN' : 'RIGHT';
  String get poseLeft => isId ? 'KIRI' : 'LEFT';
  String get keepFace =>
      isId ? 'Pastikan wajah ada di dalam bingkai.' : 'Keep your face inside the frame.';
  String get capture => isId ? 'Mengambil' : 'Capture';
  String get usePhoto => isId ? 'Gunakan foto' : 'Use photo';
  String get retake => isId ? 'Ambil ulang' : 'Retake';
  String get photoOk => isId ? 'Foto ini sudah oke?' : 'Is this photo okay?';

  String get faceReviewTitle =>
      isId ? 'Face Enrollment' : 'Face Enrollment';
  String get faceReviewBody => isId
      ? 'Foto identitas Anda siap.'
      : 'Your identity photos are ready.';
  String get completeEnrollment =>
      isId ? 'SELESAIKAN ENROLLMENT' : 'COMPLETE ENROLLMENT';
  String get savingIdentity =>
      isId ? 'Menyimpan identitas Anda...' : 'Saving your identity...';
  String get faceEnrollmentComplete =>
      isId ? 'Face Enrollment Selesai' : 'Face Enrollment Complete';
  String get faceEnrollmentCompleteBody => isId
      ? 'Profil member Anda siap.\nKembali ke beranda...'
      : 'Your member profile is ready.\nReturning to home...';

  String get recordingVisit =>
      isId ? 'Mencatat kunjungan...' : 'Recording your visit...';
  String get checkedIn => isId ? 'Anda sudah check-in!' : "You're Checked In";
  String welcomeName(String name) => name;
  String get youEarned => isId ? 'Anda mendapatkan' : 'You earned';
  String pointsPlus(int n) => '+$n ${isId ? 'POIN' : 'POINTS'}';
  String get points => isId ? 'POIN' : 'POINTS';
  String get totalBalance => isId ? 'Total Saldo' : 'Total Balance';
  String get yourTotal => isId ? 'Total' : 'Total';
  String get thanksVisit =>
      isId ? 'Terima kasih sudah berkunjung!' : 'Thanks for visiting!';
  String get alreadyGotDailyPoints => isId
      ? 'Check-in berhasil.\nPoin kunjungan hari ini sudah Anda terima.'
      : "Check-in successful.\nYou've already received\ntoday's visit points.";
  String returningIn(int sec) => isId
      ? 'Kembali ke beranda dalam $sec...'
      : 'Returning to home in $sec...';
  String get done => isId ? 'Selesai' : 'Done';

  String get alreadyCheckedIn =>
      isId ? 'Anda Sudah Check-in' : "You're Already Checked In";
  String alreadyCheckedInHi(String name) =>
      isId ? 'Halo, $name.' : 'Hi, $name.';
  String get alreadyCheckedInBody => isId
      ? 'Kunjungan Anda baru saja tercatat.\nTidak perlu menempel kartu lagi.'
      : 'Your visit was already recorded\na moment ago.\n\nNo need to tap again.';
  String get backHome => isId ? 'Kembali ke beranda' : 'Back to home';

  String get somethingWrong =>
      isId ? 'Terjadi kendala' : 'Something went wrong';
  String get couldNotCheckIn => isId
      ? 'Kunjungan belum bisa diselesaikan. Silakan coba lagi.'
      : "We couldn't complete your visit. Please try again.";
  String get tryAgain => isId ? 'Coba lagi' : 'Try again';
  String get connectionUnavailable =>
      isId ? 'Koneksi tidak tersedia' : 'Connection unavailable';
  String get cannotReach => isId
      ? 'Kiosk tidak dapat terhubung ke server saat ini.'
      : 'The kiosk cannot reach the server right now.';
  String get retry => isId ? 'Coba lagi' : 'Retry';
  String get cameraUnavailable =>
      isId ? 'Kamera tidak tersedia' : 'Camera unavailable';
  String get cameraUnavailableBody => isId
      ? 'Kami tidak dapat mengakses kamera.'
      : "We couldn't access the camera.";
  String get sessionExpired => isId ? 'Sesi berakhir' : 'Session expired';
  String get sessionExpiredBody => isId
      ? 'Demi privasi Anda, sesi ini telah ditutup.'
      : 'For your privacy, this session has been closed.';
  String get startAgain => isId ? 'Mulai lagi' : 'Start again';

  String get helpTitle => isId ? 'Ada Kendala?' : 'Having Trouble?';
  String get helpBody => isId
      ? '1. Tempelkan kartu di dekat pembaca RFID.\n2. Tahan sebentar.\n3. Tunggu hingga kiosk mengonfirmasi kartu Anda.'
      : '1. Place your card near the RFID reader.\n2. Hold it briefly.\n3. Wait until the kiosk confirms your card.';
  String get helpMore => isId
      ? 'Butuh bantuan lebih?\nHubungi petugas.'
      : 'Need more help?\nPlease contact staff.';
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

  // Legacy aliases used by older widgets during transition
  String get helloWelcome => welcomeTo;
  String get checkIn => tapMemberCard;
  String get needHelp => needAssistance;
  String get cardNotRegistered => newCardDetected;
  String get cardNotRegisteredBody => newCardBody;
  String get registerNow => register;
  String get createAccount => createProfile;
  String get whatName => fullName;
  String get contactInfo => contactHint;
  String get whatPhone => contactHint;
  String get reviewInfo => createProfileBody;
  String get createAccountCta => continueCta;
  String get confirmPresence => faceSetupTitle;
  String get needPhoto => faceSetupBody;
  String get lookAtCamera => lookStraightBody;
  String get turnRight => turnFaceRightBody;
  String get turnLeft => turnFaceLeftBody;
  String get uploadingEnrollment => savingIdentity;
  String get takePhoto => lookStraight;
  String get confirmingPresence => savingIdentity;
  String get checkingIn => recordingVisit;
  String get awardingPoints => recordingVisit;
  String get preparingCamera =>
      isId ? 'Menyiapkan kamera...' : 'Preparing camera...';
  String get cardReady => readyToScan;
}
