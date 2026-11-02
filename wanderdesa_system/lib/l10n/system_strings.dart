enum SystemLang { id, en }

class SystemStrings {
  const SystemStrings(this.lang);

  final SystemLang lang;

  bool get isId => lang == SystemLang.id;

  String get brand => 'WanderDesa';

  String get welcomeTo =>
      isId ? 'Halo, selamat datang di WanderDesa' : 'Hello, Welcome to WanderDesa';
  String get whatToday =>
      isId ? 'Mau apa hari ini?' : 'What do you want today?';
  String get tapMemberCard => isId ? 'Tempel Kartu Member' : 'Tap Member Card';
  String get tapMemberCardBody => isId
      ? 'Gunakan kartu member Anda untuk melanjutkan'
      : 'Use your member card to continue';
  String get registerCardTitle => isId ? 'Daftar' : 'Register';
  String get registerCardBody => isId
      ? 'Hubungkan kartu yang sudah ada ke identitas Anda'
      : 'Link an existing card to your identity';
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
  String get needAssistance => isId ? 'Butuh bantuan?' : 'Need help?';
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
      ? 'Dekatkan kartu ke RFID reader untuk melanjutkan'
      : 'Hold your card near the reader to continue';
  String get scanRfidTitle => isId ? 'TEMPLEK KARTU' : 'TAP YOUR CARD';
  String get scanRfidDesc => isId
      ? 'Tempelkan kartu RFID ke reader untuk melanjutkan'
      : 'Hold your RFID card near the reader to continue';
  String get scanReadingTitle => isId ? 'MEMBACA...' : 'READING...';
  String get scanReadingDesc => isId
      ? 'Mohon tetap dekatkan kartu ke reader'
      : 'Please keep the card close to the reader';
  String get usageGuide => isId ? 'Petunjuk Penggunaan' : 'How to use';
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
  String get welcomeBack =>
      isId ? 'Selamat Datang Kembali!' : 'Welcome Back!';
  String get memberId => 'Member ID';
  String get newCardDetected =>
      isId ? 'Kartu tidak dikenali' : 'Card not recognized';
  String get newCardBody => isId
      ? 'Kartu ini belum diterbitkan. WanderDesa memakai kartu yang sudah jadi. Isi saldonya, lalu tempelkan di gerbang.'
      : 'This card has not been issued. WanderDesa uses a ready-made card. Top it up, then tap it at the gate.';
  String get register => isId ? 'DAFTAR' : 'REGISTER';
  String get registerNowCta => isId ? 'Daftar Sekarang' : 'Register Now';
  String get identityLinkedTitle =>
      isId ? 'Identitas terhubung' : 'Identity linked';
  String get identityLinkedBody => isId
      ? 'Kartu yang sama tetap dipakai. Batas saldonya sekarang lebih besar.'
      : 'The same card stays in use. Its balance limit is now higher.';
  String get createProfile => isId ? 'Daftar' : 'Register';
  String get createProfileBody => isId
      ? 'Isi nama dan nomor telepon. Password dibuat sistem. Setelah terhubung, foto experience tersimpan ke akun ini.'
      : 'Enter your name and phone number. The system creates the password. After linking, experience photos are saved to this account.';
  String get fullName => isId ? 'Nama lengkap' : 'Full Name';
  String get ageLabel => isId ? 'Umur' : 'Age';
  String get originLabel => isId ? 'Asal' : 'Origin';
  String get genderLabel => isId ? 'Jenis kelamin' : 'Gender';
  String get male => isId ? 'Laki-laki' : 'Male';
  String get female => isId ? 'Perempuan' : 'Female';
  String get ageRequired => isId ? 'Umur wajib diisi.' : 'Age is required.';
  String get originRequired => isId ? 'Asal wajib diisi.' : 'Origin is required.';
  String get genderRequired =>
      isId ? 'Jenis kelamin wajib diisi.' : 'Gender is required.';
  String genderText(String? code) => switch (code) {
        'male' => male,
        'female' => female,
        _ => '—',
      };
  String get paymentDoneTitle =>
      isId ? 'Pembayaran berhasil' : 'Payment complete';
  String get paymentDoneBody => isId
      ? 'Saldo kartu sudah dipotong. Lanjut untuk foto experience.'
      : 'The card balance was charged. Continue to the experience photo.';
  String get takePhoto => isId ? 'AMBIL FOTO' : 'TAKE PHOTO';
  String get visitResultTitle => isId ? 'Hasil foto' : 'Photo result';
  String get phone => isId ? 'Nomor telepon' : 'Phone Number';
  String get email => 'Email';
  String get contactHint =>
      isId ? 'Isi nomor telepon atau email' : 'Enter a phone number or email';
  String get continueCta => isId ? 'LANJUT' : 'CONTINUE';
  String get back => isId ? 'Kembali' : 'Back';
  String stepOf(int n, int total) => isId ? '$n dari $total' : '$n of $total';

  String get faceSetupTitle =>
      isId ? 'Siapkan Face ID Anda' : 'Set Up Your Face ID';
  String get faceSetupBody => isId
      ? 'Kami akan mengambil tiga foto singkat\nuntuk membuat identitas member Anda.'
      : "We'll take three quick photos\nto create your member identity.";
  String get faceOnceOnly => isId
      ? 'Ini hanya perlu dilakukan sekali.\nKunjungan berikutnya tidak perlu foto.'
      : "This only needs to be done once.\nYou won't need to take photos\nduring future visits.";
  String get faceEnrollmentLabel => 'Face Enrollment';
  String get faceRequiredAccent => isId ? 'Diperlukan' : 'Required';
  String get faceRequiredTitle =>
      isId ? 'Face Enrollment Diperlukan' : 'Face Enrollment Required';
  String get faceRequiredBody => isId
      ? 'Akun Anda sudah ada, tetapi foto identitas belum lengkap.'
      : 'Your account exists, but identity photos are not complete yet.';
  String get photosNeeded =>
      isId ? 'Foto yang Dibutuhkan' : 'Photos Needed';
  String get photosNeededBody => isId
      ? 'Kami akan memandu Anda mengambil 3 sudut'
      : "We'll guide you to capture 3 angles";

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
  String get keepFace => isId
      ? 'Silakan posisikan wajah Anda di dalam bingkai'
      : 'Please position your face in the frame';
  String get takeAPhoto => isId ? 'Ambil foto' : 'Take a photo';
  String get capture => isId ? 'Mengambil' : 'Capture';
  String get usePhoto => isId ? 'Gunakan Foto Ini' : 'Use This Photo';
  String get retake => isId ? 'Ambil Ulang' : 'Retake';
  String get photoOk => isId ? 'Foto ini sudah oke?' : 'Is this photo okay?';
  String get photoOkBody => isId
      ? 'Silakan periksa foto Anda sebelum melanjutkan'
      : 'Please review your photo before continuing';

  String get faceReviewTitle =>
      isId ? 'Pendaftaran Wajah' : 'Face Enrollment';
  String get faceReviewBody => isId
      ? 'Foto identitas Anda sudah siap.'
      : 'Your identity photos are ready.';
  String get faceReviewSuccess => isId
      ? 'Semua foto berhasil diambil'
      : 'All photos captured successfully';
  String get completeEnrollment =>
      isId ? 'SELESAIKAN PENDAFTARAN' : 'COMPLETE ENROLLMENT';
  String get retakePhotos => isId ? 'AMBIL ULANG FOTO' : 'RETAKE PHOTOS';
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
  String get totalBalance => isId ? 'Total Poin' : 'Total Points';
  String get fareCharged => isId ? 'Saldo terpotong' : 'Balance charged';
  String get remainingBalance => isId ? 'Sisa saldo' : 'Remaining balance';
  String get cardNeedsLinkTitle =>
      isId ? 'Kartu belum dihubungkan' : 'Card is not linked yet';
  String get cardNeedsLinkBody => isId
      ? 'Foto experience hanya untuk kartu yang sudah terhubung ke pengunjung. Daftar sendiri di sini, atau hubungkan lewat kasir / aplikasi.'
      : 'Experience photos are only for a card linked to a visitor. Link it here, at the cashier, or in the app.';
  String get linkMyself => isId ? 'Daftar sendiri' : 'Link myself';
  String get captureVisitTitle =>
      isId ? 'Foto kunjungan' : 'Visit photo';
  String get captureVisitBody => isId
      ? 'Hadap kamera. Foto ini masuk ke experience Anda.'
      : 'Face the camera. This photo is saved to your experience.';
  String get insufficientBalance => isId
      ? 'Saldo tidak cukup untuk masuk. Isi saldo di loket.'
      : 'Not enough balance to enter. Please top up at the counter.';
  String get gateClosed => isId ? 'Gerbang tertutup' : 'Gate closed';
  String get yourTotal => isId ? 'Total' : 'Total';
  String get thanksVisit =>
      isId ? 'Terima kasih atas kunjungannya!' : 'Thanks for visiting!';
  String get thanksVisitBody => isId
      ? 'Kami berharap dapat bertemu Anda kembali.'
      : 'We hope to see you again soon.';
  String get alreadyGotDailyPoints => isId
      ? 'Check-in berhasil.\nPoin kunjungan hari ini sudah Anda terima.'
      : "Check-in successful.\nYou've already received\ntoday's visit points.";
  String returningIn(int sec) => isId
      ? 'Kembali ke beranda dalam $sec...'
      : 'Returning to home in $sec...';
  String get done => isId ? 'SELESAI' : 'DONE';

  String get alreadyCheckedIn =>
      isId ? 'Anda Sudah Check-in' : "You're Already Checked In";
  String alreadyCheckedInHi(String name) =>
      isId ? 'Hai, $name.' : 'Hi, $name.';
  String get alreadyCheckedInVisit => isId
      ? 'Kunjungan Anda sudah tercatat beberapa saat yang lalu.'
      : 'Your visit was already recorded a moment ago.';
  String get alreadyCheckedInTap => isId
      ? 'Tidak perlu menempelkan kartu lagi.'
      : 'No need to tap again.';
  String get alreadyCheckedInBody =>
      '${alreadyCheckedInVisit}\n\n$alreadyCheckedInTap';
  String get backHome => isId ? 'KEMBALI KE BERANDA' : 'BACK TO HOME';

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

  String get helpTitle => isId ? 'Butuh Bantuan?' : 'Need Help?';
  String get helpBody => isId
      ? '1. Tempelkan kartu di dekat pembaca RFID.\n2. Tahan sebentar.\n3. Tunggu hingga kiosk mengonfirmasi kartu Anda.'
      : '1. Place your card near the RFID reader.\n2. Hold it briefly.\n3. Wait until the kiosk confirms your card.';
  String get helpMore => isId
      ? 'Butuh bantuan lebih?\nHubungi petugas.'
      : 'Need more help?\nPlease contact staff.';
  String get nameRequired => isId ? 'Nama wajib diisi' : 'Name is required';
  String get phoneRequired =>
      isId ? 'Nomor telepon wajib diisi.' : 'Phone number is required.';
  String get contactRequired =>
      isId ? 'Isi nomor telepon atau email' : 'Enter a phone number or email';
  String get phoneShort =>
      isId ? 'Nomor telepon terlalu pendek' : 'Phone number is too short';
  String get emailInvalid => isId ? 'Email tidak valid' : 'Email is not valid';
  String get rfidInactive =>
      isId ? 'Kartu RFID ini tidak aktif.' : 'This RFID card is inactive.';
  String get rfidInvalid => isId
      ? 'Kartu tidak dikenali. Tempel ulang.'
      : 'This card could not be read. Please tap again.';
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
  String get bootFailed => isId ? 'Server belum siap' : 'Server is not ready';

  // Legacy aliases used by older widgets during transition
  String get helloWelcome => welcomeTo;
  String get checkIn => tapMemberCard;
  String get needHelp => needAssistance;
  String get cardNotRegistered => newCardDetected;
  String get cardNotRegisteredBody => newCardBody;
  String get registerNow => registerNowCta;
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
