import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class BluetoothDevicesSection extends StatefulWidget {
  @override
  _BluetoothDevicesSectionState createState() =>
      _BluetoothDevicesSectionState();
}


class _BluetoothDevicesSectionState extends State<BluetoothDevicesSection> {
  final _ble = FlutterReactiveBle();
  List<DiscoveredDevice> discoveredDevices = [];
  bool showAllDevices = false;
  Map<String, int> batteryLevels = {};
  StreamSubscription? _scanSubscription;
  StreamSubscription? _statusSubscription;
  Map<String, StreamSubscription> _batterySubscriptions = {};
  bool isScanning = false;

  static const String BATTERY_SERVICE_UUID = '180F';
  static const String BATTERY_CHARACTERISTIC_UUID = '2A19';

  @override
  void initState() {
    super.initState();
    _initializeBle();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _statusSubscription?.cancel();
    _batterySubscriptions.values.forEach((sub) => sub.cancel());
    super.dispose();
  }

  Future<void> _initializeBle() async {
    await _getPermissions();
    _statusSubscription = _ble.statusStream.listen((status) {
      if (status == BleStatus.ready) {
        _startScan();
      }
    });
  }

  Future<void> _getPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  void _startScan() {
    setState(() {
      discoveredDevices = [];
      isScanning = true;
    });

    _scanSubscription?.cancel();
    _scanSubscription = _ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    ).listen(
      (device) {
        if (device.name.isEmpty) return; // Skip unnamed devices

        final knownDeviceIndex = discoveredDevices.indexWhere(
          (d) => d.id == device.id,
        );

        setState(() {
          if (knownDeviceIndex >= 0) {
            discoveredDevices[knownDeviceIndex] = device;
          } else {
            discoveredDevices.add(device);
            _connectAndMonitor(device);
          }
        });
      },
      onError: (e) => print('Error scanning: $e'),
    );

    Timer(Duration(seconds: 10), () {
      _scanSubscription?.cancel();
      setState(() => isScanning = false);
    });
  }

  void _connectAndMonitor(DiscoveredDevice device) async {
    try {
      final connection = _ble.connectToDevice(
        id: device.id,
        servicesWithCharacteristicsToDiscover: {
          Uuid.parse(BATTERY_SERVICE_UUID): [
            Uuid.parse(BATTERY_CHARACTERISTIC_UUID)
          ]
        },
        connectionTimeout: const Duration(seconds: 2),
      );

      connection.listen((state) {
        switch (state.connectionState) {
          case DeviceConnectionState.connected:
            _monitorBatteryLevel(device);
            break;
          case DeviceConnectionState.disconnected:
            _batterySubscriptions[device.id]?.cancel();
            break;
          default:
            break;
        }
      });
    } catch (e) {
      print('Connection error: $e');
    }
  }

  void _monitorBatteryLevel(DiscoveredDevice device) {
    final characteristic = QualifiedCharacteristic(
      serviceId: Uuid.parse(BATTERY_SERVICE_UUID),
      characteristicId: Uuid.parse(BATTERY_CHARACTERISTIC_UUID),
      deviceId: device.id,
    );

    _batterySubscriptions[device.id]?.cancel();
    _batterySubscriptions[device.id] =
        _ble.subscribeToCharacteristic(characteristic).listen(
      (data) {
        if (data.isNotEmpty) {
          setState(() => batteryLevels[device.id] = data[0]);
        }
      },
      onError: (e) => print('Battery monitoring error: $e'),
    );
  }

  // Rest of the code remains the same...
  IconData _getDeviceIcon(DiscoveredDevice device) {
    final name = device.name.toLowerCase();

    if (name.contains('keyboard')) return Icons.keyboard;
    if (name.contains('mouse')) return Icons.mouse;
    if (name.contains('headphone') || name.contains('buds'))
      return Icons.headphones;
    if (name.contains('watch')) return Icons.watch;
    if (name.contains('speaker')) return Icons.speaker;
    if (name.contains('phone')) return Icons.phone_android;
    if (name.contains('tv')) return Icons.tv;
    if (name.contains('car')) return Icons.directions_car;
    if (name.contains('game')) return Icons.games;

    return Icons.bluetooth;
  }

  Widget _buildBatteryIndicator(DiscoveredDevice device, ThemeData theme) {
    int? batteryLevel = batteryLevels[device.id];
    IconData icon = batteryLevel == null
        ? Icons.battery_unknown
        : batteryLevel <= 20
            ? Icons.battery_alert
            : batteryLevel <= 50
                ? Icons.battery_5_bar
                : Icons.battery_full;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.colorScheme.onPrimaryContainer, size: 20),
          if (batteryLevel != null) ...[
            SizedBox(width: 6),
            Text(
              '$batteryLevel%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayDevices =
        showAllDevices ? discoveredDevices : discoveredDevices.take(4).toList();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  "Connected Devices",
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Spacer(),
                if (isScanning)
                  SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2))
                else
                  IconButton(
                    icon: Icon(Icons.refresh, size: 24),
                    onPressed: _startScan,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tightFor(width: 40, height: 40),
                  ),
              ],
            ),
            if (discoveredDevices.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(Icons.devices_other, size: 20),
                    SizedBox(width: 10),
                    Text(isScanning ? "Scanning..." : "No devices found",
                        style: theme.textTheme.bodyLarge),
                  ],
                ),
              )
            else
              Column(
                children: [
                  ...displayDevices.map((device) => Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            Icon(_getDeviceIcon(device), size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.name.isNotEmpty
                                        ? device.name
                                        : 'Unknown Device',
                                    style: theme.textTheme.bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    'Signal: ${device.rssi} dBm',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.textTheme.bodySmall?.color
                                            ?.withOpacity(0.7)),
                                  ),
                                ],
                              ),
                            ),
                            _buildBatteryIndicator(device, theme),
                          ],
                        ),
                      )),
                  if (discoveredDevices.length > 4)
                    TextButton(
                      onPressed: () =>
                          setState(() => showAllDevices = !showAllDevices),
                      child: Text(
                        showAllDevices
                            ? "Show Less"
                            : "Show More (${discoveredDevices.length - 4})",
                        style: TextStyle(fontSize: 16),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
