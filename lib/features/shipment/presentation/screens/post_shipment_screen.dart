// lib/features/shipment/presentation/screens/post_shipment_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/enums/shipment_type.dart';
import '../../domain/enums/weight_unit.dart';
import '../../domain/enums/safety_option.dart';
import '../providers/shipment_provider.dart';

class PostShipmentScreen extends StatefulWidget {
  const PostShipmentScreen({super.key});

  @override
  State<PostShipmentScreen> createState() => _PostShipmentScreenState();
}

class _PostShipmentScreenState extends State<PostShipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<ShipmentProvider>();

    try {
      // TODO: Call PostShipmentUseCase
      // For now, call existing createShipment with minimal data
      await provider.createShipment(
        shipperName: 'Current User', // TODO: Get from UserProvider
        shipmentType: ShipmentType.dryGoods,
        amount: 0, // Optional for now
        unit: WeightUnit.kg,
        pickup: _originController.text.trim(),
        destination: _destinationController.text.trim(),
        pickupDate: DateTime.now().add(const Duration(days: 1)),
        safetyOption: SafetyOption.normal,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shipment posted successfully! Carriers can now submit bids.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post shipment: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShipmentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post New Shipment'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Origin
              TextFormField(
                controller: _originController,
                decoration: const InputDecoration(
                  labelText: 'Origin *',
                  hintText: 'e.g., Chicago, IL',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Origin is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Destination
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destination *',
                  hintText: 'e.g., Dallas, TX',
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Destination is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe the shipment details...',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _submit,
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Post Shipment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
