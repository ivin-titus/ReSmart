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
  final bool isStereio;
  final String? useCase;
  final ScanResult? scanResult;

  const BluetoothDevice({
    required this.name,
    required this.id,
    required this.type,
    this.batteryLevel,
    this.codec,
    this.isStereio = true,
    this.useCase,
    this.scanResult,
  });

  factory BluetoothDevice.fromScanResult(ScanResult result) {
    final deviceName = result.device.platformName.isNotEmpty
        ? result.device.platformName
        : 'Unknown Device';
    
    return BluetoothDevice(
      name: deviceName,
      id: result.device.remoteId.str,
      type: _determineDeviceType(result),
      batteryLevel: _getBatteryLevel(result),
      scanResult: result,
    );
  }

  static DeviceType _determineDeviceType(ScanResult result) {
    final uuids = result.advertisementData.serviceUuids;
    if (uuids.contains('1108')) return DeviceType.headset;
    if (uuids.contains('110A')) return DeviceType.speaker;
    if (uuids.contains('1124')) return DeviceType.keyboard;
    return DeviceType.other;
  }

  static int? _getBatteryLevel(ScanResult result) {
    try {
      return result.advertisementData.manufacturerData.values
          .first.last;
    } catch (_) {
      return null;
    }
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

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _devices = results
            .map((result) => BluetoothDevice.fromScanResult(result))
            .toList();
      });
    });

    FlutterBluePlus.isScanning.listen((scanning) {
      setState(() => _isScanning = scanning);
    });

    if (await FlutterBluePlus.isSupported) {
      _startScan();
    }
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
            _Header(
              title: widget.title,
              titleStyle: widget.titleStyle,
              isScanning: _isScanning,
              onRefresh: _startScan,
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
        _DeviceList(
          devices: devices,
          onDeviceTap: _connectToDevice,
        ),
        if (_devices.length > 3)
          _ShowMoreButton(
            showAll: _showAllDevices,
            onPressed: () => setState(() => _showAllDevices = !_showAllDevices),
          ),
      ],
    );
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      final bleDevice = device.scanResult?.device;
      if (bleDevice != null) {
        await bleDevice.connect();
        _showDeviceInfo(device);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: $e')),
      );
    }
  }

  void _showDeviceInfo(BluetoothDevice device) {
    showDialog(
      context: context,
      builder: (context) => DeviceInfoDialog(device: device),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final bool isScanning;
  final VoidCallback onRefresh;

  const _Header({
    required this.title,
    this.titleStyle,
    required this.isScanning,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.bluetooth, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: titleStyle ?? Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (isScanning)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
          ),
      ],
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

class _DeviceList extends StatelessWidget {
  final List<BluetoothDevice> devices;
  final Function(BluetoothDevice) onDeviceTap;

  const _DeviceList({required this.devices, required this.onDeviceTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: devices.length > 4
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      itemBuilder: (context, index) => DeviceListItem(
        device: devices[index],
        onTap: () => onDeviceTap(devices[index]),
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
      subtitle: Text(device.id),
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

class DeviceInfoDialog extends StatelessWidget {
  final BluetoothDevice device;

  const DeviceInfoDialog({Key? key, required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(device.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Device ID: ${device.id}'),
          Text('Type: ${device.type.toString().split('.').last}'),
          if (device.type == DeviceType.headset) ...[
            Text('Codec: ${device.codec}'),
            Text('Audio: ${device.isStereio ? 'Stereo' : 'Mono'}'),
            Text('Use: ${device.useCase}'),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
