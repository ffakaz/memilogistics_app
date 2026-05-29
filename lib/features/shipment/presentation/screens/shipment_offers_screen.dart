// lib/features/shipment/presentation/screens/shipment_offers_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memilogistics_app/features/shipment/presentation/providers/shipment_provider.dart';
import 'package:memilogistics_app/features/shipment_offer/data/models/shipment_offer_model.dart';
import 'package:memilogistics_app/features/shipment/domain/entities/shipment.dart';
import 'package:memilogistics_app/features/shipment/domain/enums/shipment_status.dart';

class ShipmentOffersScreen extends StatefulWidget {
  final int shipmentId;
  const ShipmentOffersScreen({super.key, required this.shipmentId});

  @override
  State<ShipmentOffersScreen> createState() => _ShipmentOffersScreenState();
}

class _ShipmentOffersScreenState extends State<ShipmentOffersScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Shipment? _shipment;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final provider = context.read<ShipmentProvider>();

    try {
      _shipment = await provider.loadShipmentDetail(widget.shipmentId);
      await provider.fetchShipmentOffers(widget.shipmentId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptOffer(ShipmentOfferModel offer) async {
    final provider = context.read<ShipmentProvider>();
    final carrierId = offer.carrierCompanyId ?? offer.carrierCompany?.id;
    if (carrierId == null || carrierId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This offer does not include a valid carrier profile id.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await _confirmOfferAction(
      title: 'Accept Offer?',
      message:
          'Assign this shipment to ${_carrierName(offer)} for \$${offer.price.toStringAsFixed(2)}?',
      confirmLabel: 'Accept',
    );
    if (!confirmed || !mounted) return;

    try {
      await provider.acceptShipmentOffer(
        shipmentId: widget.shipmentId,
        shipmentOfferId: offer.id,
        carrierId: carrierId,
      );
      if (!mounted) return;
      setState(() {
        _shipment =
            provider.activeShipment ??
            provider.getShipmentById(widget.shipmentId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer accepted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept offer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectOffer(ShipmentOfferModel offer) async {
    final provider = context.read<ShipmentProvider>();

    final confirmed = await _confirmOfferAction(
      title: 'Reject Offer?',
      message:
          'Reject the \$${offer.price.toStringAsFixed(2)} offer from ${_carrierName(offer)}?',
      confirmLabel: 'Reject',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    try {
      await provider.cancelShipmentOffer(
        shipmentId: widget.shipmentId,
        shipmentOfferId: offer.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer rejected'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reject offer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _confirmOfferAction({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: destructive
                ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShipmentProvider>();
    final offers = provider.offersCache[widget.shipmentId] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Shipment Offers')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 12),
                  Text('Error: $_errorMessage'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                _shipment = await provider.loadShipmentDetail(
                  widget.shipmentId,
                );
                await provider.fetchShipmentOffers(widget.shipmentId);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_shipment != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Shipment: ${_shipment!.trackingNumber}'),
                            const SizedBox(height: 8),
                            Text('Status: ${_shipment!.status.displayName}'),
                            const SizedBox(height: 8),
                            Text(
                              '${_shipment!.origin} → ${_shipment!.destination}',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Text(
                    'Offers (${offers.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (offers.isEmpty)
                    Center(
                      child: Column(
                        children: const [
                          Icon(
                            Icons.local_offer_outlined,
                            size: 72,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text('No offers yet'),
                        ],
                      ),
                    )
                  else
                    ...offers.map((o) => _buildOfferCard(o, provider)).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildOfferCard(ShipmentOfferModel offer, ShipmentProvider provider) {
    final isSubmitting = provider.isMutatingOffer(offer.id);
    final shipmentIsPending =
        _shipment?.status == null ||
        _shipment?.status == ShipmentStatus.pending;
    final actionsDisabled = isSubmitting || !shipmentIsPending;
    final carrierName = _carrierName(offer);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF2C3E50),
                  child: Text(
                    carrierName.isEmpty
                        ? 'C'
                        : carrierName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        carrierName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(offer.carrierCompany?.companyEmail ?? ''),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '\$${offer.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF27AE60),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Submitted: ${_formatDateTime(offer.createdAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            if (!shipmentIsPending)
              const Text(
                'This shipment has already been assigned.',
                style: TextStyle(fontWeight: FontWeight.w600),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: actionsDisabled
                          ? null
                          : () => _rejectOffer(offer),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      icon: isSubmitting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: actionsDisabled
                          ? null
                          : () => _acceptOffer(offer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                      ),
                      icon: isSubmitting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.check, size: 18),
                      label: const Text('Accept'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _carrierName(ShipmentOfferModel offer) {
    final name = offer.carrierCompany?.companyName.trim();
    if (name != null && name.isNotEmpty) return name;

    final carrierId = offer.carrierCompanyId ?? offer.carrierCompany?.id;
    return carrierId == null ? 'Carrier' : 'Carrier $carrierId';
  }
}
