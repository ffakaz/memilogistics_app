import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memilogistics_app/app/app.dart';
import 'package:memilogistics_app/bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    await initApp();
  });

  testWidgets('shows login screen when signed out', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MemiLogisticsApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('MEMI LOGISTICS'), findsOneWidget);
    expect(find.text('Sign in to your workspace'), findsOneWidget);
  });
}
