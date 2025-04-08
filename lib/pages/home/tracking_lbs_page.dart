import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_tugas3/components/list_home.dart';

class TrackingLbsPage extends StatefulWidget {
  const TrackingLbsPage({Key? key}) : super(key: key);

  @override
  State<TrackingLbsPage> createState() => _TrackingLbsPageState();
}

class _TrackingLbsPageState extends State<TrackingLbsPage> with WidgetsBindingObserver {
  final Completer<GoogleMapController> _kontrolerPeta = Completer();
  GoogleMapController? _googleMapController;

  Position? _posisiSaatIni;
  LatLng? _posisiSaatIniLatLng;

  final Map<MarkerId, Marker> _penanda = {};
  final Map<PolylineId, Polyline> _polylines = {};
  final List<LatLng> _rutePerjalanan = [];

  bool _memuat = true;
  bool _pelacakanAktif = false;
  Timer? _timer;

  double _jarakPerjalanan = 0.0; // dalam meter

  // Stream controller untuk memperbarui UI secara realtime
  final _locationStreamController = StreamController<Position>.broadcast();
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mintaIzinLokasi();

    // Listen to location stream
    _locationStreamController.stream.listen((Position position) {
      _updatePositionData(position);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _googleMapController?.dispose();
    _timer?.cancel();
    _positionStreamSubscription?.cancel();
    _locationStreamController.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh map when app is resumed
      _googleMapController?.setMapStyle("[]");
    }
  }

  // Fungsi untuk meminta izin lokasi
  Future<void> _mintaIzinLokasi() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      await _dapatkanPosisiSekarang();
    } else {
      _tampilkanDialogIzin();
    }
  }

  // Fungsi untuk menampilkan dialog jika izin ditolak
  void _tampilkanDialogIzin() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Izin Lokasi Diperlukan'),
        content: const Text('Aplikasi memerlukan akses lokasi untuk fitur pelacakan. Silakan berikan izin pada pengaturan aplikasi.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk mendapatkan posisi saat ini tanpa menyebabkan refresh UI secara keseluruhan
  Future<void> _dapatkanPosisiSekarang() async {
    try {
      Position posisi = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Kirim posisi ke stream untuk update UI
      _locationStreamController.add(posisi);
    } catch (e) {
      setState(() {
        _memuat = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mendapatkan lokasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Update data posisi tanpa setState keseluruhan
  void _updatePositionData(Position posisi) {
    _posisiSaatIni = posisi;
    _posisiSaatIniLatLng = LatLng(posisi.latitude, posisi.longitude);

    // Jika sedang pelacakan aktif, tambahkan ke rute perjalanan
    if (_pelacakanAktif && _rutePerjalanan.isNotEmpty) {
      // Hitung jarak dari posisi sebelumnya
      final LatLng posisiSebelumnya = _rutePerjalanan.last;
      final double jarakBaru = Geolocator.distanceBetween(
          posisiSebelumnya.latitude,
          posisiSebelumnya.longitude,
          posisi.latitude,
          posisi.longitude
      );

      _jarakPerjalanan += jarakBaru;
      _rutePerjalanan.add(_posisiSaatIniLatLng!);
      _updatePolyline();
    } else if (_pelacakanAktif && _rutePerjalanan.isEmpty) {
      // Jika ini adalah titik pertama dalam rute
      _rutePerjalanan.add(_posisiSaatIniLatLng!);
    }

    // Update marker
    _tambahPenanda();

    // Update kamera
    _geserKePosisiSaatIni();

    // Update UI hanya untuk bagian koordinat
    setState(() {
      _memuat = false;
    });
  }

  // Fungsi untuk menambahkan/memperbarui polyline rute perjalanan
  void _updatePolyline() {
    final PolylineId polylineId = const PolylineId('rute_perjalanan');
    final Polyline polyline = Polyline(
      polylineId: polylineId,
      color: Colors.blue,
      width: 5,
      points: _rutePerjalanan,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    setState(() {
      _polylines[polylineId] = polyline;
    });
  }

  // Fungsi untuk menambahkan penanda pada peta
  void _tambahPenanda() {
    if (_posisiSaatIniLatLng == null) return;

    final markerId = const MarkerId('posisi_saat_ini');
    final marker = Marker(
      markerId: markerId,
      position: _posisiSaatIniLatLng!,
      infoWindow: const InfoWindow(title: 'Lokasi Saat Ini'),
    );

    setState(() {
      _penanda[markerId] = marker;
    });
  }

  // Fungsi untuk menggeser kamera ke posisi saat ini
  Future<void> _geserKePosisiSaatIni() async {
    if (_posisiSaatIniLatLng == null || _googleMapController == null) return;

    await _googleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _posisiSaatIniLatLng!,
          zoom: 17,
        ),
      ),
    );
  }

  // Fungsi untuk menyalin koordinat ke clipboard
  void _salinKoordinat() {
    if (_posisiSaatIni == null) return;

    final koordinatString = '${_posisiSaatIni!.latitude}, ${_posisiSaatIni!.longitude}';
    Clipboard.setData(ClipboardData(text: koordinatString));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Koordinat berhasil disalin ke clipboard'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Fungsi untuk memulai pelacakan lokasi secara realtime
  void _mulaiPelacakan() {
    // Reset rute dan jarak jika memulai pelacakan baru
    _rutePerjalanan.clear();
    _polylines.clear();
    _jarakPerjalanan = 0.0;

    if (_posisiSaatIniLatLng != null) {
      _rutePerjalanan.add(_posisiSaatIniLatLng!);
    }

    // Mulai pelacakan dengan location stream
    final LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update setiap bergerak 5 meter
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings
    ).listen((Position position) {
      _locationStreamController.add(position);
    });

    setState(() {
      _pelacakanAktif = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pelacakan lokasi dimulai'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Fungsi untuk menghentikan pelacakan lokasi
  void _hentikanPelacakan() {
    setState(() {
      _pelacakanAktif = false;
    });

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pelacakan lokasi dihentikan'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Format koordinat dengan 6 digit di belakang koma
  String _formatKoordinat(double? koordinat) {
    if (koordinat == null) return '-';
    return koordinat.toStringAsFixed(6);
  }

  // Format jarak dalam meter atau kilometer
  String _formatJarak(double jarak) {
    if (jarak < 1000) {
      return '${jarak.toStringAsFixed(0)} meter';
    } else {
      return '${(jarak / 1000).toStringAsFixed(2)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking LBS'),
        backgroundColor: Colors.blue,
      ),
      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            flex: 3,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _posisiSaatIniLatLng ?? const LatLng(0, 0),
                zoom: 15,
              ),
              markers: Set<Marker>.of(_penanda.values),
              polylines: Set<Polyline>.of(_polylines.values),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _kontrolerPeta.complete(controller);
                _googleMapController = controller;

                if (_posisiSaatIniLatLng != null) {
                  _geserKePosisiSaatIni();
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lokasi Saat Ini:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_pelacakanAktif)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Text(
                          'Pelacakan Aktif',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_posisiSaatIni != null)
                  InkWell(
                    onTap: _salinKoordinat,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${_formatKoordinat(_posisiSaatIni!.latitude)}, ${_formatKoordinat(_posisiSaatIni!.longitude)}',
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.copy, size: 18),
                        ],
                      ),
                    ),
                  )
                else
                  const Text('Lokasi tidak tersedia'),
                if (_pelacakanAktif || _jarakPerjalanan > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blue[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.directions_walk, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Jarak ditempuh: ${_formatJarak(_jarakPerjalanan)}',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _dapatkanPosisiSekarang,
                        icon: const Icon(Icons.my_location, size: 18),
                        label: const Text('Perbarui'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pelacakanAktif ? _hentikanPelacakan : _mulaiPelacakan,
                        icon: Icon(_pelacakanAktif ? Icons.stop : Icons.play_arrow, size: 18),
                        label: Text(_pelacakanAktif ? 'Hentikan' : 'Mulai'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pelacakanAktif ? Colors.red : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}