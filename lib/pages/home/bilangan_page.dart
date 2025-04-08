import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BilanganPage extends StatefulWidget {
  const BilanganPage({Key? key}) : super(key: key);

  @override
  State<BilanganPage> createState() => _BilanganPageState();
}

class _BilanganPageState extends State<BilanganPage> {
  final TextEditingController _inputController = TextEditingController();
  String _hasilCek = '';
  bool _adaError = false;

  void _cekBilangan() {
    String input = _inputController.text.trim();

    // Reset hasil
    setState(() {
      _hasilCek = '';
      _adaError = false;
    });

    // Validasi input
    if (input.isEmpty) {
      setState(() {
        _hasilCek = 'Error: Silakan masukkan angka terlebih dahulu';
        _adaError = true;
      });
      return;
    }

    try {
      // Coba parsing input ke angka
      double angka = double.parse(input);
      List<String> jenisAngka = [];

      // Cek apakah desimal
      bool isDesimal = angka != angka.truncateToDouble();
      if (isDesimal) {
        jenisAngka.add('Bilangan Desimal');
      } else {
        jenisAngka.add('Bilangan Bulat');
      }

      // Cek positif/negatif
      if (angka > 0) {
        jenisAngka.add('Bilangan Positif');
      } else if (angka < 0) {
        jenisAngka.add('Bilangan Negatif');
      } else {
        jenisAngka.add('Bilangan Nol');
      }

      // Cek bilangan cacah (0 dan bilangan bulat positif)
      if (angka >= 0 && !isDesimal) {
        jenisAngka.add('Bilangan Cacah');
      }

      // Cek bilangan prima (hanya untuk bilangan bulat positif > 1)
      if (!isDesimal && angka > 1) {
        bool isPrima = true;
        int angkaInt = angka.toInt();

        for (int i = 2; i <= angkaInt ~/ 2; i++) {
          if (angkaInt % i == 0) {
            isPrima = false;
            break;
          }
        }

        if (isPrima) {
          jenisAngka.add('Bilangan Prima');
        }
      }

      setState(() {
        _hasilCek = 'Angka $angka termasuk:\n${jenisAngka.join('\n')}';
      });
    } catch (e) {
      setState(() {
        _hasilCek = 'Error: Format angka tidak valid';
        _adaError = true;
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jenis Bilangan'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Masukkan angka untuk memeriksa jenis bilangan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _inputController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Masukkan Angka',
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: 23, -7, 3.14',
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _cekBilangan,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Cek Bilangan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_hasilCek.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _adaError ? Colors.red.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _adaError ? Colors.red.shade300 : Colors.green.shade300,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _hasilCek,
                    style: TextStyle(
                      fontSize: 16,
                      color: _adaError ? Colors.red.shade900 : Colors.black,
                      height: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}