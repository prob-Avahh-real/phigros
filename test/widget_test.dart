import 'package:flutter_test/flutter_test.dart';
import 'package:phigros/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const PhigrosApp());
    expect(find.text('PHIGROS'), findsOneWidget);
  });
}
