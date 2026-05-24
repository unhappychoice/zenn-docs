---
title: "splashboard を拡張する"
free: true
---

![basic_read_store を 3 つの widget (habit gauge / signups sparkline / reading heatmap) で組んだ自作 dashboard の例。 fetcher を自作した場合も同じレイアウト位置に同じ shape で並べられる](/images/splashboard-guide/demo-extending.png)

最後の章は、同梱のままでは足りないと思った人向けです。 splashboard を拡張する経路は 3 つあります。

1. **`basic_read_store`** で自作データを読ませる ( コード不要 )
2. **自分で fetcher を書く** ( Rust 、本体に PR )
3. **自分で renderer を書く** ( Rust 、本体に PR )

サブプロセス plugin や `command = "..."` 形式の動的拡張は意図的に存在しません ( Part 3 の trust 章で触れたとおり ) 。拡張するなら本体に組み込む、というのが splashboard のスタンスです。

## 1. read-store

ch 10 で詳しく扱ったので簡潔に。同梱にないデータを映したいと思ったら、まず `basic_read_store` で済まないか考えるのが最短ルートです。

- ファイルに JSON / TOML / text を書く
- `basic_read_store` widget をそれに向ける
- 任意のスクリプト / cron / hook でファイルを更新する

これで対応できないケースは、

- realtime に計算したい ( 起動するたびに最新値が要る )
- shape が `Timeline` / `Badge` ( read-store が対応していない 2 つ )
- 配布したい ( 他のユーザーにも同じものを使ってもらいたい )

くらいに絞られます。そこに当たったときが、 fetcher を書く時期です。

## 2. 自分で fetcher を書く

`Fetcher` trait は思ったほど大きくありません。最低限の実装は数行です。

```rust
#[async_trait]
pub trait Fetcher: Send + Sync {
    fn name(&self) -> &str;                          // 識別子 ( "weather" など )
    fn safety(&self) -> Safety;                      // Safe / Network
    fn description(&self) -> &'static str;           // matrix に出る説明
    fn refresh_interval(&self) -> u64;               // キャッシュ TTL (秒)
    fn shapes(&self) -> &[Shape];                    // 出せる shape の一覧
    fn default_shape(&self) -> Shape { ... }         // shape 未指定時の既定
    async fn fetch(&self, ctx: &FetchContext) -> FetchResult<Body>;  // 本体
}
```

書く手順は

1. `src/fetcher/<category>/<name>.rs` に struct と impl を作る
2. `src/fetcher/mod.rs` の `Registry::register_builtins` に追加
3. `tests/` でユニットテストを書く ( `sample_body()` でゴールデンを返すパターンが多い )
4. cookbook / docs に使い方を追記
5. PR を出す

`Safety` の自己宣言が一番重要です。設定が通信先を制御できるかどうかで `Safe` / `Network` を選びます。決め方は ch 13 のとおり。

実装の参考にしやすいのは、

- 静的データの実装例: [`src/fetcher/system/info_host.rs`](https://github.com/unhappychoice/splashboard/blob/main/src/fetcher/system/info_host.rs)
- 認証付き API の実装例: [`src/fetcher/github/my_prs.rs`](https://github.com/unhappychoice/splashboard/blob/main/src/fetcher/github/my_prs.rs)
- 複数 shape を出す実装例: [`src/fetcher/weather/now.rs`](https://github.com/unhappychoice/splashboard/blob/main/src/fetcher/weather/now.rs)

の 3 つです。 weather は 1 つの fetcher が 5 種類の shape を切り替える例で、応用範囲が広い参考になります。

## 3. 自分で renderer を書く

`Renderer` trait はもう少し ratatui に寄った形をしています。

```rust
pub trait Renderer: Send + Sync {
    fn name(&self) -> &str;
    fn description(&self) -> &'static str;
    fn accepts(&self) -> &[Shape];                   // 受け付ける shape
    fn animates(&self) -> bool { false }             // アニメーションかどうか
    fn render(
        &self,
        frame: &mut Frame,
        area: Rect,
        body: &Body,
        opts: &RenderOptions,
        theme: &Theme,
        registry: &Registry,
    );
}
```

書く手順は fetcher と並行で、

1. `src/render/<name>.rs` に struct と impl を作る
2. `src/render/mod.rs` の `Registry::register_builtins` に追加
3. ratatui の widget ( `Paragraph` / `Block` / `Gauge` / `BarChart` / `Sparkline` / `Canvas` など ) を使って描画する
4. テスト ( `TestBackend` でスナップショットが標準 )
5. PR

`animates() = true` を返すと、 splashboard が時間ベースで再描画ループを回してくれます ( `animated_*` シリーズはこのフラグで動いています ) 。

参考にしやすいのは、

- 静止系の最小例: [`src/render/status_badge.rs`](https://github.com/unhappychoice/splashboard/blob/main/src/render/status_badge.rs)
- chart 系の例: [`src/render/chart_sparkline.rs`](https://github.com/unhappychoice/splashboard/blob/main/src/render/chart_sparkline.rs)
- wrapper 型の例: [`src/render/animated_splitflap.rs`](https://github.com/unhappychoice/splashboard/blob/main/src/render/animated_splitflap.rs) ( inner renderer を持つアニメ )

## Shape × Fetcher × Renderer

ここまで本書を通して何度か出てきましたが、 splashboard の拡張モデルは結局この 3 軸の直積で動いています。

- Shape は 15 種類
- Fetcher は 100+ ( + 自作 )
- Renderer は 30+ ( + 自作 )

新しい組み合わせを足すたびに、 3 軸のどれを伸ばしているかを意識しておくと、設計上の落とし所が見えやすくなります。

- 新しいデータソースを足したい → fetcher を書く ( renderer は既存を流用 )
- 新しい見た目が欲しい → renderer を書く ( fetcher は既存を流用 )
- 既存の枠に収まらないデータ構造が要る → shape を書く ( 重い、慎重に )

shape を増やすのは全 renderer / 全 fetcher を見直すことに繋がるので、最後の手段です。多くの欲求は既存 shape のどれかに落とせます。

## おわりに

ここまでで splashboard の入口から出口までを一周しました。本書を順に読んだ人は、

- 動かして preset / theme を選び ( Part 1 )
- 自分の `dashboard.toml` を組み ( Part 2 )
- 中で何が起きているかを掴み ( Part 3 )
- 同梱の枠を超えて広げる方法もわかる ( この章 )

状態になっているはずです。

splashboard 自体はまだ動いている OSS なので、ここに書いてある内容は時間とともに少しずつ古くなります。 fetcher / renderer は増えますし、 trust モデルや cache の挙動も改善される可能性があります。最新の情報は以下を見てください。

splashboard 本体:

https://github.com/unhappychoice/splashboard

公式 docs:

https://splashboard.unhappychoice.com/

ターミナルを開いたときに眺めるものが、 1 行のプロンプトから 1 画面の dashboard になる。それだけのことですが、毎日見るものなので体感の差が出ます。組んだ splash を共有したい人は、 docs サイトの showcase に追加する PR も受け付けています。
