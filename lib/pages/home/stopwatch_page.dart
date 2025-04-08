import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  List<Duration> _lapTimes = [];

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {});
    });
  }

  void _toggleStopwatch() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer.cancel();
    } else {
      _stopwatch.start();
      _startTimer();
    }
    setState(() {});
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    _lapTimes.clear();
    setState(() {});
  }

  void _recordLap() {
    setState(() {
      _lapTimes.insert(0, _stopwatch.elapsed); // Simpan total waktu
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final milliseconds = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return "$minutes:$seconds:$milliseconds";
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_stopwatch.elapsed.inMilliseconds % 60000) / 60000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Stopwatch Display with Circular Progress
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    color: Colors.deepPurpleAccent,
                    backgroundColor: Colors.black12,
                  ),
                ),
                Text(
                  _formatDuration(_stopwatch.elapsed),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Icon Button: Start/Stop toggle
            IconButton(
              iconSize: 60,
              icon: Icon(
                _stopwatch.isRunning ? Icons.pause_circle : Icons.play_circle,
                color: _stopwatch.isRunning ? Colors.redAccent : Colors.purple,
              ),
              onPressed: _toggleStopwatch,
            ),

            const SizedBox(height: 16),

            // Reset and Lap buttons aligned left and right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _resetStopwatch,
                  icon: const Icon(Icons.replay),
                  label: const Text("Reset"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
                ElevatedButton.icon(
                  onPressed: _recordLap,
                  icon: const Icon(Icons.flag),
                  label: const Text("Lap"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Lap List
            Expanded(
              child: _lapTimes.isEmpty
                  ? const Center(child: Text("Belum ada lap."))
                  : ListView.builder(
                itemCount: _lapTimes.length,
                itemBuilder: (context, index) {
                  final lapIndex = _lapTimes.length - index;
                  final currentLap = _lapTimes[index];
                  final previousLap = index < _lapTimes.length - 1
                      ? _lapTimes[index + 1]
                      : Duration.zero;
                  final lapDuration = currentLap - previousLap;

                  return ListTile(
                    leading: Text(
                      "Lap $lapIndex",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    title: Text("Lap Time: ${_formatDuration(lapDuration)}"),
                    trailing: Text(_formatDuration(currentLap)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
