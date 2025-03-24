class BantuanModel {
  final String judul; // Judul bantuan
  final String deskripsi; // Deskripsi bantuan

  BantuanModel({required this.judul, required this.deskripsi});
}

List<BantuanModel> itemList = [
  BantuanModel(
    judul: "Stopwatch",
    deskripsi: """
    - Buka menu Stopwatch dari halaman utama.
    - Tekan tombol Start untuk memulai stopwatch.
    - Tekan Pause untuk menghentikan sementara waktu.
    - Tekan Reset untuk mengatur ulang stopwatch ke 00:00.
    """,
  ),
  BantuanModel(
    judul: "Jenis Bilangan",
    deskripsi: """
    - Buka menu "Jenis Bilangan".
    - Masukkan angka ke dalam kolom input.
    - Tekan tombol Cek Bilangan.
    - Aplikasi akan menampilkan apakah bilangan tersebut prima, desimal, bulat positif/negatif, atau cacah.
    """,
  ),
  BantuanModel(
    judul: "Tracking LBS (Location-Based Service)",
    deskripsi: """
    - Buka menu "Tracking LBS".
    - Izinkan aplikasi mengakses lokasi jika diminta.
    - Aplikasi akan menampilkan lokasi Anda saat ini di peta.
    - Bisa digunakan untuk melacak posisi pengguna atau digunakan untuk fitur lokasi tertentu.
    """,
  ),
  BantuanModel(
    judul: "Konversi Waktu",
    deskripsi: """
    - Buka menu "Konversi Waktu".
    - Pilih jenis konversi (misalnya tahun ke detik, menit ke jam, dll).
    - Masukkan nilai angka pada kolom input.
    - Tekan tombol Konversi.
    - Hasil konversi waktu akan muncul di bawahnya.
    """,
  ),
  BantuanModel(
    judul: "Rekomendasi Situs",
    deskripsi: """
    - Buka menu "Daftar Rekomendasi Situs".
    - Akan muncul daftar situs yang direkomendasikan lengkap dengan gambar dan link.
    - Tekan ikon Favorite (❤) untuk menyimpan situs ke daftar favorit Anda.
    - Tekan link untuk membuka situs di browser.
    """,
  ),
];
