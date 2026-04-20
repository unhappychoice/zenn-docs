---
title: "2026 Markdown Viewer 比較（grip / markserv / glow / mo / Arto / mdts）"
emoji: "👀"
type: "idea"
topics: [markdown, cli, viewer, ドキュメント]
published: true
---

## はじめに

最近、ローカルに `.md` ファイルがどんどん溜まっていきます。
AI に出させた設計メモ、 ADR 、 RFC 、雑な作業ログ……エディタで開くほどではないけれど、 GitHub に push してプレビューするのも少し大げさ、くらいの温度のものが多いかと思います。

こうした Markdown を **「ただ読む」** ためのツールをちゃんと見回したことがなかったので、一通り触ってみました。
対象は `grip` / `markserv` / `md-fileserver` / `glow` / `mo` / `Arto` と、拙作の `mdts` を加えた 7 つです。 CLI 、 TUI 、 GUI ネイティブアプリまで毛色の違うものが混在しています。

## 各ツール

### grip

https://github.com/joeyespo/grip

Python 製の老舗。 2012 年からあるこの記事中で最古参のプロジェクトです。ただし最終コミットは **2023-10** で、リリースも長らく止まっており、 Issue 125 件を残してほぼ塩漬けの状態になっています。

**GitHub の Markdown API を叩いて描画する** ため、見た目は GitHub 上で見るのと完全に一致します。

```bash
pip install grip
grip README.md
```

README を push 前に最終確認する用途であれば今でも十分使えるかと思います。一方で API 依存なのでオフラインでは動かず、認証なしだと GitHub のレート制限にも引っかかります。ツリー表示や検索もないため、日常的に大量の `.md` を読む用途にはあまり向かない印象です。

### markserv

https://github.com/markserv/markserv

Node 製のローカル Markdown サーバ。 2016 年からあるプロジェクトで、直近も 2026-03 にコミットがある程度にはメンテされています。 WebSocket でライブリロード、テーマも dark / light / synthwave / solarized の 4 種が同梱されています。

```bash
npm i -g markserv
markserv ./
```

MathJax や見出しアンカー、 Markdown 内に別の Markdown / HTML / LESS を埋め込める Just-in-Time Templating など、機能面は素直です。

一方で UI はやや古典的で、サイドバーツリーのようなモダンなナビはなく、昔ながらのファイル一覧形式です。シンプルで壊れにくい反面、「読む」体験としては少し素っ気なく感じるかもしれません。

### md-fileserver

https://github.com/commenthol/md-fileserver

同じく Node 製のプレビューサーバ。こちらも 2014 年からある古株で、 2025-11 リリースの 1.10.3 まで地道にメンテされています。グローバルインストールして `mdstart` で立ち上げます。

```bash
npm install -g md-fileserver
mdstart
```

GFM ・ highlight.js ・ KaTeX ・タスクリスト・絵文字のほか、 markedpp プリプロセッサや Confluence エクスポートなども備えています。位置付けとしては markserv と近い、「素直なプレビューサーバ」の別系統という印象です。

ディレクトリツリー・全文検索・ Mermaid は標準では対応しておらず、単ファイル〜少数ファイルをさっと開く用途向けかと思います。

### glow

https://github.com/charmbracelet/glow

[Charm](https://charm.sh/) 製の **ターミナル TUI** 型ビューワ。 2019 年から育てられているプロジェクトで、つい先日 (2026-04) にも v2.1.2 がリリースされているかなりアクティブなプロダクトです。 Stars は **24.5k** と、この記事中で他と一段違うスケールになっています。

`glow` コマンドを打つだけでカレント以下の `.md` が一覧表示され、矢印キーで選んで読めます。

```bash
brew install glow
glow
```

ブラウザを開かずに読めるので、 SSH 先のサーバで `.md` を読みたいときなどにも重宝します。

Mermaid や画像は描けず、ライブリロードもないため、ブラウザ系のビューワとは役割が少し違います。ターミナル派の方向けという位置付けかと思います。

### mo

https://github.com/k1LoW/mo

[k1LoW](https://github.com/k1LoW) さん製の Go 製ビューワ。常駐サーバ型です。実は **2026-02-27 に作られたばかり** で、この記事を書いている時点でまだ 2 ヶ月程度のプロジェクトですが、すでに v1.3.0 まで進んでおり機能もかなり充実しています。開発ペースの速さが印象的です。

```bash
brew install k1LoW/tap/mo
mo docs/
```

GFM / Syntax Highlight / Mermaid / LaTeX / 全文検索 / ツリー & フラットのサイドバー切り替え / MDX サポートと、ブラウザ系の中では機能が一番豊富に揃っています。 `mo` を複数回叩くとセッションにファイルが追加されていく運用が独特で、常駐して使う前提がよく考えられています。

ブラウザ型のビューワを腰を据えて使うなら、有力な候補かと思います。

### Arto

https://github.com/arto-app/Arto

macOS 専用のネイティブアプリ。 Rust 製で、 2025-10 からの比較的新しいプロジェクトです。現時点では v0.25.x のベータ段階で、 README 上 "currently designed exclusively for macOS" と明記されており、 Linux / Windows は未対応です。

```bash
brew install --cask arto-app/tap/arto
```

GitHub スタイルを忠実に再現するレンダリングが特徴で、 Vim / Emacs / Default のキーバインドプリセット、ブックマーク、ピン留めタブ、ダイアグラム・数式・画像の専用ビューなど、 GUI アプリならではの作り込みがしっかりしています。 「読むこと自体を静かな作業として扱う」という設計思想が明確で、他の CLI 系とは別カテゴリの存在として見るのがよさそうです。

ネイティブアプリのため、 CLI サーバ系のように `cd` して即ブラウザで俯瞰、というカジュアルな使い方とは少し違う立ち位置になります。

### mdts

https://github.com/unhappychoice/mdts

拙作。 2025-07 からぼちぼち育てていて、もうすぐ 1 年になります。

```bash
npx mdts
```

GFM / Syntax Highlight / Mermaid / Frontmatter / ツリー / 検索 / Outline / ライブリロードといった基本機能は mo あたりに近い水準です。特徴としては **見た目のカスタマイズ性** に寄せていて、アプリ全体のテーマ 20+ 種、 Syntax Highlight テーマ、本文・ monospace フォント、サイズ (14–24px) 、レイアウト (compact / full-width) などを設定ダイアログから調整できます。設定は `~/.config/mdts/config.json` と localStorage に永続化されます。

他のビューワはダーク/ライト + 少数テーマ止まりのものが多いので、自分好みの見た目でじっくり読みたい向きには差別化できるポイントかと思います。詳細は [別記事](https://zenn.dev/unhappychoice/articles/mdts) に書いています。

## 一覧

| ツール | 形態 | ツリー | オフライン | ライブリロード | 検索 | Mermaid | テーマ・見た目 | ⭐ |
|---|---|---|---|---|---|---|---|---|
| grip | Python CLI (ブラウザ) | △ | ❌ | ◯ | ❌ | ◯ | GitHub 固定 | 6.8k |
| markserv | Node CLI (ブラウザ) | △ | ◯ | ◯ | ❌ | △ | 4 テーマ | 598 |
| md-fileserver | Node CLI (ブラウザ) | ❌ | ◯ | ◯ | ❌ | ❌ | 最小 | 99 |
| glow | Go CLI (TUI) | ◯ | ◯ | ❌ | ◯ | ❌ | style 指定可 | 24.5k |
| mo | Go CLI (ブラウザ) | ◯ | ◯ | ◯ | ◯ | ◯ | ダーク/ライト | 786 |
| Arto | ネイティブアプリ (macOS) | ◯ | ◯ | ◯ | ◯ | ◯ | ダーク/ライト | 209 |
| **mdts** | Node CLI (ブラウザ) | ◯ | ◯ | ◯ | ◯ | ◯ | **20+ テーマ / フォント / レイアウト** | 172 |

※ 記事執筆時点（ 2026-04-21 ）の内容です。最新の状況は各プロジェクトの README を参照してください。

## まとめ

書くツールは選択肢が山ほどあるのに、 「読むだけ」のツールは意外と選択肢が限られているな、というのが触ってみての感想でした。
一方で、並べてみるとそれぞれ個性がちゃんとあって、 2012 年の grip から 2026-02 の mo まで、生年に 14 年ほどの幅があるのも面白いところかと思います。

- README の push 前チェック → grip
- 素直な Markdown サーバ → markserv
- markserv とは別系統の Node 製 → md-fileserver
- ターミナル / SSH 先で読む → glow
- ブラウザ型で機能豊富に使い込む → mo
- macOS の GUI アプリで腰を据えて読む → Arto
- テーマ・フォントを細かくいじりたい → mdts

気になったものがあれば、ぜひ試してみてください。
