import 'package:flutter_test/flutter_test.dart';
import 'package:sarah_app/main.dart';

void main() {
  testWidgets('App builds and shows splash', (WidgetTester tester) async {
    await tester.pumpWidget(const SarahApp());
    expect(find.text('Sarah'), findsOneWidget);
  });
}
