// lib/features/shipment/presentation/screens/my_shipments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shipment_provider.dart';
import '../../domain/entities/shipment.dart';
import '../../../../core/utils/constants/route_constants.dart';

class MyShipmentsScreen extends StatefulWidget {
  const MyShipmentsScreen({super.key});

  @override
  State<MyShipmentsScreen> createState() => _MyShipmentsScreenState();
}

class _MyShipmentsScreenState extends State<MyShipmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use getMyShipments which calls the role-aware /shipment/my endpoint
      context.read<ShipmentProvider>().getMyShipments();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh shipments when returning to this screen
    // This ensures new shipments appear after creation
    if (mounted) {
      context.read<ShipmentProvider>().getMyShipments();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<ShipmentProvider>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shipments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'In Transit'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Consumer<ShipmentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.shipments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.shipments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Error loading shipments'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => provider.loadShipmentsPaginated(page: 0, size: 20),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final shipments = provider.shipments;

          return RefreshIndicator(
            onRefresh: () async {
              await provider.getMyShipments();
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: shipments.length + (provider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
              if (index >= shipments.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final Shipment shipment = shipments[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Card(
                  child: ListTile(
                    onTap: () => Navigator.pushNamed(context, '/shipment-details', arguments: shipment.id),
                    title: Text(shipment.trackingNumber ?? 'Shipment #${shipment.id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${shipment.origin} → ${shipment.destination}'),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${shipment.status.name}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.local_offer),
                      tooltip: 'View Offers',
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          RouteConstants.shipmentOffers,
                          arguments: shipment.id,
                        );
                      },
                    ),
                    isThreeLine: true,
                  ),
                ),
              );
            },
          ),
          );
        },
      ),
    );
  }
}
