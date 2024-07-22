import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late Future<List<dynamic>> _fotoData;

  @override
  void initState() {
    super.initState();
    _fotoData = _fetchFotoData();
  }

  Future<List<dynamic>> _fetchFotoData() async {
    final response = await http
        .get(Uri.parse('https://saniangbaka.bisayukbisa.com/api/mobile/foto'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final dataList = jsonData['data'];
      if (dataList.isNotEmpty) {
        return List<dynamic>.from(dataList);
      }
    }
    throw Exception('Failed to load photo data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Color.fromRGBO(
            205, 212, 215, 1), // Set background color to light blue
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Gallery',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            // Gallery
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _fotoData,
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
                    final fotoList = snapshot.data!;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: fotoList.length,
                      itemBuilder: (context, index) {
                        final foto = fotoList[index];
                        return GestureDetector(
                          onTap: () {
                            _showImageDialog(context, foto['foto'] ?? '');
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            elevation: 4.0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                foto['foto'] ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show the image in a dialog
  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            height: 300,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
