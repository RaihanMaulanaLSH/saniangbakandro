import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:satubisa/viewwisata.dart';

class Wisatapage extends StatefulWidget {
  @override
  _WisatapageState createState() => _WisatapageState();
}

class _WisatapageState extends State<Wisatapage> {
  late Future<List<dynamic>> _destinasiData;

  @override
  void initState() {
    super.initState();
    _destinasiData = _fetchDestinasiData();
  }

  Future<List<dynamic>> _fetchDestinasiData() async {
    final response = await http
        .get(Uri.parse('https://saniangbaka.bisayukbisa.com/api/mobile/paket'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final dataList = jsonData['data'];
      if (dataList.isNotEmpty) {
        return List<dynamic>.from(dataList);
      }
    }
    throw Exception('Failed to load destination data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: _destinasiData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final destinasiList = snapshot.data!;
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/banner.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'Wisata',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Content
                  Expanded(
                    child: ListView.builder(
                      itemCount: destinasiList.length,
                      itemBuilder: (context, index) {
                        final destinasi = destinasiList[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewWisataPage(
                                  wisataData:
                                      destinasi, // Kirim data destinasi ke halaman detail
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: Column(
                              children: [
                                // Thumbnail with rounded corners
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    destinasi['foto'] ?? '',
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                // Text
                                ListTile(
                                  title: Text(destinasi['nama'] ?? ''),
                                  subtitle: Text(destinasi['harga'] ?? ''),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
