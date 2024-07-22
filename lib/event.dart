import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:satubisa/viewevent.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  late Future<List<dynamic>> _eventData;

  @override
  void initState() {
    super.initState();
    _eventData = _fetchEventData();
  }

  Future<List<dynamic>> _fetchEventData() async {
    final response = await http
        .get(Uri.parse('https://saniangbaka.bisayukbisa.com/api/mobile/event'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final dataList = jsonData['data'];
      if (dataList.isNotEmpty) {
        return List<dynamic>.from(dataList);
      }
    }
    throw Exception('Failed to load event data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event'),
      ),
      backgroundColor: Color.fromRGBO(
          205, 212, 215, 1), // Set background color to light blue
      body: FutureBuilder<List<dynamic>>(
        future: _eventData,
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
            final eventDataList = snapshot.data!;
            return ListView.builder(
              itemCount: eventDataList.length,
              itemBuilder: (context, index) {
                final event = eventDataList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewEventPage(
                          eventData:
                              event, // Kirim data event ke halaman detail
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            event['foto'] ?? '', // Handle jika foto null
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          event['nama'] ?? '', // Handle jika nama null
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          event['waktu'] ?? '', // Handle jika waktu null
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
