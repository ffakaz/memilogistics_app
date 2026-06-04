// lib/features/carrier/presentation/screens/offerable_loads_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shipment/presentation/providers/shipment_provider.dart';
import '../../../shipment/domain/entities/shipment.dart';
import '../../../shipment/domain/enums/shipment_status.dart';
import '../../../shipment_offer/presentation/providers/shipment_offer_provider.dart';
import '../../../shipment_offer/presentation/widgets/shipment_offer_dialog.dart';
import '../widgets/offerable_shipment_card.dart';

/// Screen 1: Offerable Loads
/// Shows PENDING and ACCEPTED shipments available for bidding
/// Features: Search, Filter, Pagination, Make Offer
class OfferableLoadsScreen extends StatefulWidget {
  const OfferableLoadsScreen({super.key});

  @override
  State<OfferableLoadsScreen> createState() => _OfferableLoadsScreenState();
}

class _OfferableLoadsScreenState extends State<OfferableLoadsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _filterStatus = 'All'; // All, Pending, Accepted

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShipmentProvider>().getAvailableShipments();
      context.read<ShipmentOfferProvider>().loadMyOffers();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ShipmentProvider>().loadNextPage();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Shipment> _filterShipments(List<Shipment> shipments) {
    return shipments.where((shipment) {
      // Only show unassigned shipments (offerable)
      if (shipment.assignedCarrierId != null) return false;

      // Filter by status
      final statusMatch = _filterStatus == 'All' ||
          (_filterStatus == 'Pending' &&
              shipment.status == ShipmentStatus.pending) ||
          (_filterStatus == 'Accepted' &&
              shipment.status == ShipmentStatus.accepted);

      if (!statusMatch) return false;

      // Filter by search query
      if (_searchQuery.isEmpty) return true;

      final query = _searchQuery.toLowerCase();
      final trackingNumber = (shipment.trackingNumber ?? '').toLowerCase();
      final origin = shipment.origin.toLowerCase();
      final destination = shipment.destination.toLowerCase();

      return trackingNumber.contains(query) ||
          origin.contains(query) ||
          destination.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offerable Loads'),
        backgroundColor: const Color(0xFF2C3E50),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: Consumer<ShipmentProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.shipments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null &&
                    provider.shipments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(provider.errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredShipments = _filterShipments(provider.shipments);

                if (filteredShipments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_shipping_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No Offerable Loads',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Available shipments will appear here',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredShipments.length +
                        (provider.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredShipments.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final shipment = filteredShipments[index];
                      return OfferableShipmentCard(
                        shipment: shipment,
                        onMakeOffer: () => _showOfferDialog(shipment),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by tracking, origin, destination...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          const SizedBox(height: 12),
          // Filter chips
          Row(
            children: [
              const Text(
                'Filter:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              _buildFilterChip('All'),
              const SizedBox(width: 8),
              _buildFilterChip('Pending'),
              const SizedBox(width: 8),
              _buildFilterChip('Accepted'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterStatus == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = label);
      },
      selectedColor: const Color(0xFF2C3E50),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  void _showOfferDialog(Shipment shipment) {
    showDialog(
      context: context,
      builder: (context) => ShipmentOfferDialog(shipment: shipment),
    );
  }
}
