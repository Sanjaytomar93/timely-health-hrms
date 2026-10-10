import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timelay_health/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:timelay_health/features/dashboard/presentation/screens/employee_home_shell.dart';

void main() {
  testWidgets('Employee dashboard renders Figma sections', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: EmployeeHomeShell()),
    );
    await tester.pump();

    expect(find.text('Timely Health'), findsOneWidget);
    expect(find.text('Employee Portal'), findsOneWidget);
    expect(find.text('Manager Kumar'), findsOneWidget);
    expect(find.text("TODAY'S ATTENDANCE"), findsWidgets);
    expect(find.text('Quick Actions'), findsOneWidget);
  });

  testWidgets('Attendance screen renders Records tab', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: AttendanceScreen()),
    );
    await tester.pump();

    expect(find.text('My Attendance'), findsOneWidget);
    expect(find.textContaining('Records'), findsOneWidget);
    expect(find.text("TODAY'S ATTENDANCE"), findsOneWidget);
    expect(find.textContaining('OT Calculation'), findsOneWidget);
    expect(find.text('▽ Filters & Actions'), findsOneWidget);
  });
}
