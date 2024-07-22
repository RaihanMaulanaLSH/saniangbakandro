import 'package:flutter/material.dart';

class ViewEventPage extends StatelessWidget {
  final dynamic eventData; // Data event yang diterima dari halaman sebelumnya

  ViewEventPage({required this.eventData}); // Konstruktor untuk menerima data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
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
                  child: eventData['foto'] != null
                      ? Image.network(
                          eventData['foto'],
                          fit: BoxFit.cover,
                        )
                      : SizedBox
                          .shrink(), // Jika foto null, gunakan SizedBox.shrink()
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  color: Color.fromARGB(
                      255, 225, 207, 207), // Set background color to grey
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventData['nama'] ??
                            'Nama Event Tidak Tersedia', // Penanganan jika nama null
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        eventData['waktu'] ??
                            'Tanggal Tidak Tersedia', // Penanganan jika tanggal null
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        eventData['deskripsi'] ??
                            'Deskripsi Tidak Tersedia', // Penanganan jika deskripsi null
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
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
