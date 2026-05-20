import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:memilogistics_app/core/core.dart';
import 'package:memilogistics_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:memilogistics_app/features/carrier/presentation/providers/carrier_company_provider.dart';
import 'package:memilogistics_app/features/shipment/presentation/providers/shipment_provider.dart';
import 'package:memilogistics_app/features/shipment_offer/presentation/providers/shipment_offer_provider.dart';
import 'package:memilogistics_app/features/payment/presentation/providers/payment_provider.dart';
import 'package:memilogistics_app/features/user/presentation/provider/user_provider.dart';

class AppProviders {
  const AppProviders._();

  static List<SingleChildWidget> get providers {
    return [
      Provider<SecureStorageService>.value(
        value: locator<SecureStorageService>(),
      ),
      ChangeNotifierProvider<AuthProvider>.value(
        value: locator<AuthProvider>()..init(),
      ),
      ChangeNotifierProvider<UserProvider>.value(
        value: locator<UserProvider>(),
      ),
      ChangeNotifierProvider<ShipmentProvider>.value(
        value: locator<ShipmentProvider>(),
      ),
      ChangeNotifierProvider<CarrierCompanyProvider>.value(
        value: locator<CarrierCompanyProvider>(),
      ),
      ChangeNotifierProvider<ShipmentOfferProvider>.value(
        value: locator<ShipmentOfferProvider>(),
      ),
      ChangeNotifierProvider<PaymentProvider>.value(
        value: locator<PaymentProvider>(),
      ),
    ];
  }
}
