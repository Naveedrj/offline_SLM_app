import 'package:flutter_test/flutter_test.dart';
import 'package:test_offline_app/main.dart';

void main() {
  testWidgets('TestOfflineSLMApp renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const TestOfflineSLMApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Offline SLM Tester'), findsOneWidget);
  });
}
