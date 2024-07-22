import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:satubisa/registrasiakunpage.dart';
import 'package:satubisa/main.dart';
import 'package:satubisa/daftarpesananpage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String username = _usernameController.text;
    final String password = _passwordController.text;

    final Map<String, String> data = {
      'username': username,
      'password': password,
    };

    final Uri url =
        Uri.parse('https://saniangbaka.bisayukbisa.com/api/mobile/login');
    final Map<String, String> headers = {"Content-Type": "application/json"};
    final String jsonBody = json.encode(data);

    try {
      final http.Response response = await http.post(
        url,
        headers: headers,
        body: jsonBody,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 200) {
        final Map<String, dynamic>? userData = responseData['data'];
        if (userData != null) {
          final String username = userData['name'];
          final String userId = userData['id']
              .toString(); // Ambil id_user dan ubah menjadi string

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', username);
          await prefs.setString('userId', userId); // Simpan id_user
          await prefs.setBool('isLoggedIn', true);

          Navigator.pop(context); // Kembali ke halaman sebelumnya
          Fluttertoast.showToast(
            msg:
                "Welcome, $username (ID: $userId)", // Tambahkan id_user ke pesan toast
            toastLength: Toast.LENGTH_LONG, // Durasi toast lebih lama
            gravity: ToastGravity.CENTER, // Posisi di tengah
            timeInSecForIosWeb:
                30, // Durasi ditampilkan (dalam detik) di iOS/Web
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 24.0, // Ukuran teks besar
            webShowClose: true, // Menampilkan tombol close di platform web
          );
        } else {
          _showErrorSnackBar('Invalid response from server.');
        }
      } else {
        final String errorMessage = responseData['message'] ?? 'Unknown error';
        _showErrorSnackBar(errorMessage);
      }
    } on SocketException catch (_) {
      _showErrorSnackBar(
          'No internet connection. Please check your network settings.');
    } on TimeoutException catch (_) {
      _showErrorSnackBar('Connection timeout. Please try again later.');
    } catch (error) {
      _showErrorSnackBar('An error occurred: $error. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 24.0),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
            SizedBox(height: 12.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistrasiAkunPage(),
                  ),
                );
              },
              child: Text('Registrasi Akun'),
            ),
          ],
        ),
      ),
    );
  }
}
