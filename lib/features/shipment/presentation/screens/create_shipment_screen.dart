import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shipment_provider.dart';

class CreateShipmentScreen extends StatefulWidget {
  const CreateShipmentScreen({super.key});

  @override
  State<CreateShipmentScreen> createState() =>
      _CreateShipmentScreenState();
}

class _CreateShipmentScreenState
    extends State<CreateShipmentScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _shipperNameController =
      TextEditingController();

  final TextEditingController _amountController =
      TextEditingController();

  final TextEditingController _pickupController =
      TextEditingController();

  final TextEditingController _destinationController =
      TextEditingController();

  DateTime? _pickupDate;

  String _shipmentType = 'dryGoods';

  String _weightUnit = 'kg';

  String _safetyOption = 'normal';

  @override
  void dispose() {
    _shipperNameController.dispose();
    _amountController.dispose();
    _pickupController.dispose();
    _destinationController.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pickup date is required'),
        ),
      );
      return;
    }

    final provider = context.read<ShipmentProvider>();

    try {
      await provider.createShipment(
        shipperName: _shipperNameController.text.trim(),
        shipmentType: _shipmentType,
        amount: double.parse(_amountController.text.trim()),
        unit: _weightUnit,
        pickup: _pickupController.text.trim(),
        destination: _destinationController.text.trim(),
        pickupDate: _pickupDate!,
        safetyOption: _safetyOption,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shipment created successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create shipment: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final provider =
        context.watch<ShipmentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Shipment'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              /// SHIPPER NAME

              TextFormField(
                controller: _shipperNameController,

                decoration: const InputDecoration(
                  labelText: 'Shipper Name',
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Shipper name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// SHIPMENT TYPE

              DropdownButtonFormField<String>(
                value: _shipmentType,

                decoration: const InputDecoration(
                  labelText: 'Shipment Type',
                  border: OutlineInputBorder(),
                ),

                items: ['dryGoods', 'electronics', 'fuel']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),

                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _shipmentType = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              /// AMOUNT

              Row(
                children: [

                  Expanded(
                    flex: 2,

                    child: TextFormField(
                      controller: _amountController,

                      keyboardType: TextInputType.number,

                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Amount is required';
                        }
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed <= 0) {
                          return 'Invalid amount';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _weightUnit,

                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),

                      items: ['kg', 'ton']
                          .map((u) => DropdownMenuItem(
                                value: u,
                                child: Text(u),
                              ))
                          .toList(),

                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _weightUnit = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// PICKUP

              TextFormField(
                controller: _pickupController,

                decoration: const InputDecoration(
                  labelText: 'Pickup Point',
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Address is required';
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
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Address is required';
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
                  ),

                  child: Text(
                    _pickupDate == null
                        ? 'Select date'
                        : _pickupDate!
                            .toLocal()
                            .toString()
                            .split(' ')[0],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// SAFETY OPTION

              const Text(
                'Safety Option',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              Row(
                children: [

                  Expanded(
                    child: RadioListTile<String>(
                        title: const Text('Normal'),

                        value: 'normal',

                        groupValue: _safetyOption,

                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _safetyOption = value;
                            });
                          }
                        },
                      ),
                  ),

                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Fragile'),

                      value: 'fragile',

                      groupValue: _safetyOption,

                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _safetyOption = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// SUBMIT BUTTON

              SizedBox(
                width: double.infinity,

                height: 50,

                child: ElevatedButton(
                  onPressed:
                      provider.isLoading
                          ? null
                          : _submit,

                  child:
                      provider.isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Create Shipment',
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