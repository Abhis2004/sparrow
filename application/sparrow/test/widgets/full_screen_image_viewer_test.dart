import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparrow/widgets/full_screen_image_viewer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageViewerItem Model Tests', () {
    test('ImageViewerItem.fromPath initializes properties correctly', () {
      final item = ImageViewerItem.fromPath(
        '/tmp/test_image.png',
        title: 'Evidence #101',
        subtitle: 'Officer Smith',
        caption: 'Front entrance photo',
        heroTag: 'hero_101',
      );

      expect(item.imagePath, '/tmp/test_image.png');
      expect(item.title, 'Evidence #101');
      expect(item.subtitle, 'Officer Smith');
      expect(item.caption, 'Front entrance photo');
      expect(item.heroTag, 'hero_101');
      expect(item.isNetwork, isFalse);
      expect(item.isAsset, isFalse);
    });

    test('ImageViewerItem.fromUrl detects network image', () {
      final item = ImageViewerItem.fromUrl('https://example.com/photo.jpg');

      expect(item.imagePath, 'https://example.com/photo.jpg');
      expect(item.isNetwork, isTrue);
      expect(item.isAsset, isFalse);
      expect(item.resolveImageProvider(), isA<NetworkImage>());
    });

    test('ImageViewerItem.fromAsset detects asset image', () {
      final item = ImageViewerItem.fromAsset('assets/logo/logo.png');

      expect(item.imagePath, 'assets/logo/logo.png');
      expect(item.isAsset, isTrue);
      expect(item.resolveImageProvider(), isA<AssetImage>());
    });

    test('ImageViewerItem.fromBytes initializes memory image provider', () {
      final dummyBytes = Uint8List.fromList([0, 1, 2, 3]);
      final item = ImageViewerItem.fromBytes(dummyBytes);

      expect(item.bytes, dummyBytes);
      expect(item.resolveImageProvider(), isA<MemoryImage>());
    });
  });

  group('FullScreenImageViewer Widget Tests', () {
    Widget buildTestApp(Widget child) {
      return MaterialApp(
        home: child,
      );
    }

    testWidgets('Renders single item with title, subtitle, and close button',
        (WidgetTester tester) async {
      final item = ImageViewerItem.fromAsset(
        'assets/logo/logo.png',
        title: 'Logo Preview',
        subtitle: 'App Branding',
        caption: 'Official application logo',
      );

      await tester.pumpWidget(
        buildTestApp(
          FullScreenImageViewer(
            items: [item],
            showThumbnails: false,
          ),
        ),
      );

      expect(find.text('Logo Preview'), findsOneWidget);
      expect(find.text('App Branding'), findsOneWidget);
      expect(find.text('Official application logo'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.rotate_right_rounded), findsOneWidget);
    });

    testWidgets('Renders gallery counter badge when multiple items provided',
        (WidgetTester tester) async {
      final items = [
        ImageViewerItem.fromAsset('assets/logo/logo.png', title: 'Image 1'),
        ImageViewerItem.fromAsset('assets/logo/logo.png', title: 'Image 2'),
        ImageViewerItem.fromAsset('assets/logo/logo.png', title: 'Image 3'),
      ];

      await tester.pumpWidget(
        buildTestApp(
          FullScreenImageViewer(
            items: items,
            initialIndex: 0,
            showThumbnails: true,
          ),
        ),
      );

      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.text('Image 1'), findsOneWidget);

      // Swipe to second page
      await tester.drag(find.byType(PageView), const Offset(-800, 0));
      await tester.pumpAndSettle();

      expect(find.text('2 / 3'), findsOneWidget);
      expect(find.text('Image 2'), findsOneWidget);
    });

    testWidgets('Tapping image toggles overlay visibility',
        (WidgetTester tester) async {
      final item = ImageViewerItem.fromAsset(
        'assets/logo/logo.png',
        title: 'Toggle Header',
      );

      await tester.pumpWidget(
        buildTestApp(
          FullScreenImageViewer(items: [item]),
        ),
      );

      expect(find.text('Toggle Header'), findsOneWidget);

      // Tap background/image to hide overlay
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Tap again to show overlay
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(find.text('Toggle Header'), findsOneWidget);
    });

    testWidgets('Tapping rotate button updates rotation state',
        (WidgetTester tester) async {
      final item = ImageViewerItem.fromAsset('assets/logo/logo.png');

      await tester.pumpWidget(
        buildTestApp(
          FullScreenImageViewer(items: [item]),
        ),
      );

      final rotateButton = find.byIcon(Icons.rotate_right_rounded);
      expect(rotateButton, findsOneWidget);

      await tester.tap(rotateButton);
      await tester.pumpAndSettle();

      expect(find.byType(RotatedBox), findsWidgets);
    });

    testWidgets('FullScreenImageViewer.open method launches modal route',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  FullScreenImageViewer.openSingle(
                    context,
                    imagePath: 'assets/logo/logo.png',
                    title: 'Modal Single Test',
                  );
                },
                child: const Text('Open Viewer'),
              );
            },
          ),
        ),
      );

      expect(find.text('Open Viewer'), findsOneWidget);

      await tester.tap(find.text('Open Viewer'));
      await tester.pumpAndSettle();

      expect(find.text('Modal Single Test'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Modal Single Test'), findsNothing);
      expect(find.text('Open Viewer'), findsOneWidget);
    });
  });
}
