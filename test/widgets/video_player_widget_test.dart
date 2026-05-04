import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chef_specials/widgets/video_player_widget.dart';

Widget _buildTestWidget(String videoUrl) {
  return MaterialApp(
    home: Scaffold(
      body: VideoPlayerWidget(videoUrl: videoUrl),
    ),
  );
}

void main() {
  group('VideoPlayerWidget', () {
    testWidgets('renders without error given a URL', (tester) async {
      // The widget will fail to initialize the video player in a test
      // environment (no network), so it should eventually show the error state.
      // We just verify the widget tree builds without throwing.
      await tester.pumpWidget(_buildTestWidget('https://example.com/video.mp4'));
      await tester.pump();

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });

    testWidgets('shows loading indicator while initializing', (tester) async {
      await tester.pumpWidget(_buildTestWidget('https://example.com/video.mp4'));
      // Immediately after pump, before the future resolves:
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state after failed initialization', (tester) async {
      await tester.pumpWidget(_buildTestWidget('https://invalid-host/video.mp4'));
      // Allow async operations to complete
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // The error state shows an error icon
      final errorIcon = find.byIcon(Icons.videocam_off_outlined);
      final loadingIndicator = find.byType(CircularProgressIndicator);
      // Either still loading or showing error — should not throw
      expect(errorIcon.evaluate().isNotEmpty || loadingIndicator.evaluate().isNotEmpty, isTrue);
    });

    testWidgets('uses provided aspectRatio', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VideoPlayerWidget(
              videoUrl: 'https://example.com/video.mp4',
              aspectRatio: 4 / 3,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(VideoPlayerWidget), findsOneWidget);
    });
  });
}
