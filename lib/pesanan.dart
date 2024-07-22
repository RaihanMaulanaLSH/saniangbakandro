import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:satubisa/daftarpesananpage.dart';

class Pesanan {
  final String noTelepon;
  final String alamat;
  final int jumlahPaket;
  final String tanggalPenggunaan;
  final String idPaket;

  Pesanan({
    required this.noTelepon,
    required this.alamat,
    required this.jumlahPaket,
    required this.tanggalPenggunaan,
    required this.idPaket,
  });
}

class PesananPage extends StatefulWidget {
  final Pesanan pesanan;

  PesananPage({required this.pesanan});

  @override
  _PesananPageState createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _noTeleponController;
  late TextEditingController _alamatController;
  late TextEditingController _jumlahPaketController;
  late TextEditingController _tanggalPenggunaanController;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _noTeleponController =
        TextEditingController(text: widget.pesanan.noTelepon);
    _alamatController = TextEditingController(text: widget.pesanan.alamat);
    _jumlahPaketController =
        TextEditingController(text: widget.pesanan.jumlahPaket.toString());
    _tanggalPenggunaanController =
        TextEditingController(text: widget.pesanan.tanggalPenggunaan);
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulir Pesanan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Silakan isi formulir pesanan untuk Paket ID ${widget.pesanan.idPaket}',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _noTeleponController,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor Telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: _jumlahPaketController,
                decoration: InputDecoration(
                  labelText: 'Jumlah Paket',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah Paket tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Jumlah Paket harus berupa angka';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: _tanggalPenggunaanController,
                decoration: InputDecoration(
                  labelText: 'Tanggal Penggunaan',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Colors.blue,
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              primary: Colors.black,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _tanggalPenggunaanController.text =
                          pickedDate.toLocal().toString().split(' ')[0];
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal Penggunaan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_userId.isEmpty) {
                      _showLoginDialog();
                    } else {
                      _simpanPesanan();
                    }
                  }
                },
                child: Text('Pesan Sekarang'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _simpanPesanan() async {
    final Uri apiUrl =
        Uri.parse('https://saniangbaka.bisayukbisa.com/api/mobile/pesan-paket');

    try {
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'no_telepon': _noTeleponController.text,
          'alamat': _alamatController.text,
          'jumlah_paket': int.parse(_jumlahPaketController.text),
          'tanggal_penggunaan': _tanggalPenggunaanController.text,
          'id_paket': widget.pesanan.idPaket,
          'id_user': _userId
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DaftarPesananPage(userId: _userId),
          ),
        );
      } else {
        _showErrorDialog(
            'Gagal menyimpan pesanan! Error: ${response.statusCode}',
            response.body);
      }
    } catch (error) {
      _showErrorDialog('Terjadi kesalahan:', error.toString());
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Diperlukan'),
        content:
            Text('Anda harus login terlebih dahulu untuk melakukan pesanan.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Arahkan pengguna ke halaman login jika ada
              // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
