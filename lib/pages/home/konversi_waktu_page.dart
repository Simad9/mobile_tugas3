import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KonversiWaktuPage extends StatefulWidget {
  const KonversiWaktuPage({super.key});

  @override
  _KonversiWaktuPageState createState() => _KonversiWaktuPageState();
}

class _KonversiWaktuPageState extends State<KonversiWaktuPage> {
  final TextEditingController _yearController = TextEditingController();
  String _result = "";
  DateTime? _selectedDate;

  void _convertFromYears() {
    double? years = double.tryParse(_yearController.text);
    if (years == null) {
      setState(() {
        _result = "Masukkan angka yang valid";
      });
      return;
    }

    double months = years * 12;
    double weeks = years * 52.1429;
    double days = years * 365;
    double hours = days * 24;
    double minutes = hours * 60;
    double seconds = minutes * 60;

    setState(() {
      _result = "${years.toStringAsFixed(2)} tahun =\n"
          "${months.toStringAsFixed(2)} bulan\n"
          "${weeks.toStringAsFixed(2)} minggu\n"
          "${days.toStringAsFixed(2)} hari\n"
          "${hours.toStringAsFixed(2)} jam\n"
          "${minutes.toStringAsFixed(2)} menit\n"
          "${seconds.toStringAsFixed(2)} detik";
    });
  }

  void _convertFromDate() {
    if (_selectedDate == null) {
      setState(() {
        _result = "Pilih tanggal terlebih dahulu";
      });
      return;
    }

    DateTime now = DateTime.now();
    Duration difference = now.difference(_selectedDate!);
    double years = difference.inDays / 365.25;
    double months = difference.inDays / 30.44;
    double weeks = difference.inDays / 7;
    double days = difference.inDays.toDouble();
    double hours = difference.inHours.toDouble();
    double minutes = difference.inMinutes.toDouble();
    double seconds = difference.inSeconds.toDouble();

    setState(() {
      _result = "Dari ${DateFormat('dd MMMM yyyy').format(_selectedDate!)} hingga hari ini =\n"
          "${years.toStringAsFixed(2)} tahun\n"
          "${months.toStringAsFixed(2)} bulan\n"
          "${weeks.toStringAsFixed(2)} minggu\n"
          "${days.toStringAsFixed(2)} hari\n"
          "${hours.toStringAsFixed(2)} jam\n"
          "${minutes.toStringAsFixed(2)} menit\n"
          "${seconds.toStringAsFixed(2)} detik";
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Konversi Waktu"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Masukkan jumlah tahun",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _convertFromYears,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Konversi dari Tahun"),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Pilih Tanggal:", style: TextStyle(fontSize: 16)),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("Pilih"),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedDate != null) ...[
              const SizedBox(height: 8),
              Text(
                "Tanggal dipilih: ${DateFormat('dd MMMM yyyy').format(_selectedDate!)}",
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _convertFromDate,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Konversi dari Tanggal"),
            ),
            const SizedBox(height: 30),
            if (_result.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  _result,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
