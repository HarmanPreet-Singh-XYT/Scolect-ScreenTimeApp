// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appWindowTitle =>
      'Scolect - Lacak Waktu Layar & Penggunaan Aplikasi';

  @override
  String get appName => 'Scolect';

  @override
  String get appTitle => 'Waktu Layar Produktif';

  @override
  String get sidebarTitle => 'Waktu Layar';

  @override
  String get sidebarSubtitle => 'Sumber Terbuka';

  @override
  String get trayShowWindow => 'Tampilkan Jendela';

  @override
  String get trayStartFocusMode => 'Mulai Mode Fokus';

  @override
  String get trayStopFocusMode => 'Hentikan Mode Fokus';

  @override
  String get trayReports => 'Laporan';

  @override
  String get trayAlertsLimits => 'Peringatan & Batasan';

  @override
  String get trayApplications => 'Aplikasi';

  @override
  String get trayDisableNotifications => 'Nonaktifkan Notifikasi';

  @override
  String get trayEnableNotifications => 'Aktifkan Notifikasi';

  @override
  String get trayVersionPrefix => 'Versi: ';

  @override
  String trayVersion(String version) {
    return 'Versi: $version';
  }

  @override
  String get trayExit => 'Keluar';

  @override
  String get navOverview => 'Ringkasan';

  @override
  String get navApplications => 'Aplikasi';

  @override
  String get navAlertsLimits => 'Peringatan & Batasan';

  @override
  String get navReports => 'Laporan';

  @override
  String get navFocusMode => 'Mode Fokus';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get navHelp => 'Bantuan';

  @override
  String get helpTitle => 'Bantuan';

  @override
  String get faqCategoryGeneral => 'Pertanyaan Umum';

  @override
  String get faqCategoryApplications => 'Manajemen Aplikasi';

  @override
  String get faqCategoryReports => 'Analitik Penggunaan & Laporan';

  @override
  String get faqCategoryAlerts => 'Peringatan & Batasan';

  @override
  String get faqCategoryFocusMode => 'Mode Fokus & Timer Pomodoro';

  @override
  String get faqCategorySettings => 'Pengaturan & Kustomisasi';

  @override
  String get faqCategoryTroubleshooting => 'Pemecahan Masalah';

  @override
  String get faqGeneralQ1 => 'Bagaimana aplikasi ini melacak waktu layar?';

  @override
  String get faqGeneralA1 =>
      'Aplikasi memantau penggunaan perangkat Anda secara real-time, melacak waktu yang dihabiskan pada berbagai aplikasi. Ini memberikan wawasan komprehensif tentang kebiasaan digital Anda, termasuk total waktu layar, waktu produktif, dan penggunaan aplikasi spesifik.';

  @override
  String get faqGeneralQ2 => 'Apa yang membuat aplikasi \'Produktif\'?';

  @override
  String get faqGeneralA2 =>
      'Anda dapat menandai aplikasi sebagai produktif secara manual di bagian \'Aplikasi\'. Aplikasi produktif berkontribusi pada Skor Produktif Anda, yang menghitung persentase waktu layar yang dihabiskan untuk aplikasi terkait pekerjaan atau bermanfaat.';

  @override
  String get faqGeneralQ3 => 'Seberapa akurat pelacakan waktu layar?';

  @override
  String get faqGeneralA3 =>
      'Aplikasi menggunakan pelacakan tingkat sistem untuk memberikan pengukuran yang tepat dari penggunaan perangkat Anda. Ini menangkap waktu foreground untuk setiap aplikasi dengan dampak baterai minimal.';

  @override
  String get faqGeneralQ4 =>
      'Bisakah saya menyesuaikan kategorisasi aplikasi saya?';

  @override
  String get faqGeneralA4 =>
      'Tentu saja! Anda dapat membuat kategori khusus, menetapkan aplikasi ke kategori tertentu, dan dengan mudah memodifikasi penetapan ini di bagian \'Aplikasi\'. Ini membantu menciptakan analitik penggunaan yang lebih bermakna.';

  @override
  String get faqGeneralQ5 =>
      'Wawasan apa yang bisa saya dapatkan dari aplikasi ini?';

  @override
  String get faqGeneralA5 =>
      'Aplikasi menawarkan wawasan komprehensif termasuk Skor Produktif, pola penggunaan berdasarkan waktu, penggunaan aplikasi terperinci, pelacakan sesi fokus, dan analitik visual seperti grafik dan diagram lingkaran untuk membantu Anda memahami dan meningkatkan kebiasaan digital Anda.';

  @override
  String get faqAppsQ1 =>
      'Bagaimana cara menyembunyikan aplikasi tertentu dari pelacakan?';

  @override
  String get faqAppsA1 =>
      'Di bagian \'Aplikasi\', Anda dapat mengaktifkan/menonaktifkan visibilitas aplikasi.';

  @override
  String get faqAppsQ2 => 'Bisakah saya mencari dan memfilter aplikasi saya?';

  @override
  String get faqAppsA2 =>
      'Ya, bagian Aplikasi mencakup fungsi pencarian dan opsi filter. Anda dapat memfilter aplikasi berdasarkan kategori, status produktivitas, status pelacakan, dan visibilitas.';

  @override
  String get faqAppsQ3 => 'Opsi pengeditan apa yang tersedia untuk aplikasi?';

  @override
  String get faqAppsA3 =>
      'Untuk setiap aplikasi, Anda dapat mengedit: penetapan kategori, status produktivitas, pelacakan penggunaan, visibilitas dalam laporan, dan menetapkan batasan waktu harian individual.';

  @override
  String get faqAppsQ4 => 'Bagaimana kategori aplikasi ditentukan?';

  @override
  String get faqAppsA4 =>
      'Kategori awal disarankan oleh sistem, tetapi Anda memiliki kontrol penuh untuk membuat, memodifikasi, dan menetapkan kategori khusus berdasarkan alur kerja dan preferensi Anda.';

  @override
  String get faqReportsQ1 => 'Jenis laporan apa yang tersedia?';

  @override
  String get faqReportsA1 =>
      'Laporan mencakup: Total waktu layar, Waktu produktif, Aplikasi paling sering digunakan, Sesi fokus, Grafik waktu layar harian, Diagram lingkaran pembagian kategori, Penggunaan aplikasi terperinci, Tren penggunaan mingguan, dan Analisis pola penggunaan berdasarkan waktu.';

  @override
  String get faqReportsQ2 => 'Seberapa detail laporan penggunaan aplikasi?';

  @override
  String get faqReportsA2 =>
      'Laporan penggunaan aplikasi terperinci menunjukkan: Nama aplikasi, Kategori, Total waktu yang dihabiskan, Status produktivitas, dan menawarkan bagian \'Tindakan\' dengan wawasan lebih dalam seperti ringkasan penggunaan, batasan harian, tren penggunaan, dan metrik produktivitas.';

  @override
  String get faqReportsQ3 =>
      'Bisakah saya menganalisis tren penggunaan saya dari waktu ke waktu?';

  @override
  String get faqReportsA3 =>
      'Ya! Aplikasi menyediakan perbandingan minggu-ke-minggu, menampilkan grafik penggunaan selama beberapa minggu terakhir, penggunaan harian rata-rata, sesi terpanjang, dan total mingguan untuk membantu Anda melacak kebiasaan digital Anda.';

  @override
  String get faqReportsQ4 => 'Apa itu analisis \'Pola Penggunaan\'?';

  @override
  String get faqReportsA4 =>
      'Pola Penggunaan memecah waktu layar Anda menjadi segmen pagi, siang, sore, dan malam. Ini membantu Anda memahami kapan Anda paling aktif di perangkat dan mengidentifikasi area potensial untuk perbaikan.';

  @override
  String get faqAlertsQ1 => 'Seberapa detail batasan waktu layar?';

  @override
  String get faqAlertsA1 =>
      'Anda dapat menetapkan batasan waktu layar harian keseluruhan dan batasan aplikasi individual. Batasan dapat dikonfigurasi dalam jam dan menit, dengan opsi untuk mengatur ulang atau menyesuaikan sesuai kebutuhan.';

  @override
  String get faqAlertsQ2 => 'Opsi notifikasi apa yang tersedia?';

  @override
  String get faqAlertsA2 =>
      'Aplikasi menawarkan beberapa jenis notifikasi: Peringatan sistem saat Anda melebihi waktu layar, Peringatan sering pada interval yang dapat disesuaikan (1, 5, 15, 30, atau 60 menit), dan tombol untuk mode fokus, waktu layar, dan notifikasi khusus aplikasi.';

  @override
  String get faqAlertsQ3 => 'Bisakah saya menyesuaikan peringatan batasan?';

  @override
  String get faqAlertsA3 =>
      'Ya, Anda dapat menyesuaikan frekuensi peringatan, mengaktifkan/menonaktifkan jenis peringatan tertentu, dan menetapkan batasan berbeda untuk waktu layar keseluruhan dan aplikasi individual.';

  @override
  String get faqFocusQ1 => 'Jenis Mode Fokus apa yang tersedia?';

  @override
  String get faqFocusA1 =>
      'Mode yang tersedia termasuk Deep Work (sesi fokus lebih lama), Quick Tasks (pekerjaan singkat), dan Mode Membaca. Setiap mode membantu Anda menyusun waktu kerja dan istirahat secara efektif.';

  @override
  String get faqFocusQ2 => 'Seberapa fleksibel Timer Pomodoro?';

  @override
  String get faqFocusA2 =>
      'Timer sangat dapat disesuaikan. Anda dapat menyesuaikan durasi kerja, lama istirahat pendek, dan durasi istirahat panjang. Opsi tambahan termasuk mulai otomatis untuk sesi berikutnya dan pengaturan notifikasi.';

  @override
  String get faqFocusQ3 => 'Apa yang ditampilkan riwayat Mode Fokus?';

  @override
  String get faqFocusA3 =>
      'Riwayat Mode Fokus melacak sesi fokus harian, menampilkan jumlah sesi per hari, grafik tren, durasi sesi rata-rata, total waktu fokus, dan diagram lingkaran distribusi waktu yang memecah sesi kerja, istirahat pendek, dan istirahat panjang.';

  @override
  String get faqFocusQ4 => 'Bisakah saya melacak kemajuan sesi fokus saya?';

  @override
  String get faqFocusA4 =>
      'Aplikasi menampilkan UI timer melingkar dengan tombol putar/jeda, muat ulang, dan pengaturan. Anda dapat dengan mudah melacak dan mengelola sesi fokus Anda dengan kontrol intuitif.';

  @override
  String get faqSettingsQ1 => 'Opsi kustomisasi apa yang tersedia?';

  @override
  String get faqSettingsA1 =>
      'Kustomisasi mencakup pemilihan tema (Sistem, Terang, Gelap), pengaturan bahasa, perilaku startup, kontrol notifikasi komprehensif, dan opsi manajemen data seperti menghapus data atau mengatur ulang pengaturan.';

  @override
  String get faqSettingsQ2 =>
      'Bagaimana cara memberikan umpan balik atau melaporkan masalah?';

  @override
  String get faqSettingsA2 =>
      'Di bagian bawah bagian Pengaturan, Anda akan menemukan tombol untuk Laporkan Bug, Kirim Umpan Balik, atau Hubungi Dukungan. Ini akan mengarahkan Anda ke saluran dukungan yang sesuai.';

  @override
  String get faqSettingsQ3 =>
      'Apa yang terjadi ketika saya menghapus data saya?';

  @override
  String get faqSettingsA3 =>
      'Menghapus data akan mengatur ulang semua statistik penggunaan Anda, riwayat sesi fokus, dan pengaturan khusus. Ini berguna untuk memulai dari awal atau pemecahan masalah.';

  @override
  String get faqTroubleQ1 => 'Data tidak muncul, kesalahan hive tidak terbuka';

  @override
  String get faqTroubleA1 =>
      'Masalah ini diketahui, perbaikan sementara adalah menghapus data melalui pengaturan dan jika tidak berhasil maka pergi ke Dokumen dan hapus file berikut jika ada - harman_screentime_app_usage_box.hive dan harman_screentime_app_usage.lock, Anda juga disarankan untuk memperbarui aplikasi ke versi terbaru.';

  @override
  String get faqTroubleQ2 =>
      'Aplikasi terbuka setiap startup, apa yang harus dilakukan?';

  @override
  String get faqTroubleA2 =>
      'Ini adalah masalah yang diketahui yang terjadi pada Windows 10, perbaikan sementara adalah mengaktifkan Luncurkan sebagai Diminimalkan di pengaturan sehingga diluncurkan sebagai Diminimalkan.';

  @override
  String get usageAnalytics => 'Analitik Penggunaan';

  @override
  String get last7Days => '7 Hari Terakhir';

  @override
  String get lastMonth => 'Bulan Lalu';

  @override
  String get last3Months => '3 Bulan Terakhir';

  @override
  String get lifetime => 'Selamanya';

  @override
  String get custom => 'Kustom';

  @override
  String get loadingAnalyticsData => 'Memuat data analitik...';

  @override
  String get tryAgain => 'Coba Lagi';

  @override
  String get failedToInitialize =>
      'Gagal menginisialisasi analitik. Silakan mulai ulang aplikasi.';

  @override
  String unexpectedError(String error) {
    return 'Terjadi kesalahan tak terduga: $error. Silakan coba lagi nanti.';
  }

  @override
  String errorLoadingAnalytics(String error) {
    return 'Kesalahan memuat data analitik: $error. Silakan periksa koneksi Anda dan coba lagi.';
  }

  @override
  String get customDialogTitle => 'Kustom';

  @override
  String get dateRange => 'Rentang Tanggal:';

  @override
  String get specificDate => 'Tanggal Spesifik';

  @override
  String get startDate => 'Tanggal Mulai: ';

  @override
  String get endDate => 'Tanggal Akhir: ';

  @override
  String get date => 'Tanggal';

  @override
  String get cancel => 'Batal';

  @override
  String get apply => 'Terapkan';

  @override
  String get ok => 'OK';

  @override
  String get invalidDateRange => 'Rentang Tanggal Tidak Valid';

  @override
  String get startDateBeforeEndDate =>
      'Tanggal mulai harus sebelum atau sama dengan tanggal akhir.';

  @override
  String get totalScreenTime => 'Total Waktu Layar';

  @override
  String get productiveTime => 'Waktu Produktif';

  @override
  String get mostUsedApp => 'Aplikasi Paling Sering Digunakan';

  @override
  String get focusSessions => 'Sesi Fokus';

  @override
  String positiveComparison(String percent) {
    return '+$percent% vs periode sebelumnya';
  }

  @override
  String negativeComparison(String percent) {
    return '$percent% vs periode sebelumnya';
  }

  @override
  String iconLabel(String title) {
    return 'Ikon $title';
  }

  @override
  String get dailyScreenTime => 'WAKTU LAYAR HARIAN';

  @override
  String get categoryBreakdown => 'RINCIAN KATEGORI';

  @override
  String get noDataAvailable => 'Tidak ada data tersedia';

  @override
  String sectionLabel(String title) {
    return 'Bagian $title';
  }

  @override
  String get detailedApplicationUsage => 'Penggunaan Aplikasi Terperinci';

  @override
  String get searchApplications => 'Cari aplikasi';

  @override
  String get nameHeader => 'Nama';

  @override
  String get categoryHeader => 'Kategori';

  @override
  String get totalTimeHeader => 'Total Waktu';

  @override
  String get productivityHeader => 'Produktivitas';

  @override
  String get actionsHeader => 'Tindakan';

  @override
  String sortByOption(String option) {
    return 'Urutkan berdasarkan: $option';
  }

  @override
  String get sortByName => 'Nama';

  @override
  String get sortByCategory => 'Kategori';

  @override
  String get sortByUsage => 'Penggunaan';

  @override
  String get productive => 'Produktif';

  @override
  String get nonProductive => 'Non-Produktif';

  @override
  String get noApplicationsMatch =>
      'Tidak ada aplikasi yang cocok dengan kriteria pencarian Anda';

  @override
  String get viewDetails => 'Lihat detail';

  @override
  String get usageSummary => 'Ringkasan Penggunaan';

  @override
  String get usageOverPastWeek => 'Penggunaan Selama Seminggu Terakhir';

  @override
  String get usagePatternByTimeOfDay => 'Pola Penggunaan Berdasarkan Waktu';

  @override
  String get patternAnalysis => 'Analisis Pola';

  @override
  String get today => 'Hari Ini';

  @override
  String get dailyLimit => 'Batasan Harian';

  @override
  String get noLimit => 'Tidak ada batasan';

  @override
  String get usageTrend => 'Tren Penggunaan';

  @override
  String get productivity => 'Produktivitas';

  @override
  String get increasing => 'Meningkat';

  @override
  String get decreasing => 'Menurun';

  @override
  String get stable => 'Stabil';

  @override
  String get avgDailyUsage => 'Rata-rata Penggunaan Harian';

  @override
  String get longestSession => 'Sesi terlama';

  @override
  String get weeklyTotal => 'Total Mingguan';

  @override
  String get noHistoricalData => 'Tidak ada data historis tersedia';

  @override
  String get morning => 'Pagi (6-12)';

  @override
  String get afternoon => 'Siang (12-5)';

  @override
  String get evening => 'Sore (5-9)';

  @override
  String get night => 'Malam (9-6)';

  @override
  String get usageInsights => 'Wawasan Penggunaan';

  @override
  String get limitStatus => 'Status Batasan';

  @override
  String get close => 'Tutup';

  @override
  String primaryUsageTime(String appName, String timeOfDay) {
    return 'Anda terutama menggunakan $appName selama $timeOfDay.';
  }

  @override
  String significantIncrease(String percentage) {
    return 'Penggunaan Anda telah meningkat secara signifikan ($percentage%) dibandingkan periode sebelumnya.';
  }

  @override
  String get trendingUpward =>
      'Penggunaan Anda cenderung meningkat dibandingkan periode sebelumnya.';

  @override
  String significantDecrease(String percentage) {
    return 'Penggunaan Anda telah menurun secara signifikan ($percentage%) dibandingkan periode sebelumnya.';
  }

  @override
  String get trendingDownward =>
      'Penggunaan Anda cenderung menurun dibandingkan periode sebelumnya.';

  @override
  String get consistentUsage =>
      'Penggunaan Anda telah konsisten dibandingkan periode sebelumnya.';

  @override
  String get markedAsProductive =>
      'Ini ditandai sebagai aplikasi produktif dalam pengaturan Anda.';

  @override
  String get markedAsNonProductive =>
      'Ini ditandai sebagai aplikasi non-produktif dalam pengaturan Anda.';

  @override
  String mostActiveTime(String time) {
    return 'Waktu paling aktif Anda adalah sekitar $time.';
  }

  @override
  String get noLimitSet =>
      'Tidak ada batasan penggunaan yang ditetapkan untuk aplikasi ini.';

  @override
  String get limitReached =>
      'Anda telah mencapai batasan harian untuk aplikasi ini.';

  @override
  String aboutToReachLimit(String remainingTime) {
    return 'Anda hampir mencapai batasan harian dengan hanya $remainingTime tersisa.';
  }

  @override
  String percentOfLimitUsed(int percent, String remainingTime) {
    return 'Anda telah menggunakan $percent% dari batasan harian dengan $remainingTime tersisa.';
  }

  @override
  String remainingTime(String time) {
    return 'Anda memiliki $time tersisa dari batasan harian Anda.';
  }

  @override
  String get todayChart => 'Hari Ini';

  @override
  String hourPeriodAM(int hour) {
    return '$hour Pagi';
  }

  @override
  String hourPeriodPM(int hour) {
    return '$hour Sore';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}j ${minutes}m';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '${minutes}m';
  }

  @override
  String get alertsLimitsTitle => 'Peringatan & Batasan';

  @override
  String get notificationsSettings => 'Pengaturan Notifikasi';

  @override
  String get overallScreenTimeLimit => 'Batasan Waktu Layar Keseluruhan';

  @override
  String get applicationLimits => 'Batasan Aplikasi';

  @override
  String get popupAlerts => 'Peringatan Pop-up';

  @override
  String get frequentAlerts => 'Peringatan Sering';

  @override
  String get soundAlerts => 'Peringatan Suara';

  @override
  String get systemAlerts => 'Peringatan Sistem';

  @override
  String get dailyTotalLimit => 'Batasan Total Harian: ';

  @override
  String get hours => 'Jam';

  @override
  String get minutes => 'Menit';

  @override
  String get currentUsage => 'Penggunaan Saat Ini: ';

  @override
  String get tableName => 'Nama';

  @override
  String get tableCategory => 'Kategori';

  @override
  String get tableDailyLimit => 'Batasan Harian';

  @override
  String get tableCurrentUsage => 'Penggunaan Saat Ini';

  @override
  String get tableStatus => 'Status';

  @override
  String get tableActions => 'Tindakan';

  @override
  String get addLimit => 'Tambah Batasan';

  @override
  String get noApplicationsToDisplay => 'Tidak ada aplikasi untuk ditampilkan';

  @override
  String get statusActive => 'Aktif';

  @override
  String get statusOff => 'Mati';

  @override
  String get durationNone => 'Tidak ada';

  @override
  String get addApplicationLimit => 'Tambah Batasan Aplikasi';

  @override
  String get selectApplication => 'Pilih Aplikasi';

  @override
  String get selectApplicationPlaceholder => 'Pilih sebuah aplikasi';

  @override
  String get enableLimit => 'Aktifkan Batasan: ';

  @override
  String editLimitTitle(String appName) {
    return 'Edit Batasan: $appName';
  }

  @override
  String failedToLoadData(String error) {
    return 'Gagal memuat data: $error';
  }

  @override
  String get resetSettingsTitle => 'Atur Ulang Pengaturan?';

  @override
  String get resetSettingsContent =>
      'Jika Anda mengatur ulang pengaturan, Anda tidak akan dapat memulihkannya. Apakah Anda ingin mengatur ulang?';

  @override
  String get resetAll => 'Atur Ulang Semua';

  @override
  String get refresh => 'Segarkan';

  @override
  String get save => 'Simpan';

  @override
  String get add => 'Tambah';

  @override
  String get error => 'Kesalahan';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get applicationsTitle => 'Aplikasi';

  @override
  String get searchApplication => 'Cari Aplikasi';

  @override
  String get tracking => 'Dilacak';

  @override
  String get hiddenVisible => 'Tersembunyi/Terlihat';

  @override
  String get selectCategory => 'Pilih Kategori';

  @override
  String get allCategories => 'Semua';

  @override
  String get tableScreenTime => 'Waktu Layar';

  @override
  String get tableTracking => 'Pelacakan';

  @override
  String get tableHidden => 'Tersembunyi';

  @override
  String get tableEdit => 'Edit';

  @override
  String editAppTitle(String appName) {
    return 'Edit $appName';
  }

  @override
  String get categorySection => 'Kategori';

  @override
  String get customCategory => 'Kustom';

  @override
  String get customCategoryPlaceholder => 'Masukkan nama kategori kustom';

  @override
  String get uncategorized => 'Tidak Dikategorikan';

  @override
  String get isProductive => 'Produktif';

  @override
  String get trackUsage => 'Lacak Penggunaan';

  @override
  String get visibleInReports => 'Terlihat dalam Laporan';

  @override
  String get timeLimitsSection => 'Batasan Waktu';

  @override
  String get enableDailyLimit => 'Aktifkan Batasan Harian';

  @override
  String get setDailyTimeLimit => 'Atur batasan waktu harian:';

  @override
  String get saveChanges => 'Simpan Perubahan';

  @override
  String errorLoadingData(String error) {
    return 'Kesalahan memuat data ringkasan: $error';
  }

  @override
  String get focusModeTitle => 'Mode Fokus';

  @override
  String get historySection => 'Riwayat';

  @override
  String get trendsSection => 'Tren';

  @override
  String get timeDistributionSection => 'Distribusi Waktu';

  @override
  String get sessionHistorySection => 'Riwayat Sesi';

  @override
  String get workSession => 'Sesi Kerja';

  @override
  String get shortBreak => 'Istirahat Pendek';

  @override
  String get longBreak => 'Istirahat Panjang';

  @override
  String get dateHeader => 'Tanggal';

  @override
  String get durationHeader => 'Durasi';

  @override
  String get monday => 'Senin';

  @override
  String get tuesday => 'Selasa';

  @override
  String get wednesday => 'Rabu';

  @override
  String get thursday => 'Kamis';

  @override
  String get friday => 'Jumat';

  @override
  String get saturday => 'Sabtu';

  @override
  String get sunday => 'Minggu';

  @override
  String get focusModeSettingsTitle => 'Pengaturan Mode Fokus';

  @override
  String get modeCustom => 'Kustom';

  @override
  String get modeDeepWork => 'Deep Work (60 menit)';

  @override
  String get modeQuickTasks => 'Tugas Cepat (25 menit)';

  @override
  String get modeReading => 'Membaca (45 menit)';

  @override
  String workDurationLabel(int minutes) {
    return 'Durasi Kerja: $minutes menit';
  }

  @override
  String shortBreakLabel(int minutes) {
    return 'Istirahat Pendek';
  }

  @override
  String longBreakLabel(int minutes) {
    return 'Istirahat Panjang';
  }

  @override
  String get autoStartNextSession => 'Mulai otomatis sesi berikutnya';

  @override
  String get blockDistractions => 'Blokir gangguan selama mode fokus';

  @override
  String get enableNotifications => 'Aktifkan notifikasi';

  @override
  String get saved => 'Tersimpan';

  @override
  String errorLoadingFocusModeData(String error) {
    return 'Kesalahan memuat data mode fokus: $error';
  }

  @override
  String get overviewTitle => 'Ringkasan Hari Ini';

  @override
  String get startFocusMode => 'Mulai Mode Fokus';

  @override
  String get loadingProductivityData => 'Memuat data produktivitas Anda...';

  @override
  String get noActivityDataAvailable => 'Belum ada data aktivitas tersedia';

  @override
  String get startUsingApplications =>
      'Mulai gunakan aplikasi Anda untuk melacak waktu layar dan produktivitas.';

  @override
  String get refreshData => 'Segarkan Data';

  @override
  String get topApplications => 'Aplikasi Teratas';

  @override
  String get noAppUsageDataAvailable =>
      'Belum ada data penggunaan aplikasi tersedia';

  @override
  String get noApplicationDataAvailable => 'Tidak ada data aplikasi tersedia';

  @override
  String get noCategoryDataAvailable => 'Tidak ada data kategori tersedia';

  @override
  String get noApplicationLimitsSet =>
      'Tidak ada batasan aplikasi yang ditetapkan';

  @override
  String get screenLabel => 'Layar';

  @override
  String get timeLabel => 'Waktu';

  @override
  String get productiveLabel => 'Produktif';

  @override
  String get scoreLabel => 'Skor';

  @override
  String get defaultNone => 'Tidak ada';

  @override
  String get defaultTime => '0j 0m';

  @override
  String get defaultCount => '0';

  @override
  String get unknownApp => 'Tidak dikenal';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get generalSection => 'Umum';

  @override
  String get notificationsSection => 'Notifikasi';

  @override
  String get dataSection => 'Data';

  @override
  String get versionSection => 'Versi';

  @override
  String get languageTitle => 'Bahasa';

  @override
  String get languageDescription => 'Bahasa aplikasi';

  @override
  String get startupBehaviourTitle => 'Perilaku Startup';

  @override
  String get startupBehaviourDescription => 'Luncurkan saat startup OS';

  @override
  String get launchMinimizedTitle => 'Luncurkan sebagai Diminimalkan';

  @override
  String get launchMinimizedDescription =>
      'Mulai aplikasi di System Tray (Direkomendasikan untuk Windows 10)';

  @override
  String get notificationsTitle => 'Notifikasi';

  @override
  String get notificationsAllDescription => 'Semua notifikasi aplikasi';

  @override
  String get focusModeNotificationsTitle => 'Mode Fokus';

  @override
  String get focusModeNotificationsDescription =>
      'Semua Notifikasi untuk mode fokus';

  @override
  String get screenTimeNotificationsTitle => 'Waktu Layar';

  @override
  String get screenTimeNotificationsDescription =>
      'Semua Notifikasi untuk pembatasan waktu layar';

  @override
  String get appScreenTimeNotificationsTitle => 'Waktu Layar Aplikasi';

  @override
  String get appScreenTimeNotificationsDescription =>
      'Semua Notifikasi untuk pembatasan waktu layar aplikasi';

  @override
  String get frequentAlertsTitle => 'Interval Peringatan Sering';

  @override
  String get frequentAlertsDescription =>
      'Atur interval untuk notifikasi sering (menit)';

  @override
  String get clearDataTitle => 'Hapus Data';

  @override
  String get clearDataDescription =>
      'Hapus semua riwayat dan data terkait lainnya';

  @override
  String get resetSettingsTitle2 => 'Atur Ulang Pengaturan';

  @override
  String get resetSettingsDescription => 'Atur ulang semua pengaturan';

  @override
  String get versionTitle => 'Versi';

  @override
  String get versionDescription => 'Versi aplikasi saat ini';

  @override
  String get contactButton => 'Kontak';

  @override
  String get reportBugButton => 'Laporkan Bug';

  @override
  String get submitFeedbackButton => 'Kirim Umpan Balik';

  @override
  String get githubButton => 'Github';

  @override
  String get clearDataDialogTitle => 'Hapus Data?';

  @override
  String get clearDataDialogContent =>
      'Ini akan menghapus semua riwayat dan data terkait. Anda tidak akan dapat memulihkannya. Apakah Anda ingin melanjutkan?';

  @override
  String get clearDataButtonLabel => 'Hapus Data';

  @override
  String get resetSettingsDialogTitle => 'Atur Ulang Pengaturan?';

  @override
  String get resetSettingsDialogContent =>
      'Ini akan mengatur ulang semua pengaturan ke nilai default. Apakah Anda ingin melanjutkan?';

  @override
  String get resetButtonLabel => 'Atur Ulang';

  @override
  String get cancelButton => 'Batal';

  @override
  String couldNotLaunchUrl(String url) {
    return 'Tidak dapat membuka $url';
  }

  @override
  String errorMessage(String message) {
    return 'Kesalahan: $message';
  }

  @override
  String get chart_focusTrends => 'Tren Fokus';

  @override
  String get chart_sessionCount => 'Jumlah Sesi';

  @override
  String get chart_avgDuration => 'Rata-rata Durasi';

  @override
  String get chart_totalFocus => 'Total Fokus';

  @override
  String get chart_yAxis_sessions => 'Sesi';

  @override
  String get chart_yAxis_minutes => 'Menit';

  @override
  String get chart_yAxis_value => 'Nilai';

  @override
  String get chart_monthOverMonthChange => 'Perubahan bulan ke bulan: ';

  @override
  String get chart_customRange => 'Rentang Kustom';

  @override
  String get day_monday => 'Senin';

  @override
  String get day_mondayShort => 'Sen';

  @override
  String get day_mondayAbbr => 'Sn';

  @override
  String get day_tuesday => 'Selasa';

  @override
  String get day_tuesdayShort => 'Sel';

  @override
  String get day_tuesdayAbbr => 'Sl';

  @override
  String get day_wednesday => 'Rabu';

  @override
  String get day_wednesdayShort => 'Rab';

  @override
  String get day_wednesdayAbbr => 'Rb';

  @override
  String get day_thursday => 'Kamis';

  @override
  String get day_thursdayShort => 'Kam';

  @override
  String get day_thursdayAbbr => 'Km';

  @override
  String get day_friday => 'Jumat';

  @override
  String get day_fridayShort => 'Jum';

  @override
  String get day_fridayAbbr => 'Jm';

  @override
  String get day_saturday => 'Sabtu';

  @override
  String get day_saturdayShort => 'Sab';

  @override
  String get day_saturdayAbbr => 'Sb';

  @override
  String get day_sunday => 'Minggu';

  @override
  String get day_sundayShort => 'Min';

  @override
  String get day_sundayAbbr => 'Mg';

  @override
  String time_hours(int count) {
    return '${count}j';
  }

  @override
  String time_hoursMinutes(int hours, int minutes) {
    return '${hours}j ${minutes}m';
  }

  @override
  String time_minutesFormat(String count) {
    return '$count menit';
  }

  @override
  String tooltip_dateScreenTime(String date, int hours, int minutes) {
    return '$date: ${hours}j ${minutes}m';
  }

  @override
  String tooltip_hoursFormat(String count) {
    return '$count jam';
  }

  @override
  String get month_january => 'Januari';

  @override
  String get month_januaryShort => 'Jan';

  @override
  String get month_february => 'Februari';

  @override
  String get month_februaryShort => 'Feb';

  @override
  String get month_march => 'Maret';

  @override
  String get month_marchShort => 'Mar';

  @override
  String get month_april => 'April';

  @override
  String get month_aprilShort => 'Apr';

  @override
  String get month_may => 'Mei';

  @override
  String get month_mayShort => 'Mei';

  @override
  String get month_june => 'Juni';

  @override
  String get month_juneShort => 'Jun';

  @override
  String get month_july => 'Juli';

  @override
  String get month_julyShort => 'Jul';

  @override
  String get month_august => 'Agustus';

  @override
  String get month_augustShort => 'Agu';

  @override
  String get month_september => 'September';

  @override
  String get month_septemberShort => 'Sep';

  @override
  String get month_october => 'Oktober';

  @override
  String get month_octoberShort => 'Okt';

  @override
  String get month_november => 'November';

  @override
  String get month_novemberShort => 'Nov';

  @override
  String get month_december => 'Desember';

  @override
  String get month_decemberShort => 'Des';

  @override
  String get categoryAll => 'Semua';

  @override
  String get categoryProductivity => 'Produktivitas';

  @override
  String get categoryDevelopment => 'Pengembangan';

  @override
  String get categorySocialMedia => 'Media Sosial';

  @override
  String get categoryEntertainment => 'Hiburan';

  @override
  String get categoryGaming => 'Permainan';

  @override
  String get categoryCommunication => 'Komunikasi';

  @override
  String get categoryWebBrowsing => 'Penjelajahan Web';

  @override
  String get categoryCreative => 'Kreatif';

  @override
  String get categoryEducation => 'Pendidikan';

  @override
  String get categoryUtility => 'Utilitas';

  @override
  String get categoryUncategorized => 'Tidak Dikategorikan';

  @override
  String get appMicrosoftWord => 'Microsoft Word';

  @override
  String get appExcel => 'Excel';

  @override
  String get appPowerPoint => 'PowerPoint';

  @override
  String get appGoogleDocs => 'Google Docs';

  @override
  String get appNotion => 'Notion';

  @override
  String get appEvernote => 'Evernote';

  @override
  String get appTrello => 'Trello';

  @override
  String get appAsana => 'Asana';

  @override
  String get appSlack => 'Slack';

  @override
  String get appMicrosoftTeams => 'Microsoft Teams';

  @override
  String get appZoom => 'Zoom';

  @override
  String get appGoogleCalendar => 'Google Calendar';

  @override
  String get appAppleCalendar => 'Kalender';

  @override
  String get appVisualStudioCode => 'Visual Studio Code';

  @override
  String get appTerminal => 'Terminal';

  @override
  String get appCommandPrompt => 'Command Prompt';

  @override
  String get appChrome => 'Chrome';

  @override
  String get appFirefox => 'Firefox';

  @override
  String get appSafari => 'Safari';

  @override
  String get appEdge => 'Edge';

  @override
  String get appOpera => 'Opera';

  @override
  String get appBrave => 'Brave';

  @override
  String get appNetflix => 'Netflix';

  @override
  String get appYouTube => 'YouTube';

  @override
  String get appSpotify => 'Spotify';

  @override
  String get appAppleMusic => 'Apple Music';

  @override
  String get appCalculator => 'Kalkulator';

  @override
  String get appNotes => 'Catatan';

  @override
  String get appSystemPreferences => 'Preferensi Sistem';

  @override
  String get appTaskManager => 'Task Manager';

  @override
  String get appFileExplorer => 'File Explorer';

  @override
  String get appDropbox => 'Dropbox';

  @override
  String get appGoogleDrive => 'Google Drive';

  @override
  String get loadingApplication => 'Memuat aplikasi...';

  @override
  String get loadingData => 'Memuat data...';

  @override
  String get reportsError => 'Kesalahan';

  @override
  String get reportsRetry => 'Coba Lagi';

  @override
  String get backupRestoreSection => 'Cadangan & Pemulihan';

  @override
  String get backupRestoreTitle => 'Cadangan & Pemulihan';

  @override
  String get exportDataTitle => 'Ekspor Data';

  @override
  String get exportDataDescription => 'Buat cadangan semua data Anda';

  @override
  String get importDataTitle => 'Impor Data';

  @override
  String get importDataDescription => 'Pulihkan dari file cadangan';

  @override
  String get exportButton => 'Ekspor';

  @override
  String get importButton => 'Impor';

  @override
  String get closeButton => 'Tutup';

  @override
  String get noButton => 'Tidak';

  @override
  String get shareButton => 'Bagikan';

  @override
  String get exportStarting => 'Memulai ekspor...';

  @override
  String get exportSuccessful => 'Ekspor Berhasil';

  @override
  String get exportFailed => 'Ekspor Gagal';

  @override
  String get exportComplete => 'Ekspor Selesai';

  @override
  String get shareBackupQuestion =>
      'Apakah Anda ingin membagikan file cadangan?';

  @override
  String get importStarting => 'Memulai impor...';

  @override
  String get importSuccessful => 'Impor berhasil!';

  @override
  String get importFailed => 'Impor gagal';

  @override
  String get importOptionsTitle => 'Opsi Impor';

  @override
  String get importOptionsQuestion => 'Bagaimana Anda ingin mengimpor data?';

  @override
  String get replaceModeTitle => 'Ganti';

  @override
  String get replaceModeDescription => 'Ganti semua data yang ada';

  @override
  String get mergeModeTitle => 'Gabung';

  @override
  String get mergeModeDescription => 'Gabungkan dengan data yang ada';

  @override
  String get appendModeTitle => 'Tambah';

  @override
  String get appendModeDescription => 'Hanya tambahkan catatan baru';

  @override
  String get warningTitle => '⚠️ Peringatan';

  @override
  String get replaceWarningMessage =>
      'Ini akan mengganti SEMUA data Anda yang ada. Apakah Anda yakin ingin melanjutkan?';

  @override
  String get replaceAllButton => 'Ganti Semua';

  @override
  String get fileLabel => 'File';

  @override
  String get sizeLabel => 'Ukuran';

  @override
  String get recordsLabel => 'Catatan';

  @override
  String get usageRecordsLabel => 'Catatan penggunaan';

  @override
  String get focusSessionsLabel => 'Sesi fokus';

  @override
  String get appMetadataLabel => 'Metadata aplikasi';

  @override
  String get updatedLabel => 'Diperbarui';

  @override
  String get skippedLabel => 'Dilewati';

  @override
  String get faqSettingsQ4 =>
      'Bagaimana cara memulihkan atau mengekspor data saya?';

  @override
  String get faqSettingsA4 =>
      'Anda dapat pergi ke pengaturan, dan di sana Anda akan menemukan bagian Cadangan & Pemulihan. Anda dapat mengekspor atau mengimpor data dari sini, perhatikan bahwa file data yang diekspor disimpan di Dokumen pada Folder Scolect-Backups dan hanya file ini yang dapat digunakan untuk memulihkan data, bukan file lain.';

  @override
  String get faqGeneralQ6 =>
      'Bagaimana cara mengubah bahasa dan bahasa apa yang tersedia, juga bagaimana jika saya menemukan terjemahan yang salah?';

  @override
  String get faqGeneralA6 =>
      'Bahasa dapat diubah melalui bagian Pengaturan Umum, semua bahasa yang tersedia tercantum di sana, Anda dapat meminta terjemahan dengan mengklik Kontak dan mengirim permintaan Anda dengan bahasa yang diberikan. Ketahuilah bahwa terjemahan bisa salah karena dihasilkan oleh AI dari bahasa Inggris dan jika Anda ingin melaporkan maka Anda dapat melaporkan melalui laporkan bug, atau kontak, atau jika Anda seorang pengembang maka buka issue di Github. Kontribusi mengenai bahasa juga diterima!';

  @override
  String get faqGeneralQ7 =>
      'Bagaimana jika saya menemukan terjemahan yang salah?';

  @override
  String get faqGeneralA7 =>
      'Terjemahan bisa salah karena dihasilkan oleh AI dari bahasa Inggris dan jika Anda ingin melaporkan maka Anda dapat melaporkan melalui laporkan bug, atau kontak, atau jika Anda seorang pengembang maka buka issue di Github. Kontribusi mengenai bahasa juga diterima!';

  @override
  String get activityTrackingSection => 'Pelacakan Aktivitas';

  @override
  String get idleDetectionTitle => 'Deteksi Idle';

  @override
  String get idleDetectionDescription => 'Berhenti melacak saat tidak aktif';

  @override
  String get idleTimeoutTitle => 'Batas Waktu Idle';

  @override
  String idleTimeoutDescription(String timeout) {
    return 'Waktu sebelum dianggap idle ($timeout)';
  }

  @override
  String get advancedWarning =>
      'Fitur lanjutan dapat meningkatkan penggunaan sumber daya. Aktifkan hanya jika diperlukan.';

  @override
  String get monitorAudioTitle => 'Pantau Audio Sistem';

  @override
  String get monitorAudioDescription =>
      'Deteksi aktivitas dari pemutaran audio';

  @override
  String get audioSensitivityTitle => 'Sensitivitas Audio';

  @override
  String audioSensitivityDescription(String value) {
    return 'Ambang batas deteksi ($value)';
  }

  @override
  String get monitorControllersTitle => 'Pantau Kontroler Game';

  @override
  String get monitorControllersDescription => 'Deteksi kontroler Xbox/XInput';

  @override
  String get monitorHIDTitle => 'Pantau Perangkat HID';

  @override
  String get monitorHIDDescription =>
      'Deteksi roda kemudi, tablet, perangkat khusus';

  @override
  String get setIdleTimeoutTitle => 'Atur Batas Waktu Idle';

  @override
  String get idleTimeoutDialogDescription =>
      'Pilih berapa lama menunggu sebelum menganggap Anda idle:';

  @override
  String get seconds30 => '30 detik';

  @override
  String get minute1 => '1 menit';

  @override
  String get minutes2 => '2 menit';

  @override
  String get minutes5 => '5 menit';

  @override
  String get minutes10 => '10 menit';

  @override
  String get customOption => 'Kustom';

  @override
  String get customDurationTitle => 'Durasi Kustom';

  @override
  String get minutesLabel => 'Menit';

  @override
  String get secondsLabel => 'Detik';

  @override
  String get minAbbreviation => 'mnt';

  @override
  String get secAbbreviation => 'dtk';

  @override
  String totalLabel(String duration) {
    return 'Total: $duration';
  }

  @override
  String minimumError(String value) {
    return 'Minimum adalah $value';
  }

  @override
  String maximumError(String value) {
    return 'Maksimum adalah $value';
  }

  @override
  String rangeInfo(String min, String max) {
    return 'Rentang: $min - $max';
  }

  @override
  String get saveButton => 'Simpan';

  @override
  String timeFormatSeconds(int seconds) {
    return '${seconds}dtk';
  }

  @override
  String get timeFormatMinute => '1 mnt';

  @override
  String timeFormatMinutes(int minutes) {
    return '$minutes mnt';
  }

  @override
  String timeFormatMinutesSeconds(int minutes, int seconds) {
    return '$minutes mnt ${seconds}dtk';
  }

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeDescription => 'Tema warna aplikasi';

  @override
  String get voiceGenderTitle => 'Jenis Kelamin Suara';

  @override
  String get voiceGenderDescription =>
      'Pilih jenis kelamin suara untuk notifikasi timer';

  @override
  String get voiceGenderMale => 'Pria';

  @override
  String get voiceGenderFemale => 'Wanita';

  @override
  String get alertsLimitsSubtitle =>
      'Kelola batas waktu layar dan notifikasi Anda';

  @override
  String get applicationsSubtitle => 'Kelola aplikasi yang dilacak';

  @override
  String applicationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aplikasi',
    );
    return '$_temp0';
  }

  @override
  String get noApplicationsFound => 'Tidak ada aplikasi ditemukan';

  @override
  String get tryAdjustingFilters => 'Coba sesuaikan filter Anda';

  @override
  String get configureAppSettings => 'Konfigurasi pengaturan aplikasi';

  @override
  String get behaviorSection => 'Perilaku';

  @override
  String helpSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pertanyaan di 7 kategori',
    );
    return '$_temp0';
  }

  @override
  String get searchForHelp => 'Cari bantuan...';

  @override
  String get quickNavGeneral => 'Umum';

  @override
  String get quickNavApps => 'Aplikasi';

  @override
  String get quickNavReports => 'Laporan';

  @override
  String get quickNavFocus => 'Fokus';

  @override
  String get noResultsFound => 'Tidak ada hasil ditemukan';

  @override
  String get tryDifferentKeywords => 'Coba cari dengan kata kunci yang berbeda';

  @override
  String get clearSearch => 'Hapus Pencarian';

  @override
  String get greetingMorning => 'Selamat pagi! Ini ringkasan aktivitas Anda.';

  @override
  String get greetingAfternoon =>
      'Selamat siang! Ini ringkasan aktivitas Anda.';

  @override
  String get greetingEvening => 'Selamat malam! Ini ringkasan aktivitas Anda.';

  @override
  String get screenTimeProgress => 'Waktu\nLayar';

  @override
  String get productiveScoreProgress => 'Skor\nProduktivitas';

  @override
  String get focusModeSubtitle => 'Tetap fokus, jadilah produktif';

  @override
  String get thisWeek => 'Minggu Ini';

  @override
  String get sessions => 'Sesi';

  @override
  String get totalTime => 'Total Waktu';

  @override
  String get avgLength => 'Rata-rata Durasi';

  @override
  String get focusTime => 'Waktu Fokus';

  @override
  String get paused => 'Dijeda';

  @override
  String get shortBreakStatus => 'Istirahat Pendek';

  @override
  String get longBreakStatus => 'Istirahat Panjang';

  @override
  String get readyToFocus => 'Siap untuk Fokus';

  @override
  String get focus => 'Fokus';

  @override
  String get restartSession => 'Mulai Ulang Sesi';

  @override
  String get skipToNext => 'Lompat ke Berikutnya';

  @override
  String get settings => 'Pengaturan';

  @override
  String sessionsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesi selesai',
    );
    return '$_temp0';
  }

  @override
  String get focusModePreset => 'Preset Mode Fokus';

  @override
  String get focusDuration => 'Durasi Fokus';

  @override
  String minutesFormat(int minutes) {
    return '$minutes mnt';
  }

  @override
  String get shortBreakDuration => 'Istirahat Pendek';

  @override
  String get longBreakDuration => 'Istirahat Panjang';

  @override
  String get enableSounds => 'Aktifkan Suara';

  @override
  String get focus_mode_this_week => 'Minggu Ini';

  @override
  String get focus_mode_best_day => 'Hari Terbaik';

  @override
  String focus_mode_sessions_count(int count) {
    return '$count sesi';
  }

  @override
  String get focus_mode_no_data_yet => 'Belum ada data';

  @override
  String get chart_current => 'Saat Ini';

  @override
  String get chart_previous => 'Sebelumnya';

  @override
  String get permission_error => 'Kesalahan Izin';

  @override
  String get notification_permission_denied => 'Izin Notifikasi Ditolak';

  @override
  String get notification_permission_denied_message =>
      'ScreenTime memerlukan izin notifikasi untuk mengirimkan peringatan dan pengingat.\n\nApakah Anda ingin membuka Pengaturan Sistem untuk mengaktifkan notifikasi?';

  @override
  String get notification_permission_denied_hint =>
      'Buka Pengaturan Sistem untuk mengaktifkan notifikasi ScreenTime.';

  @override
  String get notification_permission_required => 'Izin Notifikasi Diperlukan';

  @override
  String get notification_permission_required_message =>
      'ScreenTime memerlukan izin untuk mengirimkan notifikasi kepada Anda.';

  @override
  String get open_settings => 'Buka Pengaturan';

  @override
  String get allow_notifications => 'Izinkan Notifikasi';

  @override
  String get permission_allowed => 'Diizinkan';

  @override
  String get permission_denied => 'Ditolak';

  @override
  String get permission_not_set => 'Tidak Diatur';

  @override
  String get on => 'Aktif';

  @override
  String get off => 'Nonaktif';

  @override
  String get enable_notification_permission_hint =>
      'Aktifkan izin notifikasi untuk menerima peringatan';

  @override
  String minutes_format(int minutes) {
    return '$minutes menit';
  }

  @override
  String get chart_average => 'Rata-rata';

  @override
  String get chart_peak => 'Puncak';

  @override
  String get chart_lowest => 'Terendah';

  @override
  String get active => 'Aktif';

  @override
  String get disabled => 'Dinonaktifkan';

  @override
  String get advanced_options => 'Opsi Lanjutan';

  @override
  String get sync_ready => 'Sinkronisasi Siap';

  @override
  String get success => 'Sukses';

  @override
  String get destructive_badge => 'Destruktif';

  @override
  String get recommended_badge => 'Direkomendasikan';

  @override
  String get safe_badge => 'Aman';

  @override
  String get overview => 'Ikhtisar';

  @override
  String get patterns => 'Pola';

  @override
  String get apps => 'Aplikasi';

  @override
  String get sortAscending => 'Urutkan Naik';

  @override
  String get sortDescending => 'Urutkan Turun';

  @override
  String applicationsShowing(int count) {
    return '$count aplikasi ditampilkan';
  }

  @override
  String valueLabel(String value) {
    return 'Nilai: $value';
  }

  @override
  String appsCount(int count) {
    return '$count aplikasi';
  }

  @override
  String categoriesCount(int count) {
    return '$count kategori';
  }

  @override
  String get systemNotificationsDisabled =>
      'Notifikasi sistem dinonaktifkan. Aktifkan di Pengaturan Sistem untuk peringatan fokus.';

  @override
  String get openSystemSettings => 'Buka Pengaturan Sistem';

  @override
  String get appNotificationsDisabled =>
      'Notifikasi dinonaktifkan di pengaturan aplikasi. Aktifkan untuk menerima peringatan fokus.';

  @override
  String get goToSettings => 'Buka Pengaturan';

  @override
  String get focusModeNotificationsDisabled =>
      'Notifikasi mode fokus dinonaktifkan. Aktifkan untuk menerima peringatan sesi.';

  @override
  String get notificationsDisabled => 'Notifikasi Dinonaktifkan';

  @override
  String get dontShowAgain => 'Jangan tampilkan lagi';

  @override
  String get systemSettingsRequired => 'Pengaturan Sistem Diperlukan';

  @override
  String get notificationsDisabledSystemLevel =>
      'Notifikasi dinonaktifkan di tingkat sistem. Untuk mengaktifkan:';

  @override
  String get step1OpenSystemSettings =>
      '1. Buka Pengaturan Sistem (Preferensi Sistem)';

  @override
  String get step2GoToNotifications => '2. Buka Notifikasi';

  @override
  String get step3FindApp => '3. Cari dan pilih Scolect';

  @override
  String get step4EnableNotifications => '4. Aktifkan \"Izinkan notifikasi\"';

  @override
  String get returnToAppMessage =>
      'Kemudian kembali ke aplikasi ini dan notifikasi akan berfungsi.';

  @override
  String get gotIt => 'Mengerti';

  @override
  String get noSessionsYet => 'Belum ada sesi';

  @override
  String applicationsTracked(int count) {
    return '$count aplikasi dilacak';
  }

  @override
  String get applicationHeader => 'Aplikasi';

  @override
  String get currentUsageHeader => 'Penggunaan Saat Ini';

  @override
  String get dailyLimitHeader => 'Batas Harian';

  @override
  String get edit => 'Edit';

  @override
  String get showPopupNotifications => 'Tampilkan notifikasi pop-up';

  @override
  String get moreFrequentReminders => 'Pengingat lebih sering';

  @override
  String get playSoundWithAlerts => 'Putar suara dengan peringatan';

  @override
  String get systemTrayNotifications => 'Notifikasi system tray';

  @override
  String screenTimeUsed(String current, String limit) {
    return '$current / $limit digunakan';
  }

  @override
  String get todaysScreenTime => 'Waktu Layar Hari Ini';

  @override
  String get activeLimits => 'Batas Aktif';

  @override
  String get nearLimit => 'Mendekati Batas';

  @override
  String get colorPickerSpectrum => 'Spektrum';

  @override
  String get colorPickerPresets => 'Preset';

  @override
  String get colorPickerSliders => 'Penggeser';

  @override
  String get colorPickerBasicColors => 'Warna Dasar';

  @override
  String get colorPickerExtendedPalette => 'Palet yang Diperluas';

  @override
  String get colorPickerRed => 'Merah';

  @override
  String get colorPickerGreen => 'Hijau';

  @override
  String get colorPickerBlue => 'Biru';

  @override
  String get colorPickerHue => 'Rona';

  @override
  String get colorPickerSaturation => 'Saturasi';

  @override
  String get colorPickerBrightness => 'Kecerahan';

  @override
  String get colorPickerHexColor => 'Warna Heksadesimal';

  @override
  String get colorPickerHexPlaceholder => 'RRGGBB';

  @override
  String get colorPickerRGB => 'RGB';

  @override
  String get select => 'Pilih';

  @override
  String get themeCustomization => 'Kustomisasi Tema';

  @override
  String get chooseThemePreset => 'Pilih Preset Tema';

  @override
  String get yourCustomThemes => 'Tema Kustom Anda';

  @override
  String get createCustomTheme => 'Buat Tema Kustom';

  @override
  String get designOwnColorScheme => 'Rancang skema warna Anda sendiri';

  @override
  String get newTheme => 'Tema Baru';

  @override
  String get editCurrentTheme => 'Edit Tema Saat Ini';

  @override
  String customizeColorsFor(String themeName) {
    return 'Sesuaikan warna untuk $themeName';
  }

  @override
  String customThemeNumber(int number) {
    return 'Tema Kustom $number';
  }

  @override
  String get deleteCustomTheme => 'Hapus Tema Kustom';

  @override
  String confirmDeleteTheme(String themeName) {
    return 'Apakah Anda yakin ingin menghapus \"$themeName\"?';
  }

  @override
  String get delete => 'Hapus';

  @override
  String get customizeTheme => 'Sesuaikan Tema';

  @override
  String get preview => 'Pratinjau';

  @override
  String get themeName => 'Nama Tema';

  @override
  String get brandColors => 'Warna Merek';

  @override
  String get lightTheme => 'Tema Terang';

  @override
  String get darkTheme => 'Tema Gelap';

  @override
  String get reset => 'Atur Ulang';

  @override
  String get saveTheme => 'Simpan Tema';

  @override
  String get customTheme => 'Tema Kustom';

  @override
  String get primaryColors => 'Warna Utama';

  @override
  String get primaryColorsDesc =>
      'Warna aksen utama yang digunakan di seluruh aplikasi';

  @override
  String get primaryAccent => 'Aksen Utama';

  @override
  String get primaryAccentDesc => 'Warna merek utama, tombol, tautan';

  @override
  String get secondaryAccent => 'Aksen Sekunder';

  @override
  String get secondaryAccentDesc => 'Aksen pelengkap untuk gradien';

  @override
  String get semanticColors => 'Warna Semantik';

  @override
  String get semanticColorsDesc => 'Warna yang menyampaikan makna dan status';

  @override
  String get successColor => 'Warna Sukses';

  @override
  String get successColorDesc => 'Tindakan positif, konfirmasi';

  @override
  String get warningColor => 'Warna Peringatan';

  @override
  String get warningColorDesc => 'Kehati-hatian, status tertunda';

  @override
  String get errorColor => 'Warna Error';

  @override
  String get errorColorDesc => 'Kesalahan, tindakan destruktif';

  @override
  String get backgroundColors => 'Warna Latar Belakang';

  @override
  String get backgroundColorsLightDesc =>
      'Permukaan latar belakang utama untuk mode terang';

  @override
  String get backgroundColorsDarkDesc =>
      'Permukaan latar belakang utama untuk mode gelap';

  @override
  String get background => 'Latar Belakang';

  @override
  String get backgroundDesc => 'Latar belakang aplikasi utama';

  @override
  String get surface => 'Permukaan';

  @override
  String get surfaceDesc => 'Kartu, dialog, permukaan yang ditinggikan';

  @override
  String get surfaceSecondary => 'Permukaan Sekunder';

  @override
  String get surfaceSecondaryDesc => 'Kartu sekunder, sidebar';

  @override
  String get border => 'Batas';

  @override
  String get borderDesc => 'Pembagi, batas kartu';

  @override
  String get textColors => 'Warna Teks';

  @override
  String get textColorsLightDesc => 'Warna tipografi untuk mode terang';

  @override
  String get textColorsDarkDesc => 'Warna tipografi untuk mode gelap';

  @override
  String get textPrimary => 'Teks Utama';

  @override
  String get textPrimaryDesc => 'Judul, teks penting';

  @override
  String get textSecondary => 'Teks Sekunder';

  @override
  String get textSecondaryDesc => 'Deskripsi, keterangan';

  @override
  String previewMode(String mode) {
    return 'Pratinjau: Mode $mode';
  }

  @override
  String get dark => 'Gelap';

  @override
  String get light => 'Terang';

  @override
  String get sampleCardTitle => 'Judul Kartu Contoh';

  @override
  String get sampleSecondaryText =>
      'Ini adalah teks sekunder yang muncul di bawah.';

  @override
  String get primary => 'Utama';

  @override
  String get secondary => 'Sekunder';

  @override
  String get warning => 'Peringatan';

  @override
  String get launchAtStartupTitle => 'Jalankan saat startup';

  @override
  String get launchAtStartupDescription =>
      'Mulai Scolect secara otomatis saat Anda masuk ke komputer Anda';

  @override
  String get inputMonitoringPermissionTitle =>
      'Pemantauan keyboard tidak tersedia';

  @override
  String get inputMonitoringPermissionDescription =>
      'Aktifkan izin pemantauan input untuk melacak aktivitas keyboard. Saat ini hanya input mouse yang dipantau.';

  @override
  String get openSettings => 'Buka Pengaturan';

  @override
  String get permissionGrantedTitle => 'Izin diberikan';

  @override
  String get permissionGrantedDescription =>
      'Aplikasi perlu dimulai ulang agar pemantauan input berlaku.';

  @override
  String get continueButton => 'Lanjutkan';

  @override
  String get restartRequiredTitle => 'Perlu dimulai ulang';

  @override
  String get restartRequiredDescription =>
      'Untuk mengaktifkan pemantauan keyboard, aplikasi perlu dimulai ulang. Ini diwajibkan oleh macOS.';

  @override
  String get restartNote =>
      'Aplikasi akan terbuka kembali secara otomatis setelah dimulai ulang.';

  @override
  String get restartNow => 'Mulai ulang sekarang';

  @override
  String get restartLater => 'Mulai ulang nanti';

  @override
  String get restartFailedTitle => 'Gagal memulai ulang';

  @override
  String get restartFailedMessage =>
      'Aplikasi tidak dapat dimulai ulang secara otomatis. Silakan keluar (Cmd+Q) dan buka kembali secara manual.';

  @override
  String get exportAnalyticsReport => 'Ekspor Laporan Analitik';

  @override
  String get chooseExportFormat => 'Pilih format ekspor:';

  @override
  String get beautifulExcelReport => 'Laporan Excel yang Indah';

  @override
  String get beautifulExcelReportDescription =>
      'Spreadsheet yang indah dan berwarna dengan grafik, emoji, dan wawasan ✨';

  @override
  String get excelReportIncludes => 'Laporan Excel meliputi:';

  @override
  String get summarySheetDescription =>
      '📊 Lembar Ringkasan - Metrik utama dengan tren';

  @override
  String get dailyBreakdownDescription =>
      '📅 Rincian Harian - Pola penggunaan visual';

  @override
  String get appsSheetDescription =>
      '📱 Lembar Aplikasi - Peringkat aplikasi terperinci';

  @override
  String get insightsDescription => '💡 Wawasan - Rekomendasi cerdas';

  @override
  String get beautifulExcelExportSuccess =>
      'Laporan Excel yang indah berhasil diekspor! 🎉';

  @override
  String failedToExportReport(String error) {
    return 'Gagal mengekspor laporan: $error';
  }

  @override
  String get exporting => 'Mengekspor...';

  @override
  String get exportExcel => 'Ekspor Excel';

  @override
  String get saveAnalyticsReport => 'Simpan Laporan Analitik';

  @override
  String analyticsReportFileName(String timestamp) {
    return 'laporan_analitik_$timestamp.xlsx';
  }

  @override
  String get usageAnalyticsReportTitle => 'LAPORAN ANALISIS PENGGUNAAN';

  @override
  String get generated => 'Dibuat:';

  @override
  String get period => 'Periode:';

  @override
  String dateRangeValue(String startDate, String endDate) {
    return '$startDate sampai $endDate';
  }

  @override
  String get keyMetrics => 'METRIK UTAMA';

  @override
  String get metric => 'Metrik';

  @override
  String get value => 'Nilai';

  @override
  String get change => 'Perubahan';

  @override
  String get trend => 'Tren';

  @override
  String get productivityRate => 'Tingkat Produktivitas';

  @override
  String get trendUp => 'Naik';

  @override
  String get trendDown => 'Turun';

  @override
  String get trendExcellent => 'Sangat Baik';

  @override
  String get trendGood => 'Baik';

  @override
  String get trendNeedsImprovement => 'Perlu Perbaikan';

  @override
  String get trendActive => 'Aktif';

  @override
  String get trendNone => 'Tidak Ada';

  @override
  String get trendTop => 'Teratas';

  @override
  String get category => 'Kategori';

  @override
  String get percentage => 'Persentase';

  @override
  String get visual => 'Visual';

  @override
  String get statistics => 'STATISTIK';

  @override
  String get averageDaily => 'Rata-rata Harian';

  @override
  String get highestDay => 'Hari Tertinggi';

  @override
  String get lowestDay => 'Hari Terendah';

  @override
  String get day => 'Hari';

  @override
  String get applicationUsageDetails => 'DETAIL PENGGUNAAN APLIKASI';

  @override
  String get totalApps => 'Total Aplikasi:';

  @override
  String get productiveApps => 'Aplikasi Produktif:';

  @override
  String get rank => 'Peringkat';

  @override
  String get application => 'Aplikasi';

  @override
  String get time => 'Waktu';

  @override
  String get percentOfTotal => '% dari Total';

  @override
  String get type => 'Tipe';

  @override
  String get usageLevel => 'Tingkat Penggunaan';

  @override
  String get leisure => 'Hiburan';

  @override
  String get usageLevelVeryHigh => 'Sangat Tinggi ||||||||';

  @override
  String get usageLevelHigh => 'Tinggi ||||||';

  @override
  String get usageLevelMedium => 'Sedang ||||';

  @override
  String get usageLevelLow => 'Rendah ||';

  @override
  String get keyInsightsTitle => 'WAWASAN DAN REKOMENDASI UTAMA';

  @override
  String get personalizedRecommendations => 'REKOMENDASI PERSONAL';

  @override
  String insightHighDailyUsage(String hours) {
    return 'Penggunaan Harian Tinggi: Anda rata-rata menggunakan $hours jam waktu layar per hari';
  }

  @override
  String insightLowDailyUsage(String hours) {
    return 'Penggunaan Harian Rendah: Anda rata-rata $hours jam per hari - keseimbangan yang bagus!';
  }

  @override
  String insightModerateUsage(String hours) {
    return 'Penggunaan Sedang: Rata-rata $hours jam waktu layar per hari';
  }

  @override
  String insightExcellentProductivity(String percentage) {
    return 'Produktivitas Sangat Baik: $percentage% waktu layar Anda adalah kerja produktif!';
  }

  @override
  String insightGoodProductivity(String percentage) {
    return 'Produktivitas Baik: $percentage% waktu layar Anda produktif';
  }

  @override
  String insightLowProductivity(String percentage) {
    return 'Peringatan Produktivitas Rendah: Hanya $percentage% waktu layar yang produktif';
  }

  @override
  String insightFocusSessions(int count, String avgPerDay) {
    return 'Sesi Fokus: Menyelesaikan $count sesi (rata-rata $avgPerDay per hari)';
  }

  @override
  String insightGreatFocusHabit(int count) {
    return 'Kebiasaan Fokus Hebat: Anda telah membangun rutinitas fokus yang luar biasa dengan $count sesi selesai!';
  }

  @override
  String get insightNoFocusSessions =>
      'Tidak Ada Sesi Fokus: Pertimbangkan menggunakan mode fokus untuk meningkatkan produktivitas Anda';

  @override
  String insightScreenTimeTrend(String direction, String percentage) {
    return 'Tren Waktu Layar: Penggunaan Anda $direction $percentage% dibandingkan periode sebelumnya';
  }

  @override
  String insightProductiveTimeTrend(String direction, String percentage) {
    return 'Tren Waktu Produktif: Waktu produktif Anda $direction $percentage% dibandingkan periode sebelumnya';
  }

  @override
  String get directionIncreased => 'meningkat';

  @override
  String get directionDecreased => 'menurun';

  @override
  String insightTopCategory(String category, String percentage) {
    return 'Kategori Teratas: $category mendominasi dengan $percentage% dari total waktu Anda';
  }

  @override
  String insightMostUsedApp(
      String appName, String percentage, String duration) {
    return 'Aplikasi Paling Sering Digunakan: $appName menyumbang $percentage% dari waktu Anda ($duration)';
  }

  @override
  String insightUsageVaries(String highDay, String multiplier, String lowDay) {
    return 'Penggunaan Bervariasi Signifikan: $highDay memiliki penggunaan ${multiplier}x lebih banyak dari $lowDay';
  }

  @override
  String get insightNoInsights => 'Tidak ada wawasan signifikan tersedia';

  @override
  String get recScheduleFocusSessions =>
      'Coba jadwalkan lebih banyak sesi fokus sepanjang hari untuk meningkatkan produktivitas';

  @override
  String get recSetAppLimits =>
      'Pertimbangkan untuk menetapkan batas pada aplikasi hiburan';

  @override
  String get recAimForFocusSessions =>
      'Targetkan setidaknya 1-2 sesi fokus per hari untuk membangun kebiasaan konsisten';

  @override
  String get recTakeBreaks =>
      'Waktu layar harian Anda cukup tinggi. Coba ambil istirahat teratur menggunakan aturan 20-20-20';

  @override
  String get recSetDailyGoals =>
      'Pertimbangkan untuk menetapkan target waktu layar harian untuk mengurangi penggunaan secara bertahap';

  @override
  String get recBalanceEntertainment =>
      'Aplikasi hiburan menyumbang sebagian besar waktu Anda. Pertimbangkan untuk menyeimbangkan dengan aktivitas lebih produktif';

  @override
  String get recReviewUsagePatterns =>
      'Waktu layar Anda meningkat secara signifikan. Tinjau pola penggunaan Anda dan tetapkan batasan';

  @override
  String get recScheduleFocusedWork =>
      'Waktu produktif Anda menurun. Coba jadwalkan blok kerja fokus di kalender Anda';

  @override
  String get recKeepUpGreatWork =>
      'Terus pertahankan! Kebiasaan waktu layar Anda terlihat sehat';

  @override
  String get recContinueFocusSessions =>
      'Terus gunakan sesi fokus untuk mempertahankan produktivitas';

  @override
  String get sheetSummary => 'Ringkasan';

  @override
  String get sheetDailyBreakdown => 'Rincian Harian';

  @override
  String get sheetApps => 'Aplikasi';

  @override
  String get sheetInsights => 'Wawasan';

  @override
  String get statusHeader => 'Status';

  @override
  String workSessions(int count) {
    return '$count sesi kerja';
  }

  @override
  String get complete => 'Selesai';

  @override
  String get inProgress => 'Sedang Berlangsung';

  @override
  String get workTime => 'Waktu Kerja';

  @override
  String get breakTime => 'Waktu Istirahat';

  @override
  String get phasesCompleted => 'Fase Selesai';

  @override
  String hourMinuteFormat(String hours, String minutes) {
    return '$hours jam $minutes menit';
  }

  @override
  String hourOnlyFormat(String hours) {
    return '$hours jam';
  }

  @override
  String minuteFormat(String minutes) {
    return '$minutes menit';
  }

  @override
  String sessionsCount(int count) {
    return '$count sesi';
  }

  @override
  String get workPhases => 'Fase Kerja';

  @override
  String get averageLength => 'Rata-rata Durasi';

  @override
  String get mostProductive => 'Paling Produktif';

  @override
  String get work => 'Kerja';

  @override
  String get breaks => 'Istirahat';

  @override
  String get none => 'Tidak ada';

  @override
  String minuteShortFormat(String minutes) {
    return '${minutes}m';
  }

  @override
  String get importTheme => 'Impor Tema';

  @override
  String get exportTheme => 'Ekspor Tema';

  @override
  String get import => 'Impor';

  @override
  String get export => 'Ekspor';

  @override
  String get chooseExportMethod => 'Pilih cara mengekspor tema Anda:';

  @override
  String get saveAsFile => 'Simpan sebagai File';

  @override
  String get saveThemeAsJSONFile =>
      'Simpan tema sebagai file JSON ke perangkat Anda';

  @override
  String get copyToClipboard => 'Salin ke Papan Klip';

  @override
  String get copyThemeJSONToClipboard => 'Salin data tema ke papan klip';

  @override
  String get share => 'Bagikan';

  @override
  String get shareThemeViaSystemSheet =>
      'Bagikan tema menggunakan lembar berbagi sistem';

  @override
  String get chooseImportMethod => 'Pilih cara mengimpor tema:';

  @override
  String get loadFromFile => 'Muat dari File';

  @override
  String get selectJSONFileFromDevice =>
      'Pilih file JSON tema dari perangkat Anda';

  @override
  String get pasteFromClipboard => 'Tempel dari Papan Klip';

  @override
  String get importFromClipboardJSON => 'Impor tema dari data JSON papan klip';

  @override
  String get importFromFile => 'Impor tema dari file';

  @override
  String get themeCreatedSuccessfully => 'Tema berhasil dibuat!';

  @override
  String get themeUpdatedSuccessfully => 'Tema berhasil diperbarui!';

  @override
  String get themeDeletedSuccessfully => 'Tema berhasil dihapus!';

  @override
  String get themeExportedSuccessfully => 'Tema berhasil diekspor!';

  @override
  String get themeCopiedToClipboard => 'Tema disalin ke papan klip!';

  @override
  String themeImportedSuccessfully(String themeName) {
    return 'Tema \"$themeName\" berhasil diimpor!';
  }

  @override
  String get noThemeDataFound => 'Tidak ada data tema ditemukan';

  @override
  String get invalidThemeFormat =>
      'Format tema tidak valid. Silakan periksa data JSON.';

  @override
  String get trackingModeTitle => 'Mode Pelacakan';

  @override
  String get trackingModeDescription =>
      'Pilih cara penggunaan aplikasi dilacak';

  @override
  String get trackingModePolling => 'Standar (Sumber Daya Rendah)';

  @override
  String get trackingModePrecise => 'Presisi (Akurasi Tinggi)';

  @override
  String get trackingModePollingHint =>
      'Memeriksa setiap menit - penggunaan sumber daya lebih rendah';

  @override
  String get trackingModePreciseHint =>
      'Pelacakan real-time - akurasi lebih tinggi, lebih banyak sumber daya';

  @override
  String get trackingModeChangeError =>
      'Gagal mengubah mode pelacakan. Silakan coba lagi.';

  @override
  String get errorTitle => 'Kesalahan';

  @override
  String get monitorKeyboardTitle => 'Pantau Keyboard';

  @override
  String get monitorKeyboardDescription =>
      'Lacak aktivitas keyboard untuk mendeteksi kehadiran pengguna';

  @override
  String get changelogWhatsNew => 'Yang Baru';

  @override
  String changelogReleasedOn(String date) {
    return 'Dirilis pada $date';
  }

  @override
  String get changelogNoContent =>
      'Tidak ada catatan perubahan untuk versi ini.';

  @override
  String get changelogUnableToLoad => 'Tidak Dapat Memuat Catatan Perubahan';

  @override
  String get changelogErrorDescription =>
      'Tidak dapat mengambil catatan perubahan untuk versi ini. Silakan periksa koneksi internet Anda atau kunjungi halaman rilis GitHub.';

  @override
  String get allTracking => 'Semua Aplikasi';

  @override
  String get notTracking => 'Tidak Dilacak';

  @override
  String get allVisibility => 'Semua';

  @override
  String get visible => 'Terlihat';

  @override
  String get hidden => 'Tersembunyi';

  @override
  String get todaysLimitUsage => 'Penggunaan Batas Hari Ini';

  @override
  String get thisWeekAtAGlance => 'Sekilas Minggu Ini';

  @override
  String get hourlyActivityHeatmap => 'Peta Panas Aktivitas Per Jam';

  @override
  String get productivityScore => 'Skor Produktivitas';

  @override
  String get streaks => 'Hari Berturut-turut';

  @override
  String get weekOverWeek => 'Minggu ke Minggu';

  @override
  String get sameAsLastWeek => 'Sama seperti minggu lalu';

  @override
  String moreUsageThanLastWeek(String percent) {
    return '$percent% lebih banyak dari minggu lalu';
  }

  @override
  String lessUsageThanLastWeek(String percent) {
    return '$percent% lebih sedikit dari minggu lalu';
  }

  @override
  String limitExceededBy(String duration) {
    return 'Batas terlampaui sebesar $duration';
  }

  @override
  String timeRemaining(String duration) {
    return '$duration tersisa';
  }

  @override
  String get totalSessions => 'Total sesi';

  @override
  String get avgSession => 'Rata-rata sesi';

  @override
  String get mostActive => 'Paling aktif';

  @override
  String get peakUsage => 'Penggunaan tertinggi';

  @override
  String get dailyAverage => 'Rata-rata harian';

  @override
  String get daysUsedInARow => 'Hari penggunaan berturut-turut';

  @override
  String get daysSingular => 'hari';

  @override
  String get daysPlural => 'hari';

  @override
  String get daysOverLimitInARow => 'Hari berturut-turut melebihi batas';

  @override
  String get withinLimitAllWeek => 'Dalam batas sepanjang minggu';

  @override
  String get productivityScoreGreat => 'Hebat';

  @override
  String get productivityScoreModerate => 'Sedang';

  @override
  String get productivityScoreNeedsAttention => 'Perlu Perhatian';

  @override
  String get productiveAppMotivation => 'Aplikasi produktif — pertahankan';

  @override
  String get nonProductiveAppSuggestion =>
      'Tidak produktif — pertimbangkan untuk mengurangi';

  @override
  String get legendUsage => 'Penggunaan';

  @override
  String get legendAverage => 'Rata-rata';

  @override
  String get legendLimit => 'Batas';

  @override
  String get chartPeak => 'Puncak';

  @override
  String overLimitBy(String duration) {
    return '+$duration melebihi batas';
  }

  @override
  String get noData => 'Tidak ada data';

  @override
  String get yesterday => 'Kemarin';

  @override
  String get changelog => 'Catatan perubahan';

  @override
  String get exportingLabel => 'Sedang mengekspor...';

  @override
  String get exportExcelLabel => 'Ekspor Excel';
}
