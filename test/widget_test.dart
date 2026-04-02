import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ma_logic/models/memory_entry.dart';
import 'package:ma_logic/models/hlc_score.dart';
import 'package:ma_logic/providers/hlc_provider.dart';

void main() {
  group('MemoryEntry', () {
    test('JSON round-trip preserves all fields', () {
      final entry = MemoryEntry(
        id: 'test-1',
        date: DateTime(2026, 4, 2, 10, 30),
        stamp: MemoryStamp.challenge,
        text: 'テスト投稿',
      );
      final json = entry.toJson();
      final restored = MemoryEntry.fromJson(json);

      expect(restored.id, 'test-1');
      expect(restored.stamp, MemoryStamp.challenge);
      expect(restored.text, 'テスト投稿');
      expect(restored.isChallenge, true);
    });

    test('isChallenge flag', () {
      final normal = MemoryEntry(id: '1', date: DateTime.now(), stamp: MemoryStamp.ate, text: 'food');
      final challenge = MemoryEntry(id: '2', date: DateTime.now(), stamp: MemoryStamp.challenge, text: 'brave');
      expect(normal.isChallenge, false);
      expect(challenge.isChallenge, true);
    });

    test('all stamps have emoji and label', () {
      for (final stamp in MemoryStamp.values) {
        expect(stamp.emoji.isNotEmpty, true);
        expect(stamp.label.isNotEmpty, true);
      }
    });
  });

  group('HlcScore', () {
    test('initial values are zero', () {
      const score = HlcScore();
      expect(score.postCount, 0);
      expect(score.likeCount, 0);
      expect(score.hospitality, 0);
      expect(score.logic, 0);
      expect(score.creativity, 0);
    });

    test('addPost increments post count and logic', () {
      final score = const HlcScore().addPost().addPost().addPost();
      expect(score.postCount, 3);
      expect(score.logic, 3);
    });

    test('addLike increments hospitality by 3x', () {
      final score = const HlcScore().addLike().addLike();
      expect(score.likeCount, 2);
      expect(score.hospitality, 6);
    });

    test('creativity equals posts + likes', () {
      final score = const HlcScore().addPost().addPost().addLike();
      expect(score.creativity, 3);
    });
  });

  group('HlcScoreNotifier', () {
    test('onPost updates provider state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(hlcScoreProvider).postCount, 0);
      container.read(hlcScoreProvider.notifier).onPost();
      expect(container.read(hlcScoreProvider).postCount, 1);
    });

    test('onLike updates provider state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(hlcScoreProvider.notifier).onLike();
      container.read(hlcScoreProvider.notifier).onLike();
      expect(container.read(hlcScoreProvider).likeCount, 2);
      expect(container.read(hlcScoreProvider).hospitality, 6);
    });
  });

  group('MemoryEntry with photo', () {
    test('photoPath is preserved in JSON', () {
      final entry = MemoryEntry(
        id: 'photo-1',
        date: DateTime(2026, 4, 2),
        stamp: MemoryStamp.went,
        text: 'おさんぽ',
        photoPath: '/tmp/manga_123.png',
      );
      final json = entry.toJson();
      final restored = MemoryEntry.fromJson(json);
      expect(restored.photoPath, '/tmp/manga_123.png');
    });

    test('photoPath can be null', () {
      final entry = MemoryEntry(id: 'no-photo', date: DateTime.now(), stamp: MemoryStamp.ate, text: 'food');
      expect(entry.photoPath, null);
      final json = entry.toJson();
      final restored = MemoryEntry.fromJson(json);
      expect(restored.photoPath, null);
    });
  });
}
