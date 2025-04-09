import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KonversiWaktuPage extends StatefulWidget {
  const KonversiWaktuPage({super.key});

  @override
  State<KonversiWaktuPage> createState() => _KonversiWaktuPageState();
}

class _KonversiWaktuPageState extends State<KonversiWaktuPage> {
  final TextEditingController _yearController = TextEditingController();
  String _result = "";
  DateTime? _selectedDate;

  void _convertFromYears() {
    double? years = double.tryParse(_yearController.text);
    if (years == null) {
      setState(() => _result = "Masukkan angka yang valid");
      return;
    }

    final months = years * 12;
    final weeks = years * 52.1429;
    final days = years * 365;
    final hours = days * 24;
    final minutes = hours * 60;
    final seconds = minutes * 60;

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
      setState(() => _result = "Pilih tanggal terlebih dahulu");
      return;
    }

    final now = DateTime.now();
    final difference = now.difference(_selectedDate!);

    final years = difference.inDays / 365.25;
    final months = difference.inDays / 30.44;
    final weeks = difference.inDays / 7;
    final days = difference.inDays.toDouble();
    final hours = difference.inHours.toDouble();
    final minutes = difference.inMinutes.toDouble();
    final seconds = difference.inSeconds.toDouble();

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
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
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
            // Input Tahun
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

            // Tombol Konversi Tahun
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

            // Pilih Tanggal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Pilih Tanggal
                Text(
                  "Pilih Tanggal:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_month_outlined, size: 20),
                  label: const Text("Pilih Tanggal"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Tanggal yang Dipilih
            if (_selectedDate != null)
              Text(
                "Tanggal dipilih: ${DateFormat('dd MMMM yyyy').format(_selectedDate!)}",
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),

            const SizedBox(height: 12),

            // Tombol Konversi Tanggal
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

            // Hasil Konversi
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
