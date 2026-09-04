# 開發狀態

最後更新：2026-09-05（Asia/Taipei）

## 當前結論

Mac 驗收範圍已全部進入原始碼：每日提問、澆水蓮蓬頭、歷史月曆、捏頭、通知 action、睡前 unknown 與四種狀態 App icon。模組化搬遷已全部完成：App、Core、Wash、History、Character、Settings、Notifications、AppIcon 與 Storefront 都有獨立目錄和接口。Storefront 已實作 StoreKit 2 的商品載入、購買、還原與 verified entitlement，但沒有正式 product ID，因此預設關閉且不影響免費核心。Windows 端仍無法取代 Simulator／iPhone 的觸控、通知、購買與桌面 icon 驗收。

最新通過的 CI：[all modules build](https://github.com/hankforgamedev/washheady/actions/runs/33904185295)。雲端以 arm64 macOS 26、Xcode 26.6 與 iOS 26 SDK 完整編譯 target，包含 StoreKit 2 的最終模組組合顯示 `BUILD SUCCEEDED`。

目前雲端渲染畫面：[docs/screenshots/main.png](docs/screenshots/main.png)。這是雲端 Mac 以 Apple SwiftUI `ImageRenderer` 產生，角色共用 App 的 `CharacterHeadView`；它是可靠的靜態視覺參考，但不是已啟動 iOS Simulator 的實機截圖。

## 功能狀態

| 項目 | 狀態 | 備註 |
|---|---|---|
| SwiftUI App / Xcode project | CI 編譯通過 | 最低 iOS 17；Xcode 26.6 / iPhoneSimulator 26.5 SDK success |
| 模組組裝層 | 搬遷完成，CI 通過 | `AppModules.live` 集中組裝；另有不載入周邊服務的 `coreOnly` 組合 |
| 巨大角色頭 | 已實作，待視覺 QA | 純 SwiftUI Shapes，可即時套用捏頭設定 |
| 要洗／不洗 | 已實作，待互動 QA | 中央彈出視窗；可按 X 或點背景關閉 |
| 不洗後頭髮膨脹 | 已實作，待互動 QA | messinessLevel clamp 在 0...3 |
| 洗頭拖曳互動 | 已實作，待手感 QA | 拖曳綠色澆花器造型的蓮蓬頭 |
| 濕髮視覺 | 已實作，待視覺 QA | 頭髮縮小、變深、水滴浮現 |
| 中途離開確認 | 已實作，待互動 QA | 中央 popup；確定離開寫入 not_washed |
| 洗完確認 | 已實作，待互動 QA | 自製 sheet，可選「洗完了／其實還沒」 |
| 信任使用者 | 已實作，待互動 QA | 勾選後下次淋完直接完成 |
| 歷史月曆 | 已實作，待互動 QA | 顯示／更正 washed、not_washed、unknown |
| 更正後回算頭髮 | 已實作，待資料 QA | 由最後一次 washed 後的 not_washed 次數推導 |
| 捏頭 | 已實作第一版，待視覺 QA | 膚色、髮色、髮型、臉型、眼睛、嘴巴 |
| Local notification | 已實作，待權限／背景 QA | 七天各別時間；通知 action 可選要／不要 |
| 睡前 unknown | 已實作，待跨日 QA | 睡前 10 分鐘；凌晨睡眠歸入前一個生活日 |
| 動態 App icon | 已實作，待 iPhone QA | primary + Puffy / Max / Unknown alternate icons |
| 本機持久化 | 已實作，待 kill/reopen QA | 使用 @AppStorage / UserDefaults JSON |
| StoreKit storefront | 模組已實作、入口關閉 | 待正式 product ID、StoreKit configuration 與 Sandbox 實機 QA |

## 實機驗收

逐項步驟與預期結果見 [MAC_ACCEPTANCE_CHECKLIST.md](MAC_ACCEPTANCE_CHECKLIST.md)。目前所有項目都只有「CI 可編譯」證據，沒有宣稱已通過實機操作。

## Windows 端的硬限制

這台電腦沒有 Swift toolchain、Xcode 與 Apple SDK。Windows 無法提供 Xcode、iOS Simulator、SwiftUI Preview、iOS code signing 或實機安裝。macOS CI 已補上「可編譯」驗證，但無法代替觸控與視覺 QA。

## 下一位開發者從這裡接

1. 在 M1 Mac 拉取 main，用 Xcode 26 與 iOS 26 iPhone Simulator 依驗收清單逐項操作。
2. 通知先用「兩分鐘後」的時間測，不要真的等到晚上。
3. alternate App icon 優先在實體 iPhone 驗證；Simulator 結果只當參考。
4. 每抓到一個問題就記錄裝置、iOS 版本、步驟與畫面，不要同時憑感覺改五處。

## 實機簽署

專案採 Automatic Signing，但 repo 不保存 Development Team、憑證或 provisioning profile。第一次在 Mac 接 iPhone 時，請在 Xcode 的 Signing & Capabilities 選擇自己的 Team。
