import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:satubisa/loginpage.dart';
import 'package:satubisa/pesanan.dart'; // Import file pesanan.dart
import 'package:satubisa/wisata.dart';

class ViewWisataPage extends StatelessWidget {
  final dynamic wisataData; // Data wisata yang diterima dari halaman sebelumnya

  ViewWisataPage({required this.wisataData}); // Konstruktor untuk menerima data

  @override
  Widget build(BuildContext context) {
    // Menghilangkan tag <p> dari deskripsi
    String deskripsiTanpaPTag = wisataData['deskripsi'] != null
        ? wisataData['deskripsi'].replaceAll(RegExp(r'<p>|<\/p>'), '')
        : 'Deskripsi Tidak Tersedia';

    // Ganti tag <ul> dan <li> dengan simbol bullet
    deskripsiTanpaPTag =
        deskripsiTanpaPTag.replaceAll(RegExp(r'<ul>|<\/ul>'), '');
    deskripsiTanpaPTag = deskripsiTanpaPTag.replaceAll(RegExp(r'<li>'), '• ');
    deskripsiTanpaPTag = deskripsiTanpaPTag.replaceAll(RegExp(r'<\/li>'), '\n');

    // Mendapatkan nilai harga dari data wisata
    String harga = wisataData['harga'] ?? 'Harga Tidak Tersedia';

    // Menyiapkan data pesanan
    Pesanan pesanan = Pesanan(
      noTelepon: '', // Anda harus mengganti ini dengan nilai yang sesuai
      alamat: '', // Anda harus mengganti ini dengan nilai yang sesuai
      jumlahPaket: 0, // Anda harus mengganti ini dengan nilai yang sesuai
      tanggalPenggunaan:
          '', // Anda harus mengganti ini dengan nilai yang sesuai
      idPaket:
          wisataData['nama'], // Menggunakan nama wisata dari data yang diterima
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Wisata Details'),
      ),
      backgroundColor: Color.fromRGBO(
          205, 212, 215, 1), // Set background color to light blue
      body: ListView(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                  child: wisataData['foto'] != null
                      ? Image.network(
                          wisataData['foto'],
                          fit: BoxFit.cover,
                        )
                      : SizedBox
                          .shrink(), // Jika foto null, gunakan SizedBox.shrink()
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wisataData['nama'] ??
                            'Nama Wisata Tidak Tersedia', // Penanganan jika nama null
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      SizedBox(height: 8.0),
                      Text(
                        deskripsiTanpaPTag,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(
                          height: 16.0), // Spasi antara deskripsi dan tombol
                      Row(
                        children: [
                          Text(
                            'Rp.$harga / Paket', // Menampilkan harga dari data
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.0), // Spasi antara harga dan tombol
                          ElevatedButton(
                            onPressed: () async {
                              // Periksa apakah pengguna sudah login
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final String userId =
                                  prefs.getString('userId') ?? '';

                              if (userId.isEmpty) {
                                // Jika belum login, arahkan ke halaman login
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                );
                              } else {
                                // Jika sudah login, lanjutkan ke halaman Pesanan
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PesananPage(pesanan: pesanan),
                                  ),
                                );
                              }
                            },
                            child: Text('Beli'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
