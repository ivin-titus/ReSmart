import 'package:flutter/material.dart';
import 'widgets/bluetooth_devices.dart';

class DevicesTab extends StatelessWidget {
  const DevicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Devices'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            SizedBox(height: 20),
            BluetoothDeviceInfo(),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
