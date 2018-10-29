import 'package:beatz/main.dart';
import 'package:beatz/pages/albums_page.dart';
import 'package:beatz/pages/playlist_page.dart';
import 'package:beatz/pages/songs_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home page test', (WidgetTester tester) async {
    await tester.pumpWidget(new MyApp());

    // Verify that appropriate widgets are visible
    expect(find.byType(BottomNavigationBar), findsOneWidget);
//    expect(find.byType(BottomNavigationBarItem), findsNWidgets(3));
    expect(
        find.descendant(
            of: find.byType(CircleAvatar), matching: find.byType(Image)),
        findsOneWidget);
    expect(find.byType(AlbumsPage), findsOneWidget);
    expect(find.byType(SongsPage), findsNothing);
    expect(find.byType(PlaylistPage), findsNothing);

    // Tap the songs icon and verify that appropriate widgets are visible
    await tester.tap(find.byIcon(Icons.queue_music));
    await tester.pump();
    expect(find.byType(BottomNavigationBar), findsOneWidget);
//    expect(find.byType(BottomNavigationBarItem), findsNWidgets(3));
    expect(find.byType(AlbumsPage), findsNothing);
    expect(find.byType(SongsPage), findsOneWidget);
    expect(find.byType(PlaylistPage), findsNothing);

    // Tap the playlist icon and verify that appropriate widgets are visible
    await tester.tap(find.byIcon(Icons.playlist_play));
    await tester.pump();
    expect(find.byType(BottomNavigationBar), findsOneWidget);
//    expect(find.byType(BottomNavigationBarItem), findsNWidgets(3));
    expect(find.byType(AlbumsPage), findsNothing);
    expect(find.byType(SongsPage), findsNothing);
    expect(find.byType(PlaylistPage), findsOneWidget);

  });
}
