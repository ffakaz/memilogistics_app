import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/enums/shipment_status.dart';
import '../providers/shipment_provider.dart';

class InTransitScreen extends StatefulWidget {
  final Shipment shipment;
  const InTransitScreen({super.key, required this.shipment});

  @override
  State<InTransitScreen> createState() => _InTransitScreenState();
}

class _InTransitScreenState extends State<InTransitScreen> {
  final TextEditingController _locationController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.shipment.destination;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _updateLocation() async {
    final loc = _locationController.text.trim();
    if (loc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await context.read<ShipmentProvider>().updateShipmentStatus(
            widget.shipment.id!,
            ShipmentStatus.inTransit,
            location: loc,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location updated')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update location: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.shipment;
    return Scaffold(
      appBar: AppBar(
        title: Text('In Transit - ${s.trackingNumber ?? 'Shipment'}'),
        backgroundColor: const Color(0xFF2C3E50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${s.status.displayName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Tracking: ${s.trackingNumber ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Origin: ${s.origin}'),
            const SizedBox(height: 8),
            Text('Destination: ${s.destination}'),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Update Current Location', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _updateLocation,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3E50)),
                child: _loading ? const CircularProgressIndicator() : const Text('Update Location'),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Note: Location updates are recorded in shipment events and visible in the timeline.'),
          ],
        ),
      ),
    );
  }
}
