import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class TrackingLbsPage extends StatefulWidget {
  const TrackingLbsPage({Key? key}) : super(key: key);

  @override
  State<TrackingLbsPage> createState() => _TrackingLbsPageState();
}

class _TrackingLbsPageState extends State<TrackingLbsPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  GoogleMapController? _googleMapController;

  Position? _currentPosition;
  LatLng? _currentLatLng;

  final Map<MarkerId, Marker> _markers = {};
  final Map<PolylineId, Polyline> _polylines = {};
  final List<LatLng> _route = [];

  bool _isLoading = true;
  bool _isTracking = false;
  double _distance = 0.0;

  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Izin Lokasi Dibutuhkan'),
        content: const Text('Aplikasi memerlukan izin lokasi untuk melacak posisi Anda.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: openAppSettings,
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      _updatePosition(position);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _updatePosition(Position position) {
    _currentPosition = position;
    _currentLatLng = LatLng(position.latitude, position.longitude);

    if (_isTracking) {
      if (_route.isNotEmpty) {
        final last = _route.last;
        _distance += Geolocator.distanceBetween(
          last.latitude, last.longitude,
          position.latitude, position.longitude,
        );
      }
      _route.add(_currentLatLng!);
      _updatePolyline();
    }

    _addMarker();
    _moveToCurrentLocation();
    setState(() => _isLoading = false);
  }

  void _updatePolyline() {
    final polylineId = const PolylineId('route');
    final polyline = Polyline(
      polylineId: polylineId,
      color: Theme.of(context).colorScheme.primary,
      width: 4,
      points: _route,
    );

    setState(() => _polylines[polylineId] = polyline);
  }

  void _addMarker() {
    if (_currentLatLng == null) return;
    final markerId = const MarkerId('current_location');
    final marker = Marker(
      markerId: markerId,
      position: _currentLatLng!,
      infoWindow: const InfoWindow(title: 'Lokasi Saat Ini'),
    );
    setState(() => _markers[markerId] = marker);
  }

  Future<void> _moveToCurrentLocation() async {
    if (_currentLatLng != null && _googleMapController != null) {
      _googleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLatLng!, zoom: 17),
        ),
      );
    }
  }

  void _startTracking() {
    _route.clear();
    _polylines.clear();
    _distance = 0.0;

    if (_currentLatLng != null) {
      _route.add(_currentLatLng!);
    }

    final settings = const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5);
    _positionStream = Geolocator.getPositionStream(locationSettings: settings).listen(_updatePosition);

    setState(() => _isTracking = true);
  }

  void _stopTracking() {
    _positionStream?.cancel();
    setState(() => _isTracking = false);
  }

  void _copyCoordinates() {
    if (_currentPosition == null) return;
    final coords = '${_currentPosition!.latitude}, ${_currentPosition!.longitude}';
    Clipboard.setData(ClipboardData(text: coords));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Koordinat disalin')),
    );
  }

  String _formatDistance(double distance) {
    return distance < 1000
        ? '${distance.toStringAsFixed(0)} m'
        : '${(distance / 1000).toStringAsFixed(2)} km';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Lokasi'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea( // Tambahkan SafeArea di sini
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentLatLng ?? const LatLng(0, 0),
                  zoom: 16,
                ),
                onMapCreated: (controller) {
                  _mapController.complete(controller);
                  _googleMapController = controller;
                },
                markers: Set<Marker>.of(_markers.values),
                polylines: Set<Polyline>.of(_polylines.values),
                myLocationEnabled: true,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _currentPosition != null
                        ? 'Lat: ${_currentPosition!.latitude.toStringAsFixed(5)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(5)}'
                        : 'Lokasi tidak tersedia',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_distance > 0)
                    Text(
                      'Jarak Ditempuh: ${_formatDistance(_distance)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color.primary,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Perbarui'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isTracking ? _stopTracking : _startTracking,
                          icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                          label: Text(_isTracking ? 'Stop' : 'Mulai'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            _isTracking ? color.error : color.secondary,
                            foregroundColor:
                            _isTracking ? Colors.white : color.onSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _copyCoordinates,
                    icon: const Icon(Icons.copy),
                    label: const Text('Salin Koordinat'),
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
