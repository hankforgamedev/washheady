# 開發記憶

這份檔案只保存專案決策與交接資訊。Repository 是 public，禁止把帳號密碼、憑證、provisioning profile、Apple Team ID 或私人背景資料放進來。

## 產品北極星

今天只驗證一件事：一顆會因為使用者洗不洗頭而變化的巨大頭，好不好玩。

人格不是健康 App。不要 streak、衛生建議、羞辱、油滴、臭氣或失敗語言。不洗也要是一個完整且好笑的結果。

## 已採用的最小方案

- UI：SwiftUI，iOS 17+
- 角色：純 SwiftUI Shapes；之後可把 CharacterHeadView 換成 PNG / SVG 狀態圖
- 狀態：直接放在 ContentView 的少量 @AppStorage
- 畫面：主畫面中央彈出提問視窗 + 一個 full-screen 洗頭畫面 + 確認 sheet
- 洗頭：手指直接在頭髮感應區搓揉，依移動距離累積 wetProgress
- 頭髮回饋：頭髮跟著手指小幅偏移，放手後彈回；觸點顯示水滴圈
- CI：GitHub Actions macOS runner，只做無簽章 Simulator build

## Persistence keys

| Key | 型別 | 意義 |
|---|---|---|
| messinessLevel | Int | 0...3 頭髮澎度 |
| lastStatus | String | WashStatus.rawValue |
| lastStatusDate | Double | Unix timestamp |
| trustUser | Bool | 搓完後是否跳過確認 |

lastStatusDate 目前只記錄，不做跨日排程。跨日絕不自動把頭髮恢復 clean。

## 關鍵檔案

- WashHead/ContentView.swift：持久狀態與主流程
- WashHead/CharacterHeadView.swift：巨大頭、澎髮與濕髮視覺
- WashHead/WashInteractionView.swift：直接搓揉頭髮、感應區、完成確認
- WashHead.xcodeproj/project.pbxproj：單一 iOS app target
- PRODUCT_BRIEF.md：完整 build brief
- DEV_STATUS.md：哪些已做、哪些尚未由 Mac 驗證

## 刻意不做

3D、backend、登入、CloudKit、Firebase、HealthKit、通知、歷史、streak、分析 SDK、廣告、角色編輯器、第三方套件。

## 最可能需要在 Simulator 調的三個數字

都在 WashInteractionView.swift：

- 頭髮感應區的 `location.y <= size.height * 0.60`
- `distance / 620` 的濕度累積速度
- `hairOffset` 的水平／垂直跟手倍率

不要為調手感重構狀態架構。
