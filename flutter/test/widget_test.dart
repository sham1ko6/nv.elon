// Basic smoke test – boots the app and confirms the splash screen renders.
import 'package:flutter_test/flutter_test.dart';
import 'package:ravoq/main.dart';
import 'package:ravoq/app_state.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    final state = AppState();
    await tester.pumpWidget(AppStateScope(notifier: state, child: const RavoqApp()));
    expect(find.text('Ravoq'), findsWidgets);
  });
}
