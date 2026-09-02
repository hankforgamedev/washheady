# 洗頭了沒

[![iOS build](https://github.com/hankforgamedev/washheady/actions/workflows/ios-build.yml/badge.svg)](https://github.com/hankforgamedev/washheady/actions/workflows/ios-build.yml)

一顆會依你洗不洗頭而改變的巨大頭。這是一天內完成、讓家人能直接玩的原生 iOS SwiftUI Demo；不是健康追蹤器，也不會對沒洗頭說教。

![目前的雲端 SwiftUI 畫面](docs/screenshots/main.png)

## 已實作

- 巨大 2D SwiftUI 角色頭
- 中央彈出式「今天要洗頭嗎？」主流程
- 不洗時頭髮逐次膨脹，最高三段
- 直接搓揉／拖動頭髮，把它逐步弄濕
- 洗完確認與「其實還沒」分支
- 「不要再提醒我，我很誠實」信任選項
- @AppStorage 本機持久化

完整規格見 [PRODUCT_BRIEF.md](PRODUCT_BRIEF.md)，目前驗證狀態見 [DEV_STATUS.md](DEV_STATUS.md)，延續開發前先讀 [DEVELOPMENT_MEMORY.md](DEVELOPMENT_MEMORY.md)。

## 在 Mac 上執行

1. 用 Xcode 開啟 WashHead.xcodeproj。
2. 選擇 WashHead scheme 與任一 iPhone Simulator。
3. 按 ⌘R。

若要裝到實機，在 target 的 Signing & Capabilities 選擇自己的 Apple Development Team；必要時把 bundle identifier 改成自己帳號下唯一的值。

最低部署版本是 iOS 17。

## 只有 Windows 時

Windows 可以編輯所有程式與文件、commit/push，並透過本 repo 的 GitHub Actions 讓 macOS runner 執行無簽章的 Simulator build。

Windows 本機不能：

- 安裝或執行 Xcode
- 開啟 iOS Simulator / SwiftUI Preview
- 編譯這個 SwiftUI iOS target
- 簽署並安裝到 iPhone

因此 CI 綠燈代表「能編譯」，不代表觸控手感已驗證。最終互動測試仍需 Mac 或可遠端操作的 Mac。

參考：[Apple Xcode 系統需求](https://developer.apple.com/xcode/system-requirements/) · [GitHub-hosted runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)

## CI

每次 push / pull request 都會在 macos-15 runner 執行：

~~~sh
xcodebuild \
  -project WashHead.xcodeproj \
  -scheme WashHead \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
~~~
