---
title: "ローカルの Markdown をツリー表示でブラウズできる CLI「mdts」を作りました"
emoji: "🎉"
type: "idea"
topics: [typescript,javascript,markdown,cli,server,preview]
published: true
published_at: 2025-07-29 12:37
---

## はじめに

最近 Markdown を触る機会、増えてますよね。 AI ツールの登場で、書いたり読んだりレビューしたりが日常的になってきました。
特に最近は **[Kiro](https://kiro.dev/)** なんかの登場もあり、Markdown がワークフローの中心になっている人も多いかと思います。

ただ、ローカルに溜まっていく `.md` ファイルを **読む** 体験には、あまり選択肢がありませんでした。
エディタで1ファイルずつ開くのは面倒だし、ツリー構造を見ながら全体を把握したいときにも不便です。

そこで今回 **mdts** を作りました。
ローカルにある Markdown ファイル群を、 `npx mdts` のみでツリー構造のままブラウザで閲覧できるようなCLIツールです。

![](https://github.com/unhappychoice/mdts/blob/main/docs/images/screen_animation.gif?raw=true)

## 特徴
* ⚡ **1コマンドで即起動**
    * `npx mdts` を叩くだけで現在のディレクトリをブラウズ可能。
* 🌐 **ブラウザベース**
    * 専用アプリ不要。Web ブラウザでそのまま閲覧可能。
* 📂 **ディレクトリ構造のツリー表示**
    * Markdown ファイルをツリー構造で一覧可能。`.md` / `.markdown` のファイルのみ表示。
* 🔍 **ナビゲーション**
    * 検索・自動展開・パンくずリストなど、必要なナビゲーションを搭載。
* 📝 **GitHub Flavored Markdown や Syntax Highlight 、 Mermaid 、 Frontmatter 対応**
    * GitHub スタイルの拡張Markdownはもちろん、コードのハイライティングや Mermaid 記法で作成したフローチャートやシーケンス図なども対応。
    * Frontmatter に関しては本文とは分けて別タブ表示。

## 使い方

以下のコマンドで、現在のディレクトリに対するローカルサーバーが立ち上がり、自動的にブラウザが開きます。

```bash
npx mdts
```

特定のディレクトリを指定したい場合はパスを与えます。

```bash
npx mdts ./docs
```

## ユースケース

* AI 等が生成したドキュメントの確認、レビュー
* 新しく参加するプロジェクトのドキュメント群（README, ADR など）を構造ごとに確認
* Markdown による個人ドキュメント / Wiki管理
    * [Obsidian](https://obsidian.md/) や Zettelkasten をもっと軽量な形で
* [GitHub](https://github.com/) に push する前の、ドキュメントの構成や見た目の確認

## なぜ作ったか

スタイル付きで Markdown のファイルを手軽に閲覧できるツールを探してたところ、以下のような問題がありました：

* **[marksrv](https://github.com/markserv/markserv) / [md-fileserver](https://github.com/commenthol/md-fileserver) / [Grip](https://github.com/joeyespo/grip) などの、 mdts に似た CLI ツール**
    * ファイルツリーに対応していなかったり、ナビゲーションが限定的。
    * モダンなUIではない場合が多い。
* **[VSCode](https://code.visualstudio.com/) 等、エディタの Markdown Preview**
    * 他のソースファイルなども表示され、読むことに集中しづらい。
    * デザインなどが最低限の場合がある。
* **[Obsidian](https://obsidian.md/) （などの Markdown エディタ）**
    * 高機能だが、vault の概念に依存しており、既存ディレクトリをそのまま開いて使うには適さず。
    * 編集のUIが前提となっている場合が多い
* **[Docsify](https://docsify.js.org/) / [VitePress](https://vitepress.dev/) / [Docusaurus](https://docusaurus.io/) などの Static Site Generator**
    * ドキュメントサイト構築には便利だが、構成やビルドが必要。
* **[GitHub](https://github.com/) 上で読む**
    * リモートへの push が必要で、ローカルの一時的なドキュメント確認には不向き。
    * 他のソースファイルなども表示され、読むことに集中しづらい。

どれも自分の要件に合うものがなかったため、今回 `mdts` を作ることにしました。

## 参考にしたツールと謝辞
本ツールの開発にあたり、以下のプロジェクトから多くを学び、刺激を受けました。

* [difit](https://github.com/yoshiko-pg/difit)
    * Git の差分を1コマンドで美しく確認できるツール。
    * CLIの使い勝手や、見やすいUI設計の参考にさせていただきました。
* [zenn-cli](https://github.com/zenn-dev/zenn-editor)
    * Zenn のコンテンツ管理ツール。今回の `mdts` とかなり似た機能があり、参考にさせていただきました。

これら開発者の皆様に深く感謝いたします。

## リンク

* LP: [https://mdts.unhappychoice.com](https://mdts.unhappychoice.com)
* GitHub: [https://github.com/unhappychoice/mdts](https://github.com/unhappychoice/mdts)
* NPM: [https://www.npmjs.com/package/mdts](https://www.npmjs.com/package/mdts)

## おわりに

**Markdown を書く** 環境は増えていますが、 **読む** ための軽量ツールはまだ少ないように思います。
mdts は、そういった用途を補うための小さなツールです。
気になった方はぜひ一度、 Markdown が含まれてるプロジェクトで↓試してみてください。

```bash
npx mdts
```
