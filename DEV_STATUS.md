# 開發狀態

最後更新：2026-09-03（Asia/Taipei）

## 當前結論

P0 Demo 已在原始碼層完成。主畫面採中央彈出式提問；選擇洗頭後，使用者拖曳外觀像澆花器的蓮蓬頭把頭髮澆濕。GitHub Actions 的 macOS runner 已成功完成 iOS Simulator build 與新版 SwiftUI 畫面渲染。本次本機環境只有 Windows，因此尚未在實際 Simulator 或 iPhone 操作。

最新通過的 CI：[iOS build run #5](https://github.com/hankforgamedev/washheady/actions/runs/33654890005)

目前雲端渲染畫面：[docs/screenshots/main.png](docs/screenshots/main.png)。這是雲端 Mac 以 Apple SwiftUI `ImageRenderer` 產生，角色共用 App 的 `CharacterHeadView`；它是可靠的靜態視覺參考，但不是已啟動 iOS Simulator 的實機截圖。

## 功能狀態

| 項目 | 狀態 | 備註 |
|---|---|---|
| SwiftUI App / Xcode project | CI 編譯通過 | iOS 17+；run #1 success |
| 巨大角色頭 | 已實作，待視覺 QA | 純 SwiftUI Shapes，無素材依賴 |
| 要洗／不洗 | 已實作，待互動 QA | 中央彈出視窗；可按 X 或點背景關閉 |
| 不洗後頭髮膨脹 | 已實作，待互動 QA | messinessLevel clamp 在 0...3 |
| 洗頭拖曳互動 | 已實作，待手感 QA | 拖曳綠色澆花器造型的蓮蓬頭 |
| 濕髮視覺 | 已實作，待視覺 QA | 頭髮縮小、變深、水滴浮現 |
| 洗完確認 | 已實作，待互動 QA | 自製 sheet，可選「洗完了／其實還沒」 |
| 信任使用者 | 已實作，待互動 QA | 勾選後下次淋完直接完成 |
| 本機持久化 | 已實作，待 kill/reopen QA | 使用 @AppStorage |
| Local notification | 未做 | P2，不阻擋 Demo |

## Definition of Done 驗證

- Test A — Don't Wash：待 Simulator / iPhone
- Test B — Wash：待 Simulator / iPhone
- Test C — Fake Wash：待 Simulator / iPhone

## Windows 端的硬限制

這台電腦沒有 Swift toolchain、Xcode 與 Apple SDK。Windows 無法提供 Xcode、iOS Simulator、SwiftUI Preview、iOS code signing 或實機安裝。macOS CI 已補上「可編譯」驗證，但無法代替觸控與視覺 QA。

## 下一位開發者從這裡接

1. 在 Mac 用 iPhone Simulator 執行三個 DoD 測試。
2. 只調整頭髮感應區、澆水累積速度、頭部尺寸等手感問題。
3. 不要在三個測試通過前開始 notification、角色編輯器或歷史 UI。

## 實機簽署

專案採 Automatic Signing，但 repo 不保存 Development Team、憑證或 provisioning profile。第一次在 Mac 接 iPhone 時，請在 Xcode 的 Signing & Capabilities 選擇自己的 Team。
