// location_dialog.dart
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationDialog extends StatefulWidget {
  final Function(String) onLocationSubmitted;
  final Function() onAutoLocationRequested;
  final String? initialLocation;

  const LocationDialog({
    Key? key,
    required this.onLocationSubmitted,
    required this.onAutoLocationRequested,
    this.initialLocation,
  }) : super(key: key);

  @override
  _LocationDialogState createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.initialLocation);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Location'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: widget.onAutoLocationRequested,
                icon: const Icon(Icons.my_location),
                label: const Text('Use Current Location'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_locationController.text.isNotEmpty) {
              widget.onLocationSubmitted(_locationController.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}