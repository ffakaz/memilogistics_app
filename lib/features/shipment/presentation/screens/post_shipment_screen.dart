// lib/features/shipment/presentation/screens/post_shipment_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/enums/shipment_type.dart';
import '../../domain/enums/weight_unit.dart';
import '../../domain/enums/safety_option.dart';
import '../providers/shipment_provider.dart';
import '../../../user/presentation/providers/user_provider.dart';

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
  final _weightController = TextEditingController();
  
  DateTime? _selectedDeliveryDate;
  bool _isFragile = false;
  ShipmentType _selectedType = ShipmentType.dryGoods;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDeliveryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDeliveryDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDeliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery date'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final provider = context.read<ShipmentProvider>();
    final user = context.read<UserProvider>().currentUser;

    try {
      await provider.createShipment(
        shipperName: user?.profile.name ?? 'Current User',
        shipmentType: _selectedType,
        amount: double.parse(_weightController.text.trim()),
        unit: WeightUnit.kg,
        pickup: _originController.text.trim(),
        destination: _destinationController.text.trim(),
        pickupDate: _selectedDeliveryDate!,
        safetyOption: _isFragile ? SafetyOption.fragile : SafetyOption.normal,
        description: _descriptionController.text.trim(),
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

              // Weight in KG
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg) *',
                  hintText: 'e.g., 1500',
                  prefixIcon: Icon(Icons.scale),
                  border: OutlineInputBorder(),
                  suffixText: 'kg',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Weight is required';
                  }
                  final weight = double.tryParse(value.trim());
                  if (weight == null || weight <= 0) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Delivery Date
              InkWell(
                onTap: _selectDeliveryDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Delivery Date *',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDeliveryDate == null
                        ? 'Select delivery date'
                        : '${_selectedDeliveryDate!.year}-${_selectedDeliveryDate!.month.toString().padLeft(2, '0')}-${_selectedDeliveryDate!.day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: _selectedDeliveryDate == null
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Shipment Type
              DropdownButtonFormField<ShipmentType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Shipment Type',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: ShipmentType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getShipmentTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Fragile Checkbox
              CheckboxListTile(
                title: const Text('Fragile'),
                subtitle: const Text('Check if shipment requires special handling'),
                value: _isFragile,
                onChanged: (value) {
                  setState(() {
                    _isFragile = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
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

              // Info Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Carriers will submit bids with their prices. You can review and accept the best offer.',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
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

  String _getShipmentTypeLabel(ShipmentType type) {
    switch (type) {
      case ShipmentType.dryGoods:
        return 'Dry Goods';
      case ShipmentType.electronics:
        return 'Electronics';
      case ShipmentType.fuel:
        return 'Fuel';
      case ShipmentType.fullTruckLoad:
        return 'Full Truck Load (FTL)';
      case ShipmentType.lessThanTruckLoad:
        return 'Less Than Truck Load (LTL)';
      case ShipmentType.partialTruckLoad:
        return 'Partial Truck Load (PTL)';
    }
  }
}
