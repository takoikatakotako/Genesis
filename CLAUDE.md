# CLAUDE.md

## プロジェクト概要

Genesis は AR ラジコンカーの iOS アプリ。DriveCraft の後継プロジェクト。

## ビルド

- Xcode で `ios/Genesis.xcodeproj` を開いてビルド
- ARKit を使用するため実機が必須

## プロジェクト構成

- `ios/Genesis/` — アプリのソースコード
- `ios/Genesis/Assets.xcassets/AR Resources.arresourcegroup/` — 画像認識用リファレンス画像

## 重要な技術的コンテキスト

- USDZモデル（miniCooperbake.usdz）は元がBlender製USDCで、`usdzip`で再パッケージ済み
- モデルの向き補正が必要: X軸 -90度（座標系変換）+ Y軸 180度（モデル固有）
- 移動方向の計算で `-sin(rotation)` を使用しているのはモデルの前後に合わせた補正

## コーディング規約

- Swift / SwiftUI
- コメントは日本語

## 注意事項

- コミット・プッシュは明示的に指示があるまで行わない
