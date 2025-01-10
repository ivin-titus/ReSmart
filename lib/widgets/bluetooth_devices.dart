import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:collection/collection.dart';
import 'dart:async';

class BluetoothDevicesSection extends StatefulWidget {
  @override
  _BluetoothDevicesSectionState createState() => _BluetoothDevicesSectionState();
}

class _BluetoothDevicesSectionState extends State<BluetoothDevicesSection> {
  List<BluetoothDevice> connectedDevices = [];
  bool isBluetoothOn = false;
  Map<BluetoothDevice, int?> batteryLevels = {};

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
    _getPermissions();
  }

  void _checkBluetoothState() async {
    BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
    setState(() {
      isBluetoothOn = (state == BluetoothAdapterState.on);
    });
    if (isBluetoothOn) {
      _getConnectedDevices();
    }
  }

  void _getPermissions() async {
    if (await Permission.location.isGranted) {
      // Permissions granted
    } else {
      await Permission.location.request();
    }
  }

  void _getConnectedDevices() {
    setState(() {
      connectedDevices = FlutterBluePlus.connectedDevices;
    });
    // Retrieve battery levels for each device
    for (var device in connectedDevices) {
      _getBatteryLevel(device);
    }
  }

  Future<void> _getBatteryLevel(BluetoothDevice device) async {
    int? batteryLevel = await _retrieveBatteryLevel(device);
    if (mounted) {
      setState(() {
        batteryLevels[device] = batteryLevel;
      });
    }
  }

Future<int?> _retrieveBatteryLevel(BluetoothDevice device) async {
  try {
    // Ensure the device is connected
    if (!device.isConnected) {
      await device.connect();
    }

    // Discover services
    await device.discoverServices();

    // Get the list of services
    final services = await device.services.first;
    BluetoothService? batteryService = services.firstWhereOrNull(
        (service) => service.uuid.toString() == '0000180f-0000-1000-8000-00805f9b34fb');

    if (batteryService != null) {
      // Get the list of characteristics
      final characteristics = batteryService.characteristics;
      BluetoothCharacteristic? batteryLevelCharacteristic = characteristics.firstWhereOrNull(
          (characteristic) => characteristic.uuid.toString() == '00002a19-0000-1000-8000-00805f9b34fb');

      if (batteryLevelCharacteristic != null) {
        // Read the battery level
        await batteryLevelCharacteristic.read();

        // Listen to the value stream to get the latest value
        List<int>? value;
        await for (final val in batteryLevelCharacteristic.value) {
          if (val.isNotEmpty) {
            value = val;
            break;
          }
        }

        if (value != null && value.isNotEmpty) {
          // Interpret the battery level value
          int batteryLevel = value.first;
          print('Battery level: $batteryLevel');
          return batteryLevel;
        } else {
          print('Battery level characteristic value is empty.');
        }
      } else {
        print('Battery level characteristic not found.');
      }
    } else {
      print('Battery service not found.');
    }
  } catch (e) {
    print('Error retrieving battery level: $e');
  } finally {
    // Disconnect the device
    if (device.isConnected) {
      await device.disconnect();
    }
  }
  return null;
}

  void _showDeviceDetails(BluetoothDevice device) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(device.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Address: ${device.id}'),
              Text('Is Connected: ${device.isConnected.toString()}'),
              // Add more details as available
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Section
          Text(
            "Bluetooth Devices",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // Bluetooth Status Handling
          if (!isBluetoothOn)
            Card(
              color: Colors.yellow[200],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Bluetooth is off. Turn it on from settings.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          SizedBox(height: 16),

          // Connection Status
          if (isBluetoothOn && connectedDevices.isEmpty)
            Text(
              "No devices connected.",
              style: TextStyle(fontSize: 16),
            ),

          // Connected Devices List
          if (isBluetoothOn && connectedDevices.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: connectedDevices.length,
                itemBuilder: (context, index) {
                  BluetoothDevice device = connectedDevices[index];
                  return ListTile(
                    title: Text(device.name),
                    trailing: _buildBatteryIndicator(device),
                    onTap: () => _showDeviceDetails(device),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBatteryIndicator(BluetoothDevice device) {
    int? batteryLevel = batteryLevels[device];
    if (batteryLevel != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.battery_full),
          Text('$batteryLevel%'),
        ],
      );
    } else {
      return Icon(Icons.battery_unknown);
    }
  }
}