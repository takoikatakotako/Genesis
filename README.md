# Genesis

AR空間上でミニクーパーのラジコンを操作できるiOSアプリ。

## 機能

- カメラで画像（B5用紙）を認識し、その上に3Dモデルを配置
- ジョイスティックでステアリング操作
- アクセルボタンで前進（加速・減速の物理挙動あり）

## 技術スタック

- SwiftUI
- ARKit（画像認識、ワールドトラッキング）
- RealityKit（USDZモデル読み込み・描画）

## プロジェクト構成

```
Genesis/
├── ios/                    # Xcode プロジェクト
│   ├── Genesis/            # ソースコード
│   │   ├── GenesisApp.swift
│   │   ├── ContentView.swift
│   │   ├── ARViewContainer.swift
│   │   ├── Joystick.swift
│   │   ├── miniCooperbake.usdz
│   │   └── Assets.xcassets/
│   │       └── AR Resources.arresourcegroup/
│   ├── Genesis.xcodeproj
│   ├── GenesisTests/
│   └── GenesisUITests/
└── README.md
```

## セットアップ

1. Xcode で `ios/Genesis.xcodeproj` を開く
2. 実機をターゲットに設定（ARKit はシミュレータ非対応）
3. ビルド＆実行
4. B5用紙をカメラに向けるとミニクーパーが出現

## 備考

- USDZモデルは Blender から書き出した USDC を `usdzip` で再パッケージしたもの（詳細は DriveCraft の `docs/usdz-model-fix.md` を参照）
- モデルの座標系補正: X軸 -90度（Blender Z-up → RealityKit Y-up）+ Y軸 180度（モデル固有の前後反転）
