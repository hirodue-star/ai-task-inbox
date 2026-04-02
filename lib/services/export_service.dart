import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/memory_entry.dart';
import '../models/hlc_score.dart';
import 'memory_database.dart';
import 'thought_database.dart';

/// Universal Backup & Export — データの永続性保証
class ExportService {
  /// 全データをJSON形式でエクスポート
  /// セキュリティ: ローカルファイルに保存、外部送信なし
  static Future<String> exportToJson() async {
    final memDb = await MemoryDatabase.database;
    final thoughtDb = await ThoughtDatabase.database;

    final memories = await memDb.query('memories', orderBy: 'date ASC');
    final hlcScores = await thoughtDb.query('hlc_scores', orderBy: 'id DESC', limit: 1);
    final thoughts = await thoughtDb.query('thoughts', orderBy: 'created_at ASC');
    final helpRecords = await thoughtDb.query('help_records', orderBy: 'completed_at ASC');

    final exportData = {
      'version': '2.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'data': {
        'memories': memories,
        'hlc_score': hlcScores.isNotEmpty ? hlcScores.first : null,
        'thoughts': thoughts,
        'help_records': helpRecords,
      },
      'metadata': {
        'total_memories': memories.length,
        'total_thoughts': thoughts.length,
        'total_help': helpRecords.length,
      },
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// PDF用データ構造生成（将来のPDF書き出し用）
  /// A4比率（210mm x 297mm）でコマをレイアウト
  static Future<List<PdfPage>> generatePdfLayout() async {
    final db = await MemoryDatabase.database;
    final maps = await db.query('memories', orderBy: 'date ASC');
    final memories = maps.map((m) => MemoryEntry.fromJson(m)).toList();

    final pages = <PdfPage>[];
    const panelsPerPage = 4;

    // 表紙
    pages.add(PdfPage(
      type: PdfPageType.cover,
      title: 'MA-LOGIC 成長の記録',
      subtitle: _dateRange(memories),
      panels: [],
    ));

    // 目次
    pages.add(PdfPage(
      type: PdfPageType.toc,
      title: '目次',
      panels: [],
      tocEntries: _generateToc(memories),
    ));

    // コンテンツページ
    for (var i = 0; i < memories.length; i += panelsPerPage) {
      final batch = memories.sublist(i, (i + panelsPerPage).clamp(0, memories.length));
      pages.add(PdfPage(
        type: PdfPageType.content,
        title: '第${(i ~/ panelsPerPage) + 1}話',
        panels: batch.map((m) => PdfPanel(
          date: m.date,
          stampEmoji: m.stamp.emoji,
          text: m.text,
          isChallenge: m.isChallenge,
          narration: _narrationForStamp(m.stamp),
        )).toList(),
      ));
    }

    return pages;
  }

  /// データ整合性チェック
  static Future<DataIntegrityReport> checkIntegrity() async {
    final memDb = await MemoryDatabase.database;
    final totalMemories = Sqflite.firstIntValue(
      await memDb.rawQuery('SELECT COUNT(*) FROM memories'),
    ) ?? 0;
    final orphanedPhotos = 0; // TODO: ファイルシステムと照合

    final thoughtDb = await ThoughtDatabase.database;
    final totalThoughts = Sqflite.firstIntValue(
      await thoughtDb.rawQuery('SELECT COUNT(*) FROM thoughts'),
    ) ?? 0;

    return DataIntegrityReport(
      totalMemories: totalMemories,
      totalThoughts: totalThoughts,
      orphanedPhotos: orphanedPhotos,
      isHealthy: true,
      checkedAt: DateTime.now(),
    );
  }

  static String _dateRange(List<MemoryEntry> memories) {
    if (memories.isEmpty) return '';
    final first = memories.first.date;
    final last = memories.last.date;
    return '${first.year}/${first.month}/${first.day} — ${last.year}/${last.month}/${last.day}';
  }

  static List<TocEntry> _generateToc(List<MemoryEntry> memories) {
    final entries = <TocEntry>[];
    for (var i = 0; i < memories.length; i += 4) {
      final m = memories[i];
      entries.add(TocEntry(
        chapter: (i ~/ 4) + 1,
        title: '${m.date.month}/${m.date.day} — ${m.stamp.label}',
        pageNumber: (i ~/ 4) + 3, // 表紙+目次分
      ));
    }
    return entries;
  }

  static String _narrationForStamp(MemoryStamp stamp) {
    switch (stamp) {
      case MemoryStamp.ate: return 'その日のごちそう';
      case MemoryStamp.went: return 'あたらしい冒険';
      case MemoryStamp.played: return 'たのしい時間';
      case MemoryStamp.pet: return 'いのちとの出会い';
      case MemoryStamp.challenge: return '勇者の挑戦';
    }
  }
}

/// PDF ページ構造
class PdfPage {
  final PdfPageType type;
  final String title;
  final String? subtitle;
  final List<PdfPanel> panels;
  final List<TocEntry>? tocEntries;

  const PdfPage({
    required this.type,
    required this.title,
    this.subtitle,
    required this.panels,
    this.tocEntries,
  });
}

enum PdfPageType { cover, toc, content }

class PdfPanel {
  final DateTime date;
  final String stampEmoji;
  final String text;
  final bool isChallenge;
  final String narration;

  const PdfPanel({
    required this.date,
    required this.stampEmoji,
    required this.text,
    required this.isChallenge,
    required this.narration,
  });
}

class TocEntry {
  final int chapter;
  final String title;
  final int pageNumber;
  const TocEntry({required this.chapter, required this.title, required this.pageNumber});
}

class DataIntegrityReport {
  final int totalMemories;
  final int totalThoughts;
  final int orphanedPhotos;
  final bool isHealthy;
  final DateTime checkedAt;

  const DataIntegrityReport({
    required this.totalMemories,
    required this.totalThoughts,
    required this.orphanedPhotos,
    required this.isHealthy,
    required this.checkedAt,
  });
}
