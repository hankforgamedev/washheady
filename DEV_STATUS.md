# 開發狀態

最後更新：2026-09-02（Asia/Taipei）

## 當前結論

P0 Demo 已在原始碼層完成；本次開發環境只有 Windows，因此尚未在本機 Xcode、Simulator 或 iPhone 實際執行。第一次可編譯性驗證交由 GitHub Actions 的 macOS runner。

## 功能狀態

| 項目 | 狀態 | 備註 |
|---|---|---|
| SwiftUI App / Xcode project | 已實作，待 CI | iOS 17+ |
| 巨大角色頭 | 已實作，待視覺 QA | 純 SwiftUI Shapes，無素材依賴 |
| 要洗／不洗 | 已實作，待互動 QA | 主畫面兩顆大按鈕 |
| 不洗後頭髮膨脹 | 已實作，待互動 QA | messinessLevel clamp 在 0...3 |
| 洗頭拖曳互動 | 已實作，待手感 QA | 在頭髮 hit area 內拖曳累積濕度 |
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

這台電腦沒有 Swift toolchain、Xcode 與 Apple SDK。Windows 無法提供 Xcode、iOS Simulator、SwiftUI Preview、iOS code signing 或實機安裝。

## 下一位開發者從這裡接

1. 先看 GitHub Actions 的 iOS build 是否綠燈；紅燈就只修編譯錯誤。
2. 在 Mac 用 iPhone Simulator 執行三個 DoD 測試。
3. 只調整 hit area、拖曳累積速度、頭部尺寸等手感問題。
4. 不要在三個測試通過前開始 notification、角色編輯器或歷史 UI。

## 實機簽署

專案採 Automatic Signing，但 repo 不保存 Development Team、憑證或 provisioning profile。第一次在 Mac 接 iPhone 時，請在 Xcode 的 Signing & Capabilities 選擇自己的 Team。
