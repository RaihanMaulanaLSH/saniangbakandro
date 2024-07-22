import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:satubisa/event.dart';
import 'package:satubisa/gallery.dart';
import 'package:satubisa/loginpage.dart';
import 'package:satubisa/viewevent.dart';
import 'package:satubisa/viewwisata.dart';
import 'package:satubisa/wisata.dart';
import 'package:satubisa/daftarpesananpage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wisata Alam di Solok',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(username: 'Guest'),
        '/login': (context) => LoginPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _username = 'Guest';
  bool _isLoggedIn = false;
  late String _userId; // Tambahkan variabel untuk menyimpan ID pengguna

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _getUsernameFromSharedPreferences();
    _getUserId(); // Panggil metode untuk mendapatkan ID pengguna
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? username = prefs.getString('username');

    if (isLoggedIn && username != null) {
      setState(() {
        _isLoggedIn = true;
        _username = username;
      });
    }
  }

  void _getUsernameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    setState(() {
      _username = username ?? 'Guest';
    });
  }

  // Metode untuk mendapatkan ID pengguna dari SharedPreferences
  void _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    setState(() {
      _userId =
          userId ?? ''; // Inisialisasi _userId dengan nilai yang diperoleh
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wisata Alam di Solok'),
        actions: [
          _buildUserIconMenu(),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.landscape),
            label: 'Wisata',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildUserIconMenu() {
    return PopupMenuButton<int>(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.person),
              SizedBox(width: 8),
              Text(_isLoggedIn ? _username : 'Login'),
            ],
          ),
        ),
        if (_isLoggedIn)
          PopupMenuItem(
            value: 2,
            child: Row(
              children: [
                Icon(Icons.logout),
                SizedBox(width: 8),
                Text('Logout'),
              ],
            ),
          ),
        if (_isLoggedIn)
          PopupMenuItem(
            value: 3,
            child: Row(
              children: [
                Icon(Icons.person_outline),
                SizedBox(width: 8),
                Text('Pesanan'),
              ],
            ),
          ),
      ],
      onSelected: (value) {
        if (value == 1 && !_isLoggedIn) {
          Navigator.pushNamed(context, '/login')
              .then((_) => _checkLoginStatus());
        } else if (value == 2 && _isLoggedIn) {
          _logout();
        } else if (value == 3 && _isLoggedIn) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DaftarPesananPage(
                    userId:
                        _userId)), // Menggunakan _userId saat menavigasi ke DaftarPesananPage
          );
        }
      },
      icon: Icon(Icons.person_outline),
    );
  }

  void _logout() async {
    final response = await http.post(
        Uri.parse('https://saniangbaka.bisayukbisa.com/api/mobile/logout'));

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('username');

      setState(() {
        _isLoggedIn = false;
        _username = 'Guest';
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Logged out successfully')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to log out')));
    }
  }

  final List<Widget> _pages = [
    HomePageContent(),
    EventPage(),
    GalleryPage(),
    Wisatapage(),
  ];
}

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  late Future<Map<String, dynamic>> _headerData;
  late Future<List<dynamic>> _destinasiData;
  late Future<List<dynamic>> _eventData;

  @override
  void initState() {
    super.initState();
    _headerData = _fetchHeaderData();
    _destinasiData = _fetchDestinasiData();
    _eventData = _fetchEventData();
  }

  Future<Map<String, dynamic>> _fetchHeaderData() async {
    final response = await http.get(
        Uri.parse('https://saniangbaka.bisayukbisa.com/api/mobile/header'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final dataList = jsonData['data'];
      if (dataList.isNotEmpty) {
        return dataList[0];
      }
    }
    throw Exception('Failed to load header data');
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
    return Container(
      color: Color.fromRGBO(205, 212, 215, 1),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: _headerData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final headerData = snapshot.data!;
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(headerData['foto']),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            headerData['judul'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              headerData['deskripsi'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            // Recommendation
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rekomendasi Wisata'),
                  SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FutureBuilder<List<dynamic>>(
                          future: _destinasiData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final destinasiList = snapshot.data!;
                              return Row(
                                children: destinasiList.map((data) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewWisataPage(
                                            wisataData: data,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Column(
                                          children: [
                                            Image.network(
                                              data['foto'],
                                              width: 150,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                            Text(data['nama']),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Event Wisata
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Event yang tengah Hadir'),
                  FutureBuilder<List<dynamic>>(
                    future: _eventData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final eventList = snapshot.data!;
                        return Column(
                          children: eventList.map((event) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewEventPage(
                                      eventData: event,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Column(
                                    children: [
                                      event['foto'] != null
                                          ? Image.network(
                                              event['foto'],
                                              width: 300,
                                              height: 200,
                                              fit: BoxFit.cover,
                                            )
                                          : SizedBox.shrink(),
                                      event['nama'] != null
                                          ? Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                event['nama'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
