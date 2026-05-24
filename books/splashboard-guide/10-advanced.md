---
title: "ちょっと凝る"
free: true
---

ここまで読めば、たいていの splash は組めるようになっています。 Part 2 の締めとして、公式 preset ではあまり扱われないパターンを 3 つ紹介します。

- `basic_read_store` で自作データを映す
- ターミナルサイズが大きい前提のレイアウト
- 季節 / 期間限定の splash

書ける幅を一段引き上げると、自分が毎日見るものに合わせ込みやすくなります。

## 自作データを映す ( read-store )

splashboard が用意していないデータでも、 `basic_read_store` を使えばコードを書かずに widget にできます。仕組みはシンプルです。

1. dashboard に `basic_read_store` widget を置く
2. その widget の `id` と同じ名前のファイルを `$HOME/.splashboard/store/<id>.<ext>` に置く
3. cron / シェル関数 / post-commit hook などで、そのファイルの中身を更新

これだけです。 splashboard はそのファイルを読み、 renderer が要求する shape に直接デシリアライズします。 envelope ( shape タグや wrapper ) は不要で、必要なデータ構造そのものを書きます。

### 例: 習慣トラッカー ( Ratio )

![basic_read_store × gauge_line: 3 つの習慣をそれぞれの JSON から読んでゲージ表示](/images/splashboard-guide/demo-c10-habit.png)

過去 10 日のうち何日継続できたかを、習慣ごとにゲージで出す例。 widget を 3 つ並べ、それぞれが別の JSON を読みます。

```toml
[[widget]]
id          = "exercise"
fetcher     = "basic_read_store"
file_format = "json"
render      = { type = "gauge_line", label_position = "center" }

[[widget]]
id          = "reading"
fetcher     = "basic_read_store"
file_format = "json"
render      = { type = "gauge_line", label_position = "center" }

[[widget]]
id          = "japanese"
fetcher     = "basic_read_store"
file_format = "json"
render      = { type = "gauge_line", label_position = "center" }
```

```json
// $HOME/.splashboard/store/exercise.json
{ "value": 0.8, "label": "exercise · 8 / 10 日" }
```

`basic_read_store` は widget の `id` から読むファイルを決めます ( `store/<id>.json` ) 。 3 つの widget には 3 つの JSON が対応します。あとは毎晩 cron で各ファイルを書き換えるスクリプトを置いておくだけで、シェルを開くたびに習慣ごとの達成率が見えます。

### 例: 読書ログ ( Heatmap )

![basic_heatmap × grid_heatmap: 4 週 × 7 曜日の読書ログ ( 曜日ラベル付き )](/images/splashboard-guide/demo-reading-heatmap.png)

読書時間の heatmap を `git_commits_activity` の流儀で出す例。 1 ヶ月 × 7 曜日のグリッドにします。

```toml
[[widget]]
id          = "reading"
fetcher     = "basic_read_store"
file_format = "json"
render      = "grid_heatmap"
```

```json
// $HOME/.splashboard/store/reading.json
{
  "cells": [
    [0, 1, 0, 2, 3, 0, 0],
    [1, 1, 2, 0, 0, 4, 2],
    [0, 0, 1, 3, 2, 0, 1],
    [2, 1, 0, 0, 2, 3, 1]
  ],
  "col_labels": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
}
```

任意のスクリプト ( Python でも shell でも ) で読書ログの DB / ファイルを集計し、 1 行で `> ~/.splashboard/store/reading.json` に書き出すだけです。

### 例: KPI のミニ chart ( NumberSeries )

![basic_read_store × chart_sparkline: `store/signups.json` の日次サインアップ数を棒グラフで描画](/images/splashboard-guide/demo-c10-kpi.png)

最近 30 日のフォロワー数推移、自プロダクトの日次サインアップ数を `chart_sparkline` で出します。

```toml
[[widget]]
id          = "signups"
fetcher     = "basic_read_store"
file_format = "json"
render      = { type = "chart_sparkline", style = "bars" }
```

```json
// $HOME/.splashboard/store/signups.json
{ "values": [3, 5, 4, 7, 6, 8, 9, 12, 10, 11, 13, 15, 14, 18] }
```

毎朝 BigQuery / DB / Analytics API から数字を 1 ファイルに書き出す cron を回しておけば、シェルを開くたびに自分の数字が映ります。

read-store は 11 shape に対応しています ( Text / TextBlock / Entries / Ratio / NumberSeries / PointSeries / Bars / Heatmap / Calendar / Image / ImageLinkedList ) 。 Timeline と Badge は、今この瞬間のデータなので対象外です。そこは built-in の fetcher を使う使い分けになります。

read-store の詳細仕様は公式 docs にあります:

https://splashboard.unhappychoice.com/guides/read-store/

## ターミナルが大きい前提のレイアウト

![home_daily を 2000 × 1100 のワイドキャンバスで描画した状態。狭い preset で `+4 rows (terminal too short)` と切られていた time elapsed の年/四半期/月/週/日 5 行が全部出る](/images/splashboard-guide/demo-wide-monitor.png)

`splashboard install` の preset は、 80 × 24 でも 200 × 60 でも崩れないように作られています。自分の dashboard なら、自分のターミナルサイズに合わせて贅沢に組んでも構いません。

横が 200 セル以上ある dashboard はこんな構成が組めます。

```toml
[[row]]                          # 1 段目: 巨大時計を中央、両脇に天気と月相
height = { length = 10 }
flex = "center"
gap  = 4
  [[row.child]]
  widget = "weather"
  width  = { length = 30 }
  border = "rounded"
  title  = "weather"

  [[row.child]]
  widget = "clock"
  width  = { length = 80 }       # 図体の大きい figlet を真ん中に

  [[row.child]]
  widget = "moon"
  width  = { length = 30 }
  border = "rounded"
  title  = "moon"

[[row]]                          # 2 段目: 横長の commit heatmap (52 週分が並ぶ)
height = { length = 8 }
  [[row.child]]
  widget = "kusa"

[[row]]                          # 3 段目: 3 列の panel
height = { length = 12 }
gap = 2
  [[row.child]]
  widget = "my_prs"
  width  = { fill = 1 }
  border = "top"
  title  = "open prs"

  [[row.child]]
  widget = "releases"
  width  = { fill = 1 }
  border = "top"
  title  = "releases"

  [[row.child]]
  widget = "feed"
  width  = { fill = 1 }
  border = "top"
  title  = "feed"
```

`fill` で 3 列等分すると、ターミナルサイズが変わっても比率が保たれます。大画面では `length` を多めに固定する方が、各 widget が常に同じ見え方になって落ち着きます。

逆に小さい画面でも崩れないように組みたい場合は、 `[[row]]` の `min` / `max` で「狭いときに縮む widget」と「最低限の高さを確保する widget」を 1 行ずつ決めておくと、ターミナルサイズが変わっても破綻しにくくなります。

## 季節 / 期間限定の splash

![clock_countdown × text_ascii (blocks): リリース日までの残り日数を巨大表示](/images/splashboard-guide/demo-c10-countdown.png)

`clock_countdown` を使うと、特定の日付までの残り時間を出せます。 v2.0 リリースまでのカウントダウンを出す例。

```toml
[[widget]]
id      = "ship"
fetcher = "clock_countdown"
render  = { type = "text_ascii", style = "blocks", align = "center" }
[widget.options]
target       = "2026-07-01T00:00:00+09:00"
target_label = "to v2.0 release"
```

このパターンは応用が広いです:

- 自プロダクトのリリース日カウントダウン ( `target = "2026-06-30T..."` )
- 誕生日 / 記念日
- 勉強会 / カンファレンス
- 受験 / 試験
- フリーランス契約期間の残り

期間中だけ表示する、祝日だけ別 splash 、のような条件分岐は splashboard 自体にはないので、 cron で `home.dashboard.toml` をスワップするとか、 `splashboard --config=...` で別ファイルを指定するなど、外側の仕掛けで実現します。年末年始だけ `home-newyear.dashboard.toml` を home に上書きコピーする cron 、くらいの単純さで十分です。

## Part 2 のまとめ

ここまでで、

- `dashboard.toml` の組み立て方 ( ch 6 )
- 何を取れるか ( fetcher 抜粋、 ch 7 )
- どう描けるか ( renderer 抜粋、 ch 8 )
- どう組み合わせるか ( ch 9 )
- 凝った使い方 ( この章 )

を一通り扱いました。自分の dashboard を組める状態に届いたはずです。

次の Part 3 では、 splashboard の中で何が起きているかを掘ります。シェル起動を遅くしないための cache + daemon 、 fetcher → renderer のデータパイプライン、 per-repo 設定を安全に扱うための trust モデル。設定で迷ったときの理由を理解できる章群です。
