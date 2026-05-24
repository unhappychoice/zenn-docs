---
title: "dashboard.toml の組み立て方"
free: true
---

ここから Part 2 です。前章までで動く状態と何を映せるかのイメージは掴めたので、自分で `dashboard.toml` を書く側に回ります。

splashboard の設定は小さな TOML を組み合わせる形になっていて、覚えることはほとんどありません。

- **widget**: 何を映すかの定義 ( GitHub のレビュー待ち PR を timeline で出す、のような単位 )
- **row**: 縦方向の帯
- **child**: その row の中に横並びに置かれるもの

この 3 つだけで全レイアウトを表現します。

## 2 ファイル構成

その前に、 splashboard の設定が 2 つのファイルに分かれていることだけ押さえます。

| ファイル | 役割 | 場所 |
| --- | --- | --- |
| `settings.toml` | テーマ、パディング、トグルなど全 dashboard 共通の好み | `$HOME/.splashboard/settings.toml` のみ |
| `dashboard.toml` | widget の配置 ( per-context ) | home / project / per-repo の 3 箇所 |

テーマは 1 度決めたら全ダッシュボードに乗ってほしいが、 widget 構成はコンテキストごとに変えたい。これを分離するための区切りです。

`settings.toml` は別の章で扱うので、この章では `dashboard.toml` の中身に集中します。

## widget の定義

最小の widget はこれです。

```toml
[[widget]]
id      = "clock"
fetcher = "clock"
render  = { type = "text_ascii", align = "center" }
```

3 つだけ意識すれば書けます。

- **`id`**: その dashboard 内で一意の名前。後で row から参照するためのキー
- **`fetcher`**: データの取り元 ( 例: `clock` 、 `github_my_prs` 、 `weather` ) 。 100 を超える種類が同梱されている
- **`render`**: そのデータをどう描くか ( 例: `text_plain` 、 `text_ascii` 、 `grid_heatmap` 、 `chart_sparkline` ) 。 30 を超える種類が同梱されている

`render` には 2 つの書き方があります。

```toml
# 短い形 ( デフォルトオプションで OK のとき )
render = "text_plain"

# 長い形 ( オプションを足したいとき )
render = { type = "text_ascii", style = "figlet", font = "banner", align = "center" }
```

よく使う追加フィールドが 2 つあります。

```toml
[[widget]]
id      = "weather"
fetcher = "weather"
render  = { type = "text_plain", align = "center" }
refresh_interval = 600  # キャッシュの TTL (秒)
[widget.options]
latitude  = 35.6762
longitude = 139.6503
```

- **`refresh_interval`**: その widget のキャッシュ TTL ( 秒 ) 。 cache の話は Part 3 で詳しく
- **`[widget.options]`**: fetcher 固有のオプション ( 場所、ユーザー名、上限件数など )

`fetcher` / `render` の組み合わせには相性 ( shape ) があります。 timeline 形式のデータを `chart_sparkline` で出そうとしても合わないので、 fetcher の出力 shape と renderer が要求する shape をマッチさせる必要があります。詳しくは Part 3 で扱いますが、迷ったら [reference matrix](https://splashboard.unhappychoice.com/reference/matrix/) に組み合わせ表があります。

## row と child の配置

widget の定義が終わったら、それを画面のどこに置くかを `[[row]]` で並べます。

```toml
[[row]]
height = { length = 4 }
  [[row.child]]
  widget = "clock"
```

row は上から下に縦積みで、 row の中の `[[row.child]]` は左から右に横並びです。これだけです。

例: 上段に時計、下段に天気とニュースを横並びにする。

```toml
[[row]]
height = { length = 5 }
  [[row.child]]
  widget = "clock"

[[row]]
height = { length = 8 }
  [[row.child]]
  widget = "weather"
  width = { length = 30 }
  [[row.child]]
  widget = "news"
  width = { fill = 1 }
```

`height` / `width` には同じ 5 つの書き方が使えます。

| 書き方 | 意味 |
| --- | --- |
| `{ length = N }` | 固定で N セル |
| `{ fill = N }` | 兄弟の `fill` 値に応じて余白を比例配分 |
| `{ min = N }` | 最低 N セル、余裕があれば伸びる |
| `{ max = N }` | 最大 N セル、内容が少なければ縮む |
| `{ percentage = N }` | 親軸の N % |

上の例だと、 weather は固定 30 セル、 news は残り全部、という配分です。 column 比 2 : 1 にしたいなら両方 `fill` で書きます。

```toml
[[row.child]]
widget = "weather"
width = { fill = 2 }
[[row.child]]
widget = "news"
width = { fill = 1 }
```

## 隙間と枠線

row には 2 種類の装飾オプションがあります。

```toml
[[row]]
height = { length = 10 }
bg     = "subtle"      # "default" / "subtle" (theme.bg_subtle で塗る)
flex   = "center"      # 子が row 幅を埋めない場合の配置 ("center" / 既定の左寄せ)
gap    = 2             # 兄弟 child の間に N セル空ける
title  = "system"      # row レベルのタイトル
border = "top"         # "none" / "plain" / "rounded" / "thick" / "double" / "top"
```

`gap` は兄弟の間に毎回 N セル空けるショートカットです。明示的にスペーサーを置きたい場合は、 widget を持たない child を挟みます。

```toml
[[row.child]]
widget = "left"
[[row.child]]
width = { length = 4 }  # widget を書かないとレイアウト用のスペーサーになる
[[row.child]]
widget = "right"
```

`border = "top"` と `title = "..."` を組み合わせると、上に横線とタイトルだけが乗るセクション区切りになります。 panel で囲わずに緩く区切るのに便利です。

`flex = "center"` はサブタイトルみたいに細い child を row の中央に置きたいときに使います。

## 通しで組み立てる

最後に、ここまでの要素だけで組んだ project splash の例を 1 つ置きます。

![下の TOML をそのまま描画した結果。 figlet ロゴ + git_status のサブタイトル + commits / recent の 2 列 panel](/images/splashboard-guide/demo-project-toml.png)

```toml
# ./.splashboard/dashboard.toml

[[widget]]
id      = "hero"
fetcher = "git_repo_name"
render  = { type = "text_ascii", style = "figlet", font = "banner", align = "center", color = "panel_title" }

[[widget]]
id      = "subtitle"
fetcher = "git_status"
render  = { type = "text_plain", align = "center" }

[[widget]]
id      = "commits"
fetcher = "git_commits_activity"
render  = "grid_heatmap"

[[widget]]
id      = "recent"
fetcher = "git_recent_commits"
render  = { type = "list_timeline", bullet = "●", max_items = 3 }

[[row]]                       # 1 段目: figlet ヒーロー
height = { length = 8 }
bg = "subtle"
  [[row.child]]
  widget = "hero"

[[row]]                       # 2 段目: サブタイトルを中央寄せ
height = { length = 3 }
bg = "subtle"
flex = "center"
  [[row.child]]
  widget = "subtitle"
  width = { length = 70 }

[[row]]                       # 3 段目: 空白行
height = { length = 1 }

[[row]]                       # 4 段目: 2 列の panel 風
height = { length = 10 }
gap = 4
  [[row.child]]
  widget = "commits"
  width = { fill = 1 }
  border = "top"
  title = "commits"
  [[row.child]]
  widget = "recent"
  width = { fill = 1 }
  border = "top"
  title = "recent"
```

これで上からロゴ、サブタイトル、空白、 2 列 panel ( commits / recent ) という構成になります。 4 つの widget と 4 つの row だけ。 splash としては十分なレイアウトです。 fetcher を git 系だけで揃えてあるので、どの git レポジトリでもそのまま描画できます。

設定スキーマの全容は公式 configuration ガイドに揃っています:

https://splashboard.unhappychoice.com/guides/configuration/

次の章からは、 `fetcher = "..."` に何を書けるかの選択肢、 fetcher 抜粋紹介に進みます。
