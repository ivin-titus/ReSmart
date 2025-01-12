import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum DeviceType {
  headset,
  speaker,
  keyboard,
  computer,
  mobile,
  watch,
  tablet,
  mic,
  mouse,
  gamepad,
  printer,
  car,
  other
}

class BluetoothDevice {
  final String name;
  final String id;
  final DeviceType type;
  final int? batteryLevel;
  final String? codec;
  final bool isStereo;
  final String? useCase;
  final ScanResult? scanResult;
  final bool isConnected;

  const BluetoothDevice({
    required this.name,
    required this.id,
    required this.type,
    this.batteryLevel,
    this.codec,
    this.isStereo = true,
    this.useCase,
    this.scanResult,
    required this.isConnected,
  });

  factory BluetoothDevice.fromScanResult(ScanResult result) {
    final deviceName = result.device.platformName.isNotEmpty
        ? result.device.platformName
        : _getDeviceNameFromManufacturerData(
            result.advertisementData.manufacturerData);

    return BluetoothDevice(
      name: deviceName,
      id: result.device.remoteId.str,
      type: _determineDeviceType(result, deviceName),
      batteryLevel: _getBatteryLevel(result),
      useCase: _determineUseCase(result),
      isConnected: result.device.isConnected,
      scanResult: result,
    );
  }

  static String _getDeviceNameFromManufacturerData(
      Map<int, List<int>> manufacturerData) {
    if (manufacturerData.containsKey(0x004C)) return 'Apple Device';
    if (manufacturerData.containsKey(0x0075)) return 'Samsung Device';
    return 'Unknown Device';
  }

  static DeviceType _determineDeviceType(ScanResult result, String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('headphone') || lowerName.contains('buds'))
      return DeviceType.headset;
    if (lowerName.contains('speaker')) return DeviceType.speaker;
    if (lowerName.contains('keyboard')) return DeviceType.keyboard;
    if (lowerName.contains('pc') || lowerName.contains('computer'))
      return DeviceType.computer;
    if (lowerName.contains('phone')) return DeviceType.mobile;

    final serviceUuids = result.advertisementData.serviceUuids;
    if (serviceUuids.contains('1108')) return DeviceType.headset;
    if (serviceUuids.contains('110A')) return DeviceType.speaker;
    if (serviceUuids.contains('1124')) return DeviceType.keyboard;

    final manufacturerData = result.advertisementData.manufacturerData;
    if (manufacturerData.containsKey(0x004C) ||
        manufacturerData.containsKey(0x0075)) {
      return DeviceType.mobile;
    }

    return DeviceType.other;
  }

  static int? _getBatteryLevel(ScanResult result) {
    try {
      final level = result.advertisementData.serviceData['180F']?.last;
      if (level != null && level <= 100) return level;
    } catch (_) {}
    return null;
  }

  static String? _determineUseCase(ScanResult result) {
    final services = result.advertisementData.serviceUuids;
    if (services.contains('110B')) return 'Media Audio';
    if (services.contains('110C')) return 'Call Audio';
    if (services.contains('111E')) return 'Handsfree';
    return null;
  }
}

class BluetoothDeviceInfo extends StatefulWidget {
  final String title;
  final Color? backgroundColor;
  final TextStyle? titleStyle;

  const BluetoothDeviceInfo({
    Key? key,
    this.title = 'Bluetooth Devices',
    this.backgroundColor,
    this.titleStyle,
  }) : super(key: key);

  @override
  State<BluetoothDeviceInfo> createState() => _BluetoothDeviceInfoState();
}

class _BluetoothDeviceInfoState extends State<BluetoothDeviceInfo> {
  bool _showAllDevices = false;
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  bool _isBluetoothOn = false;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

Future<void> _initBluetooth() async {
  FlutterBluePlus.adapterState.listen((state) {
    setState(() => _isBluetoothOn = state == BluetoothAdapterState.on);
  });

  await _updateConnectedDevices();

  // Remove connection event listener as it's not available
  // Instead, periodically check for connected devices
  Timer.periodic(const Duration(seconds: 2), (_) {
    _updateConnectedDevices();
  });

  FlutterBluePlus.scanResults.listen((results) {
    _updateDevicesFromScan(results);
  });

  FlutterBluePlus.isScanning.listen((scanning) {
    setState(() => _isScanning = scanning);
  });

  if (await FlutterBluePlus.isSupported) {
    _startScan();
  }
}

Future<void> _updateConnectedDevices() async {
  try {
    final connectedDevices = await FlutterBluePlus.connectedSystemDevices;
    if (!mounted) return;
    
    setState(() {
      _devices = [];
      for (var device in connectedDevices) {
        _devices.add(BluetoothDevice(
          name: device.platformName.isNotEmpty ? device.platformName : 'Unknown Device',
          id: device.remoteId.str,
          type: _determineDeviceTypeFromName(device.platformName),
          isConnected: true,
        ));
      }
    });
  } catch (e) {
    debugPrint('Error getting connected devices: $e');
  }
}

  void _updateDevicesFromScan(List<ScanResult> results) {
    setState(() {
      for (var result in results) {
        final index =
            _devices.indexWhere((d) => d.id == result.device.remoteId.str);
        if (index != -1) {
          _devices[index] = BluetoothDevice.fromScanResult(result);
        }
      }
    });
  }

  DeviceType _determineDeviceTypeFromName(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('headphone') || lowerName.contains('buds'))
      return DeviceType.headset;
    if (lowerName.contains('speaker')) return DeviceType.speaker;
    if (lowerName.contains('keyboard')) return DeviceType.keyboard;
    if (lowerName.contains('pc') || lowerName.contains('computer'))
      return DeviceType.computer;
    if (lowerName.contains('phone') || lowerName.contains('5G')) return DeviceType.mobile;
    if (lowerName.contains('watch')) return DeviceType.watch;
    return DeviceType.other;
  }

  Future<void> _startScan() async {
    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );
    } catch (e) {
      debugPrint('Scan error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayDevices =
        _showAllDevices ? _devices : _devices.take(3).toList();

    return Material(
      color: widget.backgroundColor ?? Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.title,
                style:
                    widget.titleStyle?.copyWith(fontWeight: FontWeight.bold) ??
                        Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
              ),
            ),
            const SizedBox(height: 8),
            if (!_isBluetoothOn)
              const _BluetoothStatus(isEnabled: false)
            else if (_devices.isEmpty)
              const _BluetoothStatus(isEnabled: true)
            else
              _buildDeviceList(displayDevices),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList(List<BluetoothDevice> devices) {
    return Column(
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: _showAllDevices ? 300 : double.infinity,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: _showAllDevices
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: devices.length,
            itemBuilder: (context, index) => DeviceListItem(
              device: devices[index],
              onTap: () => _showDeviceInfo(devices[index]),
            ),
          ),
        ),
        if (_devices.length > 3)
          _ShowMoreButton(
            showAll: _showAllDevices,
            onPressed: () => setState(() => _showAllDevices = !_showAllDevices),
          ),
      ],
    );
  }

  void _showDeviceInfo(BluetoothDevice device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(device.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device ID: ${device.id}'),
            Text('Type: ${device.type.toString().split('.').last}'),
            if (device.batteryLevel != null)
              Text('Battery: ${device.batteryLevel}%'),
            if (device.useCase != null) Text('Use: ${device.useCase}'),
            if (device.type == DeviceType.headset) ...[
              if (device.codec != null) Text('Codec: ${device.codec}'),
              Text('Audio: ${device.isStereo ? 'Stereo' : 'Mono'}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _ShowMoreButton extends StatelessWidget {
  final bool showAll;
  final VoidCallback onPressed;

  const _ShowMoreButton({
    required this.showAll,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(showAll ? 'Show Less' : 'Show More'),
          Icon(showAll ? Icons.expand_less : Icons.expand_more),
        ],
      ),
    );
  }
}

class _BluetoothStatus extends StatelessWidget {
  final bool isEnabled;

  const _BluetoothStatus({required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.devices : Icons.bluetooth_disabled,
            color: Colors.grey,
          ),
          const SizedBox(width: 16),
          Text(
            isEnabled
                ? 'No devices connected'
                : 'Bluetooth is off. Turn it on from settings.',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class DeviceListItem extends StatelessWidget {
  final BluetoothDevice device;
  final VoidCallback onTap;

  const DeviceListItem({
    Key? key,
    required this.device,
    required this.onTap,
  }) : super(key: key);

  IconData _getDeviceIcon(DeviceType type) {
    switch (type) {
      case DeviceType.headset:
        return Icons.headset;
      case DeviceType.speaker:
        return Icons.speaker;
      case DeviceType.keyboard:
        return Icons.keyboard;
      case DeviceType.computer:
        return Icons.computer;
      case DeviceType.mobile:
        return Icons.smartphone;
      case DeviceType.watch:
        return Icons.watch;
      case DeviceType.tablet:
        return Icons.tablet;
      case DeviceType.mic:
        return Icons.mic;
      case DeviceType.mouse:
        return Icons.mouse;
      case DeviceType.gamepad:
        return Icons.gamepad;
      case DeviceType.printer:
        return Icons.print;
      case DeviceType.car:
        return Icons.directions_car;
      default:
        return Icons.bluetooth;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_getDeviceIcon(device.type)),
      title: Text(device.name),
      subtitle: Text(device.useCase ?? device.id),
      trailing: BatteryIndicator(level: device.batteryLevel),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class BatteryIndicator extends StatelessWidget {
  final int? level;

  const BatteryIndicator({Key? key, this.level}) : super(key: key);

  Color _getBatteryColor(int? level) {
    if (level == null) return Colors.grey;
    if (level <= 15) return Colors.red;
    if (level <= 50) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 21,
      decoration: BoxDecoration(
        border: Border.all(color: _getBatteryColor(level)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Stack(
        children: [
          if (level != null)
            FractionallySizedBox(
              widthFactor: level! / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: _getBatteryColor(level).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          Center(
            child: Text(
              level != null ? '$level%' : '?',
              style: TextStyle(
                fontSize: 12,
                color: _getBatteryColor(level),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
