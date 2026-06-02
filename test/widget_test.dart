import 'package:flutter_test/flutter_test.dart';
import 'package:nexgen_launcher/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
  });
}
