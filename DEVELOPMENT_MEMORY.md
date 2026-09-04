# 開發記憶

這份檔案只保存專案決策與交接資訊。Repository 是 public，禁止把帳號密碼、憑證、provisioning profile、Apple Team ID 或私人背景資料放進來。

## 產品北極星

產品核心：幫使用者記住「自己到底有沒有洗頭」。一顆會因為洗不洗頭而變化的巨大頭，是記憶介面，不是裝飾。

人格不是健康 App。不要 streak、衛生建議、羞辱、油滴、臭氣或失敗語言。不洗也要是一個完整且好笑的結果。

## 已採用的最小方案

- UI：SwiftUI，最低支援 iOS 17；開發、CI 與驗收使用 Xcode 26／iOS 26 SDK
- 角色：純 SwiftUI Shapes；之後可把 CharacterHeadView 換成 PNG / SVG 狀態圖
- 狀態：每日紀錄編碼為 UserDefaults JSON；畫面澎度永遠由歷史回算
- 畫面：主畫面中央彈出提問視窗 + 一個 full-screen 洗頭畫面 + 確認 sheet
- 洗頭：拖曳外觀像澆花器的蓮蓬頭，進入頭髮感應區後依移動距離累積 wetProgress
- 水效果：半透明水柱；不做 particle 或流體模擬
- 歷史：簡單月曆，可更正；更正後即時回算頭髮
- 通知：本機排程，提供「要／不要」action；「要」開啟澆水，「不要」直接寫入紀錄
- 捏頭：純 SwiftUI 分層角色的第一版參數編輯器
- App icon：預先打包四組 icon，透過 UIApplication alternate icon API 切換
- CI：GitHub Actions arm64 macOS 26 runner，固定 Xcode 26.6，只做無簽章 Simulator build
- 模組：所有組裝集中在 `AppModules.live`；功能只透過 input struct、Binding 與 callback 交換資料

## Persistence keys

| Key | 型別 | 意義 |
|---|---|---|
| washHistoryJSON | JSON String | 日期字串對 WashStatus 的 map |
| lastStatus | String | WashStatus.rawValue |
| lastStatusDate | Double | Unix timestamp |
| trustUser | Bool | 澆完後是否跳過確認 |
| showerScheduleJSON | JSON String | 星期一至日是否啟用與分鐘數 |
| sleepMinuteOfDay | Int | 平常睡覺時間 |
| notificationsEnabled | Bool | 是否排程本機通知 |
| iconSyncEnabled | Bool | 是否跟狀態切換 alternate icon |
| skinTone 等 | Int / Double | 角色外觀參數 |

`lastStatus` 與 `lastStatusDate` 保留給舊版資料遷移與通知 action。權威資料是 `washHistoryJSON`。若睡覺時間在凌晨 06:00 前，凌晨紀錄歸入前一個生活日。

## 關鍵檔案

- WashHead/ContentView.swift：持久狀態與主流程
- WashHead/AppModules.swift：所有可替換功能與系統服務的 composition root
- WashHead/Features/Character：共用 appearance model、巨大頭 renderer、捏頭 editor 與 module contract
- WashHead/WashInteractionView.swift：拖曳澆水蓮蓬頭、感應區、完成確認
- WashHead/WashData.swift：歷史、澎度回算、生活日與七天排程資料
- WashHead/Infrastructure/Notifications：通知排程、action handling 與可替換 reminder service
- WashHead/App/AppDelegate.swift：iOS app delegate，只轉送系統 notification callback
- WashHead/Infrastructure/AppIcon：alternate icon 實作與可替換 icon service
- WashHead/Features/History：月曆 View 與可替換 feature contract
- WashHead/SettingsView.swift：洗澡時間、睡覺時間、通知與 icon 設定
- WashHead/Assets.xcassets：primary / Puffy / Max / Unknown app icons
- WashHead.xcodeproj/project.pbxproj：單一 iOS app target
- PRODUCT_BRIEF.md：完整 build brief
- LONG_TERM_PRODUCT_SPEC.md：已確認的長期完成版方向
- MAC_ACCEPTANCE_CHECKLIST.md：明天的操作驗收順序
- DEV_STATUS.md：哪些已做、哪些尚未由 Mac 驗證
- MODULE_ARCHITECTURE.md：模組邊界、依賴方向與擴充規則

## 刻意不做

3D、backend、登入、CloudKit、Firebase、HealthKit、streak、分析 SDK、廣告、社群、第三方套件。

## 最可能需要在 Simulator 調的三個數字

都在 WashInteractionView.swift：

- `hairHitArea` 的 x/y/width/height 比例
- `distance / 780` 的濕度累積速度
- 澆水蓮蓬頭初始位置 0.78 / 0.76

不要為調手感重構狀態架構。
