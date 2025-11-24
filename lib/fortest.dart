// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'menu_selection_activity.dart';

// class DeviceScanActivitytest extends StatefulWidget {
//   @override
//   _DeviceScanActivitytestState createState() => _DeviceScanActivitytestState();
// }

// class _DeviceScanActivitytestState extends State<DeviceScanActivitytest> {
//   List<BluetoothDevice> _devices = [];
//   bool _scanning = false;
//   StreamSubscription<List<ScanResult>>? _scanSubscription;
//   String _status = 'Tap scan to start';
//   int _scanCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     _initializeBluetooth();
//   }

//   Future<void> _initializeBluetooth() async {
//     try {
//       // Check if Bluetooth is available
//       bool isAvailable = await FlutterBluePlus.isAvailable;
//       bool isOn = await FlutterBluePlus.isOn;
      
//       print('Bluetooth Available: $isAvailable');
//       print('Bluetooth On: $isOn');
      
//       if (!isOn) {
//         setState(() {
//           _status = 'Please turn on Bluetooth';
//         });
//         return;
//       }
      
//       setState(() {
//         _status = 'Bluetooth is ready. Tap scan button.';
//       });
      
//     } catch (e) {
//       print('Bluetooth init error: $e');
//       setState(() {
//         _status = 'Bluetooth error: $e';
//       });
//     }
//   }

//   Future<void> _requestPermissions() async {
//     try {
//       // Request location permission (required for Android)
//       Map<Permission, PermissionStatus> statuses = await [
//         Permission.location,
//         Permission.bluetooth,
//         Permission.bluetoothConnect,
//         Permission.bluetoothScan,
//       ].request();

//       print('Permission Status:');
//       print('Location: ${statuses[Permission.location]}');
//       print('Bluetooth: ${statuses[Permission.bluetooth]}');
//       print('BluetoothConnect: ${statuses[Permission.bluetoothConnect]}');
//       print('BluetoothScan: ${statuses[Permission.bluetoothScan]}');

//       if (statuses[Permission.location] != PermissionStatus.granted) {
//         setState(() {
//           _status = 'Location permission required for Bluetooth scanning';
//         });
//       }

//     } catch (e) {
//       print('Permission error: $e');
//     }
//   }

//   void _scanDevices(bool enable) {
//     if (enable) {
//       _startScan();
//     } else {
//       _stopScan();
//     }
//   }

//   void _startScan() async {
//     await _requestPermissions();
    
//     bool isOn = await FlutterBluePlus.isOn;
//     if (!isOn) {
//       setState(() {
//         _status = 'Bluetooth is off. Please enable Bluetooth.';
//       });
//       return;
//     }

//     setState(() {
//       _scanning = true;
//       _devices.clear();
//       _scanCount = 0;
//       _status = 'Scanning for devices...';
//     });

//     try {
//       _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
//         if (!mounted) return;
        
//         setState(() {
//           for (ScanResult result in results) {
//             _scanCount++;
//             String deviceName = result.device.platformName;
//             String deviceId = result.device.remoteId.toString();
//             int rssi = result.rssi;
            
//             print('Found device: $deviceName - $deviceId (RSSI: $rssi)');
            
//             // Only add if not already in list
//             if (!_devices.any((device) => device.remoteId == result.device.remoteId)) {
//               _devices.add(result.device);
//               print('✅ Added to list: $deviceName');
//             }
//           }
//           _status = 'Scanning... Found ${_devices.length} device(s) - Total scans: $_scanCount';
//         });
//       }, onError: (error) {
//         print('Scan error: $error');
//         setState(() {
//           _status = 'Scan error: $error';
//         });
//       });

//       // Start scanning with options
//       await FlutterBluePlus.startScan(
//         timeout: Duration(seconds: 15),
//         // Remove filters to see ALL devices
//       );

//       print('Scan started successfully');
      
//       // Auto stop after 15 seconds
//       Timer(Duration(seconds: 15), () {
//         if (_scanning) {
//           _stopScan();
//         }
//       });

//     } catch (e) {
//       print('Start scan error: $e');
//       setState(() {
//         _scanning = false;
//         _status = 'Failed to start scan: $e';
//       });
//     }
//   }

//   void _stopScan() {
//     _scanSubscription?.cancel();
//     _scanSubscription = null;
    
//     FlutterBluePlus.stopScan();
    
//     setState(() {
//       _scanning = false;
//       _status = 'Scan complete. Found ${_devices.length} device(s)';
//     });
    
//     print('Scan stopped. Total devices found: ${_devices.length}');
//   }

//   void _testWithMockDevice() {
//     // Add a mock device for testing
//     setState(() {
//       _status = 'Using mock device for testing';
//     });
    
//     // Navigate directly to menu selection (bypassing Bluetooth)
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MenuSelectionActivity(device: _createMockDevice()),
//       ),
//     );
//   }

//   BluetoothDevice _createMockDevice() {
//     // Create a mock device for testing
//     // Note: This is a simplified approach for testing without real Bluetooth
//     return BluetoothDevice(
//       remoteId: DeviceIdentifier('Mock-Device-123'),
//       // platformName: 'HM-10-MOCK',
//       // type: BluetoothDeviceType.le,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Scan Devices'),
//         actions: [
//           _scanning 
//             ? IconButton(
//                 icon: Icon(Icons.stop),
//                 onPressed: () => _scanDevices(false),
//                 tooltip: 'Stop Scan',
//               )
//             : IconButton(
//                 icon: Icon(Icons.search),
//                 onPressed: () => _scanDevices(true),
//                 tooltip: 'Start Scan',
//               ),
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: () {
//               _stopScan();
//               _devices.clear();
//               _startScan();
//             },
//             tooltip: 'Refresh Scan',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Status indicator
//           Container(
//             padding: EdgeInsets.all(16),
//             color: _scanning ? Colors.blue.shade50 : Colors.grey.shade50,
//             child: Row(
//               children: [
//                 Icon(
//                   _scanning ? Icons.bluetooth_searching : Icons.bluetooth,
//                   color: _scanning ? Colors.blue : Colors.grey,
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(_status, style: TextStyle(fontSize: 14)),
//                       if (_scanning) ...[
//                         SizedBox(height: 4),
//                         LinearProgressIndicator(),
//                       ],
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // Debug information
//           if (_devices.isNotEmpty)
//             Padding(
//               padding: EdgeInsets.all(8),
//               child: Text(
//                 'Debug: ${_devices.length} devices, $_scanCount scans',
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ),

//           // Device list or empty state
//           Expanded(
//             child: _devices.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.bluetooth_disabled, size: 64, color: Colors.grey),
//                         SizedBox(height: 16),
//                         Text(
//                           'No Bluetooth devices found',
//                           style: TextStyle(fontSize: 18, color: Colors.grey),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           'Make sure:\n• Bluetooth is enabled\n• Devices are in range\n• Location permission granted',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                         SizedBox(height: 20),
//                         // Test with mock device button
//                         ElevatedButton.icon(
//                           icon: Icon(Icons.developer_mode),
//                           label: Text('Test with Mock Device'),
//                           onPressed: _testWithMockDevice,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.orange,
//                             foregroundColor: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: _devices.length,
//                     itemBuilder: (context, index) {
//                       final device = _devices[index];
//                       return Card(
//                         margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         child: ListTile(
//                           leading: Icon(Icons.bluetooth_connected, color: Colors.blue),
//                           title: Text(
//                             device.platformName.isEmpty 
//                                 ? 'Unknown Device' 
//                                 : device.platformName,
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('ID: ${device.remoteId}'),
//                               // Text('Type: ${device.deviceType.name}'),
//                             ],
//                           ),
//                           trailing: Icon(Icons.arrow_forward_ios, size: 16),
//                           onTap: () {
//                             _stopScan();
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => MenuSelectionActivity(device: device),
//                               ),
//                             );
//                           },
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//       // Debug floating button
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             heroTag: "btn1",
//             onPressed: () {
//               _showDebugInfo();
//             },
//             child: Icon(Icons.bug_report),
//             mini: true,
//           ),
//           SizedBox(height: 10),
//           if (!_scanning) FloatingActionButton(
//             heroTag: "btn2",
//             onPressed: () => _scanDevices(true),
//             child: Icon(Icons.search),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDebugInfo() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Debug Information'),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Devices found: ${_devices.length}'),
//               Text('Scanning: $_scanning'),
//               Text('Total scans: $_scanCount'),
//               Text('Status: $_status'),
//               SizedBox(height: 16),
//               Text('Device List:'),
//               for (var device in _devices)
//                 Text('- ${device.platformName} (${device.remoteId})'),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _stopScan();
//     super.dispose();
//   }
// }