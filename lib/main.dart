import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BluetoothDeviceListScreen(),
    );
  }
}

class BluetoothDeviceListScreen extends StatefulWidget {
  @override
  _BluetoothDeviceListScreenState createState() =>
      _BluetoothDeviceListScreenState();
}

class _BluetoothDeviceListScreenState extends State<BluetoothDeviceListScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<ScanResult> devices = [];
  bool _isLoading = true;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    flutterBlue.scanResults.listen((results) {
      setState(() {
        devices = results;
        _isLoading = false;
      });
    });

    flutterBlue.startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des appareils (r <= 4 mètres)'),
      ),
      body: Column(children: [
        _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (BuildContext context, int index) {
                    print(devices[index]);
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                            'Appareil #${index + 1} - ${devices[index].device.name}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getProximityIndicator(devices[index].rssi),
                            Text('ID : ${devices[index].device.id.toString()}'),
                          ],
                        ),
                        trailing: Text(devices[index].rssi.toString()),
                      ),
                    );
                  },
                ),
              ),
        ElevatedButton(
          onPressed: _startScan,
          child: const Text("Scanner"),
        ),
      ]),
    );
  }
}

Text getProximityIndicator(int rssi) {
  Color textColor;
  String proximityText;

  if (rssi >= -50) {
    textColor = Colors.green; // Très proche (vert)
    proximityText = 'Très proche';
  } else if (rssi >= -60) {
    textColor = Colors.yellow; // Proche (jaune)
    proximityText = 'Proche';
  } else {
    textColor = Colors.red; // Loin (rouge)
    proximityText = 'Loin';
  }

  return Text(
    'Proximité : $proximityText',
    style: TextStyle(color: textColor),
  );
}
