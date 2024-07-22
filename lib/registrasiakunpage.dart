import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegistrasiAkunPage extends StatefulWidget {
  @override
  _RegistrasiAkunPageState createState() => _RegistrasiAkunPageState();
}

class _RegistrasiAkunPageState extends State<RegistrasiAkunPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return; // Jika form tidak valid, hentikan eksekusi
    }

    final String username = _usernameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;

    // Objek data yang akan dikirimkan ke API
    final Map<String, String> data = {
      'username': username,
      'email': email,
      'password': password,
    };

    final Uri url =
        Uri.parse('https://saniangbaka.bisayukbisa.com/api/mobile/register');

    try {
      final http.Response response = await http.post(
        url,
        body: data,
      );

      if (response.statusCode == 200) {
        // Registrasi berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registrasi berhasil'),
          ),
        );
      } else {
        // Registrasi gagal, tampilkan pesan kesalahan dari server
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String errorMessage = responseData['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          ),
        );
      }
    } catch (error) {
      // Error ketika melakukan permintaan HTTP
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan. Silakan coba lagi.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registrasi Akun'),
            Text(
              'Masukkan email yang benar untuk verifikasi',
              style: TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Username tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  final emailRegex = RegExp(r'^[^@]+@gmail\.com$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Masukkan email yang valid';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed:
                    _register, // Panggil fungsi _register saat tombol ditekan
                child: Text('Registrasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
