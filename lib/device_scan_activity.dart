import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'menu_selection_activity.dart';

class DeviceScanActivity extends StatefulWidget {
  final String username;

  DeviceScanActivity({Key? key, required this.username}) : super(key: key);

  @override
  _DeviceScanActivityState createState() => _DeviceScanActivityState();
}

class _DeviceScanActivityState extends State<DeviceScanActivity> {
  List<BluetoothDevice> _devices = [];
  bool _scanning = false;
  late StreamSubscription<List<ScanResult>> _scanSubscription;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      await Permission.bluetooth.request();
      await Permission.locationWhenInUse.request();
    } else {
      await Permission.location.request();
      await Permission.bluetooth.request();
      await Permission.bluetoothConnect.request();
      await Permission.bluetoothScan.request();
    }
  }

  void _scanDevices(bool enable) async {
    try {
      // Check if Bluetooth is available on iOS
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
        if (state != BluetoothAdapterState.on) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please enable Bluetooth on your device')),
            );
          }
          setState(() {
            _scanning = false;
          });
          return;
        }
      }

      setState(() {
        _scanning = enable;
      });

      if (enable) {
        _devices.clear();
        
        _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
          if (mounted) {
            for (ScanResult result in results) {
              if (!_devices.contains(result.device)) {
                setState(() {
                  _devices.add(result.device);
                });
              }
            }
          }
        }, onError: (e) {
          print('Scan error: $e');
          if (mounted) {
            setState(() {
              _scanning = false;
            });
          }
        });

        // Start scan with platform-specific settings
        await FlutterBluePlus.startScan(
          timeout: Duration(seconds: 10),
          androidUsesFineLocation: false,
        );
        
        // Auto stop after 10 seconds
        Future.delayed(Duration(seconds: 10), () {
          if (mounted && _scanning) {
            _scanDevices(false);
          }
        });
      } else {
        await FlutterBluePlus.stopScan();
        _scanSubscription.cancel();
      }
    } catch (e) {
      print('Error in _scanDevices: $e');
      if (mounted) {
        setState(() {
          _scanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning devices: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Devices'),
        actions: [
          IconButton(
            icon: _scanning ? Icon(Icons.stop) : Icon(Icons.search),
            onPressed: () => _scanning ? _scanDevices(false) : _scanDevices(true),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _scanDevices(false);
              setState(() {
                _devices.clear();
              });
              _scanDevices(true);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_scanning) 
            LinearProgressIndicator(),
          Expanded(
            child: _devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bluetooth_disabled,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No devices found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the search icon to start scanning',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: Icon(Icons.bluetooth),
                          title: Text(
                            _devices[index].platformName.isEmpty 
                                ? 'Unknown Device' 
                                : _devices[index].platformName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(_devices[index].remoteId.toString()),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            _scanDevices(false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MenuSelectionActivity(
                                  device: _devices[index],
                                  username:widget.username ,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _devices.isNotEmpty && !_scanning
          ? FloatingActionButton(
              onPressed: () {
                _scanDevices(false);
                setState(() {
                  _devices.clear();
                });
                _scanDevices(true);
              },
              child: Icon(Icons.refresh),
              tooltip: 'Scan Again',
            )
          : null,
    );
  }

  @override
  void dispose() {
    _scanDevices(false);
    super.dispose();
  }
}