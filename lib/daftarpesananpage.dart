import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class DaftarPesananPage extends StatefulWidget {
  final String userId;

  const DaftarPesananPage({Key? key, required this.userId}) : super(key: key);

  @override
  _DaftarPesananPageState createState() => _DaftarPesananPageState();
}

class _DaftarPesananPageState extends State<DaftarPesananPage> {
  late Future<List<dynamic>> _pesananData;

  @override
  void initState() {
    super.initState();
    _refreshPesananData();
  }

  @override
  void didUpdateWidget(DaftarPesananPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _refreshPesananData(); // Refresh data when userId changes
    }
  }

  Future<void> _refreshPesananData() async {
    setState(() {
      _pesananData = _fetchPesananData();
    });
  }

  Future<List<dynamic>> _fetchPesananData() async {
    final response = await http.get(
      Uri.parse('https://saniangbaka.bisayukbisa.com/api/mobile/pesanan'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> allPesanan = List<dynamic>.from(jsonData['data']);
      // Filter data based on userId
      return allPesanan
          .where((pesanan) => pesanan['id_user'] == widget.userId)
          .toList();
    } else {
      throw Exception('Failed to load pesanan data');
    }
  }

  Future<void> _uploadImage(String idPesanan) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);

      final uri = Uri.parse(
          'https://saniangbaka.bisayukbisa.com/api/mobile/upload-bukti');
      final request = http.MultipartRequest('POST', uri)
        ..fields['id_pesanan'] = idPesanan
        ..files.add(await http.MultipartFile.fromPath(
            'bukti_pembayaran', imageFile.path));

      try {
        final response = await request.send();
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload successful!')),
          );
          // Refresh data after upload
          _refreshPesananData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Dipesan':
        return Colors.orange;
      case 'Dibatalkan':
        return Colors.red;
      case 'Selesai':
        return Colors.green;
      case 'Diverifikasi':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Pesanan'),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: () {
              _launchURL('https://saniangbaka.bisayukbisa.com/login');
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshPesananData,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _pesananData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found.'));
          } else {
            final pesananList = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Nama Paket')),
                  DataColumn(label: Text('Harga Paket')),
                  DataColumn(label: Text('Alamat')),
                  DataColumn(label: Text('Jumlah Paket')),
                  DataColumn(label: Text('Tanggal Pakai')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Harga Total')),
                  DataColumn(label: Text('E-Tiket')),
                ],
                rows: pesananList.map((pesanan) {
                  return DataRow(cells: [
                    DataCell(Text('${pesanan['nama_paket']}')),
                    DataCell(Text('${pesanan['harga_paket']}')),
                    DataCell(Text('${pesanan['alamat']}')),
                    DataCell(Text('${pesanan['jumlah_paket']}')),
                    DataCell(Text('${pesanan['tgl_pakai']}')),
                    DataCell(Text('${pesanan['status']}',
                        style: TextStyle(
                            color: _getStatusColor(pesanan['status'])))),
                    DataCell(Text('${pesanan['harga_total']}')),
                    DataCell(
                      pesanan['status'] == 'Diverifikasi'
                          ? InkWell(
                              onTap: () {
                                final String eTicketUrl =
                                    'https://saniangbaka.bisayukbisa.com/pesanan/e-tiket/${pesanan['id']}';
                                _launchURL(eTicketUrl);
                              },
                              child: Text(
                                'View E-Tiket',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            )
                          : Container(),
                    ),
                  ]);
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}
