# 模組架構

最後更新：2026-09-05（Asia/Taipei）

目標是讓「洗頭核心」可以繼續調整，而月曆、捏頭、通知與 App icon 不必一起被重寫。這裡的模組是同一個 iOS target 內的可替換邊界；先不拆成多個 Swift Package，避免一天版專案多出無必要的建置成本。

## 固定核心

- `WashStatus` 與 `WashHistory`：每日資料規則。
- `CharacterAppearance`：所有畫面共用的頭部外觀資料。
- `ContentView`：只負責組合模組與切換流程。
- 每日提問與 `WashInteractionFeatureModule`：目前不可移除的產品核心。

核心可以改 UI 與手感，但不得直接知道月曆、通知、App icon 的內部實作。

## 可插拔模組

| 模組 | 輸入／輸出邊界 | 能否移除或替換 |
|---|---|---|
| `HistoryFeatureModule` | 歷史 JSON binding + 紀錄變更 callback | 可以 |
| `CharacterEditorFeatureModule` | 外觀參數 bindings | 可以 |
| `SettingsFeatureModule` | 設定 bindings + service modules | 可以 |
| `ReminderServiceModule` | 排程快照、權限、取消日期 | 可以換成 fake／新版排程器 |
| `AppIconServiceModule` | `messinessLevel` + `isUnknown` | 可以換成 no-op／其他 icon 策略 |
| `WashInteractionFeatureModule` | 洗頭輸入 + 完成／放棄 callbacks | 可以換實作，但 App 必須保留一個版本 |
| `StorefrontFeatureModule` | StoreKit 商品快照 + 購買／還原 commands | 規劃中；不得阻塞免費核心 |

所有組裝集中在 `AppModules.live`。可選 UI 模組使用 optional；拿掉模組時，主畫面的入口也一起消失，不需要修改核心資料規則。

## 依賴方向

```text
WashHeadApp
    └── ContentView + AppModules
          ├── 洗頭核心
          ├── 月曆模組 ──────┐
          ├── 捏頭模組       │
          └── 設定模組       │
                ├── 通知服務 │
                └── Icon 服務│
                             ▼
                 WashStatus / WashHistory / CharacterAppearance
```

功能模組只透過 input struct、`Binding` 和 callback 交換資料，不讀取其他模組的 private state。

## 新功能的規則

1. 一個功能新增一個 `FeatureModule` 與一個 input struct。
2. 模組只取得它真正需要的 bindings／callbacks，不能直接拿整個 `ContentView`。
3. 系統 API 包在 service module，畫面不直接綁死 UIKit／UserNotifications。
4. 先把新模組接成 optional，再由 `AppModules.live` 開啟。
5. 每次只搬一個模組，推送後以 GitHub Actions 保持 `BUILD SUCCEEDED`。

## 處理順序與狀態

1. [x] 建立所有現有功能的組裝接口。
2. [ ] 通知：拆出排程、action handling 與 delegate。
3. [ ] App icon：拆出狀態策略與 UIKit adapter。
4. [ ] 歷史：獨立 feature folder 與 module contract。
5. [ ] 角色／捏頭：獨立 appearance model、renderer、editor contract。
6. [ ] 設定：只組合 settings bindings 與注入服務。
7. [ ] 洗頭核心：獨立互動與每日提問邊界。
8. [ ] 共用 domain／app composition：只保留跨模組資料規則與接線。
9. [ ] StoreKit：先提供可關閉的 storefront／entitlement 邊界；沒有正式 product id 前不顯示付費入口。
10. [ ] Xcode 26 全量編譯與狀態文件更新。
