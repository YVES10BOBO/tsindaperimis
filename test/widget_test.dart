import 'package:flutter_test/flutter_test.dart';

import 'package:amategeko_app/app.dart';

void main() {
  testWidgets('Welcome screen igaragara', (WidgetTester tester) async {
    await tester.pumpWidget(const AmategekoApp());
    expect(find.text("Amategeko y'Umuhanda"), findsOneWidget);
    expect(find.text('Injira'), findsOneWidget);
  });
}
