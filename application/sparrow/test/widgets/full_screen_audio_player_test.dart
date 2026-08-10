import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparrow/widgets/full_screen_audio_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FullScreenAudioPlayer Widget Tests', () {
    Widget buildTestApp(Widget child) {
      return MaterialApp(
        home: child,
      );
    }

    testWidgets('FullScreenAudioPlayer renders title, subtitle, and badge',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const FullScreenAudioPlayer(
            audioPath: 'assets/sample_audio.mp3',
            title: 'Test Audio Statement',
            subtitle: 'Witness Interview',
            caption: 'Recorded at 15:45',
            autoPlay: false,
          ),
        ),
      );

      expect(find.text('Test Audio Statement'), findsOneWidget);
      expect(find.text('Witness Interview'), findsOneWidget);
      expect(find.text('AUDIO EVIDENCE'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('FullScreenAudioPlayer.open opens full-screen modal route',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  FullScreenAudioPlayer.open(
                    context,
                    audioPath: 'assets/sample_audio.mp3',
                    title: 'Modal Audio Test',
                    autoPlay: false,
                  );
                },
                child: const Text('Play Audio'),
              );
            },
          ),
        ),
      );

      expect(find.text('Play Audio'), findsOneWidget);

      await tester.tap(find.text('Play Audio'));
      await tester.pumpAndSettle();

      expect(find.text('Modal Audio Test'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Modal Audio Test'), findsNothing);
      expect(find.text('Play Audio'), findsOneWidget);
    });
  });
}
