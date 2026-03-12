import 'package:flutter_test/flutter_test.dart';
import 'package:hostel_management_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('shell app renders the clean admin setup flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Set Up Admin Workspace'), findsOneWidget);
    expect(find.text('Create Admin'), findsOneWidget);
  });
}
