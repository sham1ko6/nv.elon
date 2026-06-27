// Basic smoke test – creates a minimal AppState so it doesn't need
// SharedPreferences or the network.
import 'package:flutter_test/flutter_test.dart';
import 'package:nv_elon/main.dart';
import 'package:nv_elon/app_state.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    final appState = AppState();
    await tester.pumpWidget(NvElonApp(appState: appState));
    // The splash screen is shown; material app title propagates.
    expect(find.text('nv.elon'), findsWidgets);
  });
}
