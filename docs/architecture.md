# Genesis アーキテクチャ

## 概要

Swift / SwiftUI で実装した iOS アプリ。ARKit + RealityKit で拡張現実を実現し、MVVM パターンで画面ロジックを管理する。

---

## 画面構成

```
GenesisApp
└── TitleView（タイトル画面）
    ├── DriveView（AR 操作画面）
    │   ├── ARViewContainer（ARKit ラッパー）
    │   ├── Joystick（操作スティック）
    │   ├── SpeedMeter（速度メーター）
    │   └── SteeringIndicator（ステアリング表示）
    ├── CarSelectionView（車種選択画面）
    └── SettingsView（設定画面）
```

---

## ファイル構成

```
ios/Genesis/
├── GenesisApp.swift              # アプリエントリーポイント
├── AppSettings.swift             # 設定管理（シングルトン）
├── CarModel.swift                # 車モデルの定義
├── classicCar.usdz               # 3D モデル（Blender 製 USDC を usdzip で再パッケージ）
├── Assets.xcassets/
│   ├── AppIcon.appiconset/
│   └── AR Resources.arresourcegroup/  # 画像認識用リファレンス画像
└── Screen/
    ├── Title/
    │   ├── TitleView.swift
    │   └── TitleViewModel.swift
    ├── Drive/
    │   ├── DriveView.swift
    │   ├── DriveViewModel.swift
    │   ├── ARViewContainer.swift  # UIViewRepresentable で ARView をラップ
    │   ├── Joystick.swift
    │   ├── SpeedMeter.swift
    │   └── SteeringIndicator.swift
    ├── CarSelection/
    │   └── CarSelectionView.swift
    └── Settings/
        └── SettingsView.swift
```

---

## アーキテクチャパターン

**MVVM（Model - View - ViewModel）**

| 役割 | クラス / ファイル |
|---|---|
| Model | `CarModel`, `AppSettings` |
| View | `*View.swift`, `ARViewContainer.swift` |
| ViewModel | `TitleViewModel`, `DriveViewModel` |

- ViewModel は `@Observable` マクロを使用（Swift 5.9 以降）
- `AppSettings` は `ObservableObject` のシングルトンで設定を全体に共有

---

## 主要コンポーネント

### AppSettings
- `UserDefaults` で設定値を永続化
- ステアリング感度・最大速度・加速度・選択車種を管理
- シングルトン（`AppSettings.shared`）

### CarModel
- 選択可能な車種を定義する値型（struct）
- 現在実装済みモデル：クラシックカー（`classicCar.usdz`）
- スポーツカー・SUV・トラックはデータのみ定義（モデルファイル未実装）

### ARViewContainer
- `UIViewRepresentable` で `ARView`（RealityKit）を SwiftUI にブリッジ
- `ARWorldTrackingConfiguration` で水平面を検出
- モデルの向き補正：X 軸 -90°（座標系変換）+ Y 軸 180°（モデル固有）
- 移動方向の計算で `-sin(rotation)` を使用（モデルの前後に合わせた補正）

### Joystick
- 画面上の仮想スティック UI
- X 軸でステアリング、Y 軸で前進 / 後退を制御

---

## 技術スタック

| 項目 | 内容 |
|---|---|
| 言語 | Swift 5.9+ |
| UI フレームワーク | SwiftUI |
| AR フレームワーク | ARKit + RealityKit |
| 3D モデル形式 | USDZ |
| 設定永続化 | UserDefaults |
| 最小サポート OS | iOS（ARKit 必須のため実機のみ） |
| ビルド | Xcode（`ios/Genesis.xcodeproj`） |
