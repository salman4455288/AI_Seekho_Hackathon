import 'package:flutter_test/flutter_test.dart';
import 'package:insightflow/main.dart';

void main() {
  testWidgets('InsightFlow smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const InsightFlowApp());
    expect(find.text('InsightFlow'), findsOneWidget);
  });
}
