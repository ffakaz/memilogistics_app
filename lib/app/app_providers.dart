import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:memilogistics_app/features/carrier/presentation/providers/carrier_company_provider.dart';
import 'package:memilogistics_app/features/shipper/presentation/providers/shipper_company_provider.dart';

import 'package:memilogistics_app/core/di/service_locator.dart';

import 'package:memilogistics_app/features/auth/presentation/provider/auth_provider.dart';

import 'package:memilogistics_app/features/shipment/presentation/provider/shipment_provider.dart';
import 'package:memilogistics_app/features/shipment_offer/presentation/providers/shipment_offer_provider.dart';

import 'package:memilogistics_app/features/user/presentation/provider/user_provider.dart';

class AppProviders {

  static final List<SingleChildWidget> providers = [

    ChangeNotifierProvider<AuthProvider>(
      create: (_) => locator<AuthProvider>()..init(),
    ),

    ChangeNotifierProvider<ShipmentProvider>(
      create: (_) => locator<ShipmentProvider>(),
    ),

    ChangeNotifierProvider<ShipmentOfferProvider>(
      create: (_) => locator<ShipmentOfferProvider>(),
    ),

    ChangeNotifierProvider<CarrierCompanyProvider>(
      create: (_) => locator<CarrierCompanyProvider>(),
    ),

    ChangeNotifierProvider<ShipperCompanyProvider>(
      create: (_) => locator<ShipperCompanyProvider>(),
    ),

    ChangeNotifierProvider<UserProvider>(
      create: (_) => locator<UserProvider>(),
    ),
  ];
}