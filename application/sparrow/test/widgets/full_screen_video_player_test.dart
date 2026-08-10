import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparrow/widgets/full_screen_video_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FullScreenVideoPlayer Widget Tests', () {
    Widget buildTestApp(Widget child) {
      return MaterialApp(
        home: child,
      );
    }

    testWidgets('FullScreenVideoPlayer renders title, subtitle, and close button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const FullScreenVideoPlayer(
            videoPath: 'assets/sample_video.mp4',
            title: 'Test Bodycam Recording',
            subtitle: 'Officer Davis',
            caption: 'Recorded at 14:30',
            autoPlay: false,
          ),
        ),
      );

      expect(find.text('Test Bodycam Recording'), findsOneWidget);
      expect(find.text('Officer Davis'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    });

    testWidgets('FullScreenVideoPlayer.open opens full-screen modal route',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  FullScreenVideoPlayer.open(
                    context,
                    videoPath: 'assets/sample_video.mp4',
                    title: 'Modal Video Test',
                    autoPlay: false,
                  );
                },
                child: const Text('Play Video'),
              );
            },
          ),
        ),
      );

      expect(find.text('Play Video'), findsOneWidget);

      await tester.tap(find.text('Play Video'));
      await tester.pumpAndSettle();

      expect(find.text('Modal Video Test'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Modal Video Test'), findsNothing);
      expect(find.text('Play Video'), findsOneWidget);
    });
  });
}
