import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/shipment_provider.dart';
import 'package:memilogistics_app/features/shipper/presentation/providers/shipper_company_provider.dart';

class CreateShipmentScreen extends StatefulWidget {
  const CreateShipmentScreen({super.key});

  @override
  State<CreateShipmentScreen> createState() => _CreateShipmentScreenState();
}

class _CreateShipmentScreenState extends State<CreateShipmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _shipmentItemController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _pickupDate;
  bool _fragile = false;

  @override
  void dispose() {
    _shipmentItemController.dispose();
    _weightController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectPickupDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _pickupDate = selectedDate;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pickupDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pickup date is required')));
      return;
    }

    final provider = context.read<ShipmentProvider>();
    final shipperProvider = context.read<ShipperCompanyProvider>();

    // Ensure shipper profile is loaded
    if (shipperProvider.state.company == null) {
      print('📋 Shipper profile not loaded, fetching...');
      try {
        await shipperProvider.getShipperCompany();
      } catch (e) {
        print('❌ Failed to load shipper profile: $e');
      }
    }

    final shipperCompany = shipperProvider.state.company;
    final shipperId = shipperCompany?.id;

    if (shipperId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create your shipper profile first before creating shipments.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    print('📋 Creating shipment with Shipper ID: $shipperId');

    try {
      await provider.createShipment(
        shipperId: shipperId,  // Include shipper ID
        shipmentItem: _shipmentItemController.text.trim(),
        weightKg: double.parse(_weightController.text.trim()),
        origin: _originController.text.trim(),
        destination: _destinationController.text.trim(),
        pickupDate: _pickupDate!,
        fragile: _fragile,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );

      if (!mounted) return;

      // Refresh the shipments list so new shipment appears immediately
      await context.read<ShipmentProvider>().getMyShipments();
      print('✅ Refreshed shipments list after creation');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shipment created successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      print('❌ Error creating shipment: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create shipment: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShipmentProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Shipment')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Consumer<ShipperCompanyProvider>(
                builder: (context, shipperProvider, _) {
                  final company = shipperProvider.state.company;
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.business_outlined),
                      title: Text(company?.companyName ?? 'Verified shipper'),
                      subtitle: Text(
                        company?.businessName ?? 'Backend profile verified',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              /// SHIPMENT ITEM
              TextFormField(
                controller: _shipmentItemController,
                decoration: const InputDecoration(
                  labelText: 'Shipment Item',
                  hintText: 'e.g., Electronics, Furniture, Dry Goods',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Shipment item is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// WEIGHT IN KG
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  hintText: 'Enter weight in kilograms',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale_outlined),
                  suffixText: 'kg',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Weight is required';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Invalid weight';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// ORIGIN
              TextFormField(
                controller: _originController,
                decoration: const InputDecoration(
                  labelText: 'Origin',
                  hintText: 'Pickup location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.trip_origin),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Origin is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// DESTINATION
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destination',
                  hintText: 'Delivery location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Destination is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// PICKUP DATE
              InkWell(
                onTap: _selectPickupDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Pickup Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _pickupDate == null
                        ? 'Select date'
                        : _pickupDate!.toLocal().toString().split(' ')[0],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// DESCRIPTION (Optional)
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Additional details about the shipment',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),

              const SizedBox(height: 16),

              /// FRAGILE CHECKBOX
              Card(
                child: CheckboxListTile(
                  title: const Text('Fragile Item'),
                  subtitle: const Text('Check if this shipment contains fragile items'),
                  secondary: Icon(
                    _fragile ? Icons.warning : Icons.check_circle_outline,
                    color: _fragile ? Colors.orange : Colors.green,
                  ),
                  value: _fragile,
                  onChanged: (value) {
                    setState(() {
                      _fragile = value ?? false;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              /// SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    foregroundColor: Colors.white,
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text(
                          'Create Shipment',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
