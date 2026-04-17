# B8-脸谱AR秀：京剧变脸互动体验

## 项目简介

脸谱AR秀是一款基于 iOS ARKit 人脸追踪技术的增强现实应用，将传统京剧脸谱文化与 AR 技术深度融合。用户可以在相机中实时预览自己佩戴不同京剧脸谱的效果，通过点击界面按钮一键切换脸谱，并支持拍照保存到本地相册，便于社交媒体分享与传播。

项目旨在解决京剧脸谱文化传播形式传统、缺乏互动性与趣味性的问题，让年轻用户以沉浸式方式接触和体验中华非遗文化。

## 功能特点

- **实时人脸识别与跟踪**：使用 ARKit 提供的 `ARFaceTrackingConfiguration`，实时捕捉用户面部特征，实现 3D 几何脸部模型叠加。
- **京剧脸谱贴图**：精选多种京剧脸谱素材，用户可从右侧弹出的脸谱列表（自定义 View + UICollectionView）中选择并实时替换。
- **一键拍照保存**：支持一键保存当前 AR 贴图画面，拍摄照片保存到 iOS 相册，方便分享。
- **流畅的 AR 渲染体验**：基于 SceneKit 实现高质量 3D 脸谱渲染，贴合面部轮廓，随表情实时变形。

## 技术架构与实现原理

### 整体架构

```
iPhone 前置摄像头 → ARSession(ARFaceTrackingConfiguration) → ARSCNView → SceneKit 渲染 → 脸谱贴图叠加
```

### 核心技术

- **ARKit**：苹果增强现实框架，提供高精度的面部追踪与 3D 几何网格生成。
- **SceneKit**：3D 场景渲染引擎，用于将脸谱纹理贴合到 `ARSCNFaceGeometry` 上。
- **ARSCNFaceGeometry**：根据用户面部形状动态生成的 3D 几何体，确保脸谱完美贴合。
- **UICollectionView**：右侧弹出式脸谱选择面板，支持横向滑动浏览。
- **AVFoundation / Photos**：拍照截图与相册保存。

### 关键源码说明

- `ViewController.swift`：主界面控制器，管理 ARSession 生命周期、脸谱切换逻辑与拍照功能。
- `VirtualContentUpdater.swift`：AR 内容更新器，处理面部锚点变化时的内容同步。
- `Mask.swift`：脸谱遮罩模型，定义如何将纹理应用到面部几何体上。
- `VirtualFaceContent.swift`：虚拟面部内容协议与基础实现。
- `BottomSheetFacePickerView.swift`：底部/侧滑脸谱选择器视图。
- `RobotHead.swift`：额外的虚拟头部内容示例（如机器人头部特效）。

## 项目目录结构

```
B8-脸谱AR秀：京剧变脸互动体验/
├── ARKitFaceExample.xcodeproj/     # Xcode 工程文件
├── ARKitFaceExample/
│   ├── AppDelegate.swift
│   ├── ViewController.swift
│   ├── StatusViewController.swift
│   ├── VirtualContentUpdater.swift
│   ├── BottomSheetFacePickerView.swift
│   ├── RobotHead.swift
│   ├── Base.lproj/
│   │   └── Main.storyboard
│   ├── Content Selection/
│   │   └── VirtualContentType.swift
│   ├── VirtualFaceContent/
│   │   ├── Mask.swift
│   │   └── VirtualFaceContent.swift
│   └── Resources/
│       ├── Info.plist
│       └── LaunchScreen.storyboard
├── Configuration/
│   └── SampleCode.xcconfig
├── Documentation/
│   └── FaceExampleModes.png
├── LICENSE/
│   └── LICENSE.txt
└── README.md
```

## 安装与运行说明

### 环境要求

- macOS 系统 + Mac 电脑
- iPhone / iPad（支持 Face ID 或前置深感摄像头，iOS 15+）及数据线
- Apple ID（建议注册免费开发者账号）
- Xcode（最新版，通过 App Store 安装）

### 安装步骤

1. 克隆项目到本地：
   ```bash
   git clone https://github.com/magiclab2233/B8-Peking-Opera-Face-Changing-AR.git
   cd B8-Peking-Opera-Face-Changing-AR
   ```

2. 打开 Xcode 工程：
   ```bash
   open ARKitFaceExample.xcodeproj
   ```

3. Xcode 签名配置：
   - 选择工程文件 → 修改 Bundle Identifier
   - 勾选 "Automatically manage signing"
   - Team 中选择个人 Apple ID 对应的免费开发者证书

4. 连接 iPhone，选择设备后点击运行按钮。

### 首次运行注意事项

- **开启开发者模式**：设置 → 隐私与安全 → 开发者模式 → 打开（需重启）。
- **信任开发者证书**：设置 → 通用 → VPN 与设备管理 → 选择个人证书 → 点击信任。
- **ARKit 面部追踪需要 TrueDepth 摄像头**，请在 iPhone X 及以上机型运行。

## 使用场景

- **非遗文化科普展厅/教育课堂**：作为京剧文化的互动体验装置。
- **博物馆互动装置**：让观众以 AR 方式体验传统脸谱艺术。
- **社交媒体分享**：用户拍照生成个性化的京剧脸谱照片，分享到朋友圈。
- **青少年传统文化学习**：以趣味互动形式激发年轻人对中华传统文化的兴趣。

## 许可证/声明

本项目基于 ARKit 与 SceneKit 开发，部分示例代码遵循苹果官方 Sample Code 许可协议。项目仅供学习、教学演示与课程设计使用，涉及的京剧脸谱素材版权归原作者所有。
