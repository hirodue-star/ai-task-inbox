# MA-LOGIC v2.0 アーキテクチャ

## コンセプト
「子供のお手伝いを通じたホスピタリティ向上と、ママ友間での拡散」

## 技術スタック
| レイヤー | 技術 | 状態 |
|---|---|---|
| UI描画 | CustomPainter / BoxDecoration（PNG不使用） | 完了 |
| 状態管理 | flutter_riverpod | 完了 |
| ローカルDB | sqflite | 完了 |
| 通知 | Firebase Cloud Messaging | スタブ実装済 |
| バックエンド | Cloud Firestore | 未接続 |

## ディレクトリ構造
```
lib/
├── main.dart                          # エントリ + グローバルオーバーレイ設定
├── theme/
│   └── ma_colors.dart                 # 全級カラーパレット + グラデーション定義
├── models/
│   ├── hlc_score.dart                 # H(奉仕)/L(論理)/C(創造)スコア + レベル判定
│   └── thought_record.dart            # 思考資産 + レベルアップ問いかけ生成
├── providers/
│   └── hlc_provider.dart              # Riverpod: HLCスコア全画面共有
├── services/
│   ├── thought_database.dart          # SQLite: 思考/スコア/お手伝い永続化
│   └── fcm_service.dart               # FCM: 親端末承認（スタブ対応）
├── painters/
│   ├── background_painter.dart        # 動的背景（パステルバブル/星空+金粉）
│   ├── gaogao_painter.dart            # ガオガオ4表情ベクター描画
│   ├── mandala_grid_painter.dart      # 黄金3x3グリッド + タッチ残光
│   └── particle_painter.dart          # 黄金パーティクルバースト
├── widgets/
│   ├── squishy_button.dart            # マシュマロ弾性ボタン（SpringSimulation）
│   ├── spring_button.dart             # 汎用スプリングボタン
│   ├── gacha_capsule.dart             # 黄金カプセル + シェイク演出
│   └── hyokkori_frame.dart            # 親承認オーバーレイ（全画面最優先）
└── screens/
    ├── splash_screen.dart             # スプラッシュ（弾性ロゴ → 3秒遷移）
    ├── home_screen.dart               # 級選択 + HLCスコアバー
    ├── hiyoko/
    │   ├── hiyoko_home.dart           # ぷにぷにボタン + ガオガオ表情切替
    │   └── hiyoko_otetsudai.dart      # お手伝い記録 + メダル + HLCスコア加算
    └── lion/
        ├── lion_home.dart             # 黄金マンダラ + ガチャ入口
        └── lion_gacha.dart            # ガチャフルシーケンス + パーティクル
```

## 物理演算仕様
| ウィジェット | 実装 | パラメータ |
|---|---|---|
| ぷにぷにボタン | 縦縮小(0.85)+横膨張(1.12) → Spring戻り | mass=1.0, stiffness=300, damping=8 (縦) / mass=1.2, stiffness=250, damping=9 (横) |
| マンダラ残光 | タッチ位置に金粉8粒子 → 1秒フェードアウト | life=1.0→0.0, radius=30px |
| ガチャ演出 | 上昇→振動→バースト→結果 | 3秒4段階Interval |
| ひょっこりフレーム | 弾性スライドイン + バウンス | Curves.elasticOut |

## HLCスコアシステム
| アクション | H(奉仕) | L(論理) | C(創造) |
|---|---|---|---|
| お手伝い完了 | +10 | - | - |
| 思考記録 | - | +5 | - |
| 創造的活動 | - | - | +8 |
| 親の承認 | +5 | +5 | +5 |
| ガチャ報酬 | +1~5 | +1~5 | +1~5 |

## レベル判定
| レベル | 必要ポイント | テーマ |
|---|---|---|
| ひよこ級 | 0~ | Squishy & Pastel |
| ペンギン級 | 100~ | Ice & Crystalline |
| ライオン級 | 300~ | Gold & Particles |

## 次期開発ロードマップ

### Phase 1: ペンギン級実装
- `lib/screens/penguin/` — 氷の結晶UI + クリスタリンエフェクト
- `lib/painters/ice_painter.dart` — 六角形結晶の描画
- 論理パズル系タスク（思考記録でL加算）

### Phase 2: Firebase接続
- `flutterfire configure` でFirebase初期化
- Cloud Firestore: 家族間データ同期
- FCM: リアル親子間承認フロー
- Firebase Auth: 家族アカウント管理

### Phase 3: ママ友拡散機能
- 共有カード生成（コード描画 → 画像書き出し）
- ディープリンクによる招待フロー
- 家族間ランキング

### Phase 4: 思考資産の高度利用
- マンダラ完成度の可視化
- AI問いかけ（過去の思考を文脈にした発展的質問）
- 成長レポート（親向け）
