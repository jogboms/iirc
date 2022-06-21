import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/app.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    await tester.pump();

    expect(find.text('IIRC'), findsOneWidget);
  });
}
