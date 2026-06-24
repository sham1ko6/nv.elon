// This is a basic Flutter widget test.
import 'package:flutter_test/flutter_test.dart';
import 'package:nv_elon/main.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NvElonApp());

    // Verify that the splash screen logo or title is present.
    expect(find.text('nv.elon'), findsOneWidget);
  });
}
