import 'package:flutter_test/flutter_test.dart';
import 'package:cpr_coach/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const CprCoachApp());
    expect(find.text('CPR COACH'), findsOneWidget);
  });
}
