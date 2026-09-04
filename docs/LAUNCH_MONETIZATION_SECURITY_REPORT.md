# 「洗頭了沒」iOS 商業化、資安與明日上線決策報告

**研究日期：2026-09-04**  
**適用版本：目前 `WashHead` repository，以及未來規劃中的照片／AI 生成功能**

> 一句話決策：**先賣角色個性，不要賣使用者資料；v1.0 不收照片、不接 OpenAI，先用一次性外觀包收費；AI 照片生成放到有後端、配額與刪除機制的 v1.1，採按次點數制。**

---

## 0. 執行摘要

### 商業模式

最適合本產品的組合是：

1. **免費本機核心**：洗頭紀錄、提醒、歷史、基本角色編輯，全留在手機。
2. **一次性「創始人個性包」**：建議先測 `NT$90–150`，提供原創髮型、臉、表情、背景、台詞與 App Icon；採 StoreKit 2 非消耗型購買。
3. **AI 大頭生成點數**：等 v1.1 安全架構完成後再賣，例如 3 次一包；每次成功工作扣一點，技術失敗自動退點。這比訂閱更符合有變動成本、低頻使用的生成服務。
4. **暫時不要廣告、賣資料、社交牆、聊天與抽箱**：它們會把一個簡單、有性格的小工具變成內容審核與隱私工程專案。
5. **暫時不要月訂閱**：目前沒有足夠持續價值。Apple 要求自動續訂服務持續提供價值；等到每月新素材、固定 AI 點數、跨裝置備份等真的存在後，再測年訂閱。[Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

### 資安判定

- **現在的版本**沒有網路、OpenAI、照片、登入或後端，因此「API Key 被偷」「伺服器被大量請求打垮」「雲端照片外洩」目前都尚不存在。
- **但目前版本不是照片／AI 生產環境安全版本。** 若直接把 OpenAI API Key 寫進 iOS App，風險為 **Critical／不可上線**；行動 App 內的 hardcoded secret 可從安裝包或執行期被取出。[OWASP MASWE-0004](https://mas.owasp.org/MASWE/MASVS-STORAGE/MASWE-0004/)
- 照片與 AI 功能必須改成：**iPhone → 自家受驗證後端 → 排隊系統 → OpenAI**。API Key 只存在伺服器 Secret Manager，App 永遠看不到。
- OpenAI API 資料預設不拿去訓練，但預設 abuse-monitoring logs 最多可保留 30 天；影像／檔案輸入也會做 CSAM 掃描。產品文案不能聲稱「照片絕不離開手機」或「所有副本立刻刪除」。[OpenAI Data Controls](https://developers.openai.com/api/docs/guides/your-data)

### 「明天開始盈利」的現實邊界

**不能誠實保證明天公開上架並收到 App Store 營收。** 目前缺 StoreKit、商品、簽章實機 QA、隱私政策／條款 URL、商店素材與審查設定。Apple 公布 90% submissions 平均在 24 小時內審完，但不是 SLA；批准後也可能再花最多 24 小時出現在商店。[App Review](https://developer.apple.com/app-store/review/)

而且 TestFlight 測試版**不得用任何形式收費**，第一個 external TestFlight build 也可能需要 beta review。[App Review Guidelines §2.2](https://developer.apple.com/app-store/review/guidelines/)、[TestFlight Overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview)

所以明天的合理交付是：

- `v1.0`：**無照片、無 AI、無帳號**，加入一次性外觀包、購買還原、隱私政策與正式 metadata，完成實機 QA 後送審。
- 同時開免費候補名單或 external beta；**不要把付費當作取得 TestFlight 的條件**。
- `v1.1`：後端、安全控制、照片明確同意與 AI 點數制完成後再送。

---

## 1. 競品如何賺錢

### 1.1 競品矩陣

| 產品 | 免費鉤子 | 營利方式 | 價格訊號（研究當日商店頁） | 對我們的教訓 |
|---|---|---|---|---|
| [PicPet（台灣 App Store）](https://apps.apple.com/tw/app/picpet/id6742077014) | 和朋友分享照片、養寵物、賺幣升級 | `PicPet+` 月／年訂閱、代幣包、廣播道具；Premium 解鎖自訂寵物／背景、相簿上傳、相框、去浮水印、縮短冷卻 | 月 `NT$120`、年 `NT$1,190`；代幣約 `NT$60–2,990`；廣播 `NT$30` | 人們付費買的是**身份表達、收藏與社交展示**。但社交、UGC、虛擬幣與通知施壓會同時增加審核、隱私與信任成本。 |
| [Freshily](https://apps.apple.com/us/app/freshily-smart-hair-wash-day/id6755645431) | 洗髮排程、紀錄、提醒 | Premium 年費＋Lifetime；主打無帳號、無廣告、本機與可選 iCloud | 年 `US$9.99`、Lifetime `US$19.99` | 與我們最接近。**隱私／離線也能被包裝成價值**，但商店評價量仍少，顯示純紀錄功能的付費天花板可能不高。 |
| [iPoop](https://apps.apple.com/us/app/poop-tracker-calendar-ipoop/id1671100769) | 排便日曆／紀錄 | 廣告＋Premium 年費／永久解鎖 | 年 `US$5.99`、永久解鎖約 `US$9.99–20.99` | 實用工具常用「便宜年費／永久買斷」；廣告可賺錢，但會傷害這種私密、日常型產品的氣質。 |
| [Happy Poop](https://apps.apple.com/us/app/happy-poop-toilet-journal-log/id1586000388) | 核心紀錄全部免費 | 非侵入式廣告、一次性永久去廣告、贊助／donation | 贊助 `US$0.99–49.99`；官方說明為一次性永久去廣告、無訂閱 | 忠誠社群可以支持 donation，但不是第一天可靠營收模型。它也用 PIN／生物辨識與偽裝 icon 回應私密資料焦慮。[官方 Help](https://casadozeps.com/help/settings-customization.html) |
| [KB Poop Tracker AI](https://apps.apple.com/us/app/kb-poop-tracker-ai-stool-scan/id6784489026) | 本機日誌與照片 | AI 照片分析、聊天、PDF、完整歷史、多 profile 付費 | 週 `US$1.99`、年 `US$29.99`、Lifetime `US$39.99` | 有真實 AI 成本時才有理由收 recurring／higher price；照片每次 opt-in 是好模式。App Store 的「Data Not Collected」是 Apple 定義下的標籤，不能直接等同資料從未離開裝置。 |
| [GutLog](https://apps.apple.com/us/app/ibs-poop-tracker-gutlog/id6749550927) | 離線、本機、無帳號的基礎紀錄 | 進階分析、PDF 匯出、模式洞察 Premium | 週 `US$1.99`、月 `US$9.99`、年 `US$34.99`、Lifetime 最高約 `US$59.99` | 付費牆應放在「產生新價值」的分析／匯出，不是封鎖最基本的記錄。 |
| [Poop Map](https://apps.apple.com/us/app/poop-map-pin-and-track/id1303269455) | 地圖打卡＋朋友社交 | IAP／社交擴散 | 美國商店有數萬評分 | 排泄主題能靠可分享的荒謬感成長；但地點與 UGC 會新增跟蹤、騷擾與審核風險，不適合明日版。 |

### 1.2 可複製的，不該複製的

可複製：

- PicPet 的**個人化與收藏動機**：使用者不是為工具按鈕付費，而是為「這顆頭真的像我／有我的怪味」付費。
- Freshily／GutLog 的**local-first 隱私定位**：洗髮歷史留在手機，不需要帳號。
- AI 工具的**按次計費／高級功能**：成本隨請求發生，就讓收入也隨請求發生。
- Lifetime／一次性包降低第一次付款阻力。

不要複製：

- 用通知內疚使用者、製造虛假急迫感。PicPet 商店評論已出現對通知壓力與頻率的抱怨；這也會直接破壞「不評判你的洗頭 App」定位。
- 為了成長過早加入社交 feed、聊天、UGC、loot box 或地點。這些不是小功能，而是另一套內容安全與營運系統。
- 出售照片、行為資料或廣告識別碼。本產品可用「不賣資料、不投放行為廣告」形成明確差異。

---

## 2. 建議的收入設計

### 2.1 v1.0：明日送審版

**Free**

- 今日洗／不洗、歷史日曆、提醒。
- 基本大頭編輯器與 1–2 組風格。
- 所有紀錄只存本機；不強迫登入。

**創始人個性包（非消耗型 IAP，先測 NT$90 或 NT$120）**

- 6–10 個原創髮型／臉部元件。
- 3 個背景、3 個另類 App Icon。
- 一組更髒、更荒謬的台詞／音效。
- 一次付款永久解鎖，支援 Restore Purchases。

不要把「允許通知」「相機」「相簿」本身當商品；Apple 明確禁止 monetizing built-in capabilities。[App Review Guidelines §4.10](https://developer.apple.com/app-store/review/guidelines/)

### 2.2 v1.1：AI 照片生成

建議先測：

- 1 次免費低解析預覽，或只提供內建示例，不把免費額度開到可被濫用。
- 3 次 `NT$90–120`；成功產出才扣點，技術失敗／供應商失敗自動退點。
- 不要做無限生成。OpenAI 的成本、速率限制和內容審核都不支持「unlimited」承諾。
- App 內數位功能與點數必須用 IAP。[App Review Guidelines §3.1.1](https://developer.apple.com/app-store/review/guidelines/)

成本核算先用這個門檻：

```text
每包可用收入 = 售價 × (1 - Apple commission) - 稅務／退款緩衝
每包變動成本 = 平均成功生成成本 + 平均重試成本 + 儲存／函式／客服成本
上線門檻：每包變動成本 ≤ 可用收入的 20–25%
```

符合資格且加入 Apple Small Business Program 的開發者，paid apps／IAP commission 可降至 15%；需自行申請與確認資格。[Apple Small Business Program](https://developer.apple.com/app-store/small-business-program/)

OpenAI 現行 `gpt-image-2` 依影像 input／output tokens 計費，實際一張圖成本受尺寸、品質、輸入照片與輸出影像影響，不能只抄一個「每張固定成本」。先用 100 個代表性任務做實測再定價。[OpenAI Pricing](https://developers.openai.com/api/docs/pricing)、[gpt-image-2](https://developers.openai.com/api/docs/models/gpt-image-2)

### 2.3 訂閱何時才成立

至少有以下三項再推出年訂閱，建議先年費 `NT$590` 做 A/B 驗證：

- 每月固定原創角色素材。
- 每月固定 AI 點數，未使用額度規則清楚。
- 跨裝置備份／匯出或其他持續服務。

若只是把現有按鈕關起來，這不是 recurring value，只是 recurring resentment。

---

## 3. 目前程式到底安全嗎？

### 3.1 Repository 實證盤點

本次檢查 tracked files 與 Git history；未在目前工作樹或提交歷史找到 OpenAI key pattern。這是範圍內掃描結果，不是對所有開發者電腦、CI secret 或已刪除遠端物件的絕對保證。

| 項目 | 現況 | 判定 |
|---|---|---|
| OpenAI／其他網路 API | 沒有 `URLSession`、OpenAI SDK 或 API Key | 現在無 key 可偷；AI 也尚未存在 |
| 照片／相機 | 沒有 PhotosPicker／相簿上傳 | 現在沒有照片雲端外洩面 |
| 後端／登入 | 沒有 backend、Firebase、CloudKit、帳號 | 現在沒有服務端 DoS 面；也無法安全做 AI／雲端 |
| 本機資料 | 洗頭歷史、設定與外觀放在 `@AppStorage`／`UserDefaults` | 低敏生活紀錄尚可；不可放 token、API Key、照片授權或 server entitlement |
| 通知 | 鎖定畫面 body 直接顯示洗頭提問 | Confidentiality 中風險：旁人可能看見生活習慣 |
| 付款 | 沒有 StoreKit／商品／購買還原 | 不能盈利，也是 launch blocker |
| 隱私合規 | 沒有 App 內 Privacy Policy／Terms | App Store blocker |
| 測試 | 未發現 test target／自動測試 | Integrity／可靠性中風險 |
| CI | 整個 workflow 有 `contents: write`，並用可移動 tag 的 checkout action | 權限過寬與 supply-chain 中風險；build job 應只讀，寫回 screenshot 的 job 應隔離 |

對應程式證據：`WashHead/ContentView.swift:8–23`、`WashHead/SystemFeatures.swift:111–113`、`.github/workflows/ios-build.yml:8–19`、`WashHead.xcodeproj/project.pbxproj:289–327`。

### 3.2 CIA 判定

NIST 將 CIA 定義為：Confidentiality 是只讓獲授權者存取並保護隱私；Integrity 是防止不當修改／破壞並維持真實性；Availability 是可靠、及時可用。[NIST CIA definitions](https://www.nccoe.nist.gov/publication/1800-26/VolA/index.html)

| 面向 | 要保護什麼 | 目前 v0 | 若直接把照片＋Key 加進 App | 可接受生產設計 |
|---|---|---:|---:|---|
| **C — 機密性** | 照片、洗頭紀錄、身份、API Key、私人下載 URL | **中**：本機資料＋通知外露 | **Critical**：Key 可被取出，照片可能被 IDOR／URL／log 洩漏 | Key 只在後端 Secret Manager；私人 bucket；逐物件授權；短效 URL；不記錄照片；EXIF 移除；明確 consent／retention／delete |
| **I — 完整性** | 付費 entitlement、AI 點數、工作狀態、紀錄 | **中**：UserDefaults 可被修改；現在尚無錢損 | **Critical**：客戶端自行說「我已付費」會被偽造、重放或重複扣點 | Server-side 驗證 StoreKit signed transaction；transaction／job idempotency；server authoritative ledger；可稽核但不含照片的事件紀錄 |
| **A — 可用性** | API、生成排隊、成本預算、使用者可讀自己的資料 | **高（本機）** | **Critical**：bot／同機多開／同時請求可打滿 rate limit 或花光額度 | App Attest＋登入；per-user/device/IP/global quota；queue＋concurrency cap；timeout／circuit breaker；hard spend limit；kill switch；local core 永遠可用 |

台灣個資法也要求蒐集與目的相稱，非公務機關需有特定目的與合法基礎，並採適當安全措施防止個資被竊取、竄改、毀損、滅失或洩漏；當事人具有查詢、更正、停止利用與刪除等權利。[個人資料保護法（英文官方頁）](https://theme.ndc.gov.tw/lawout/EngLawContent.aspx?id=89)

產品應維持「生活紀錄／角色生成」定位，不宣稱診斷頭皮或健康狀況；一旦處理醫療／健康資料，法規與使用者合理期待都會變嚴格。

---

## 4. Threat Model：誰會怎麼打

### 4.1 系統邊界

```text
[iOS App：不可信任]
  ├─ 本機洗頭紀錄（預設不離機）
  ├─ StoreKit 2 ──> Apple
  └─ 照片生成請求
       ↓ TLS
[API Gateway / Callable Function]
  ├─ Auth + App Attest/App Check
  ├─ entitlement + credit ledger + idempotency
  ├─ per-user/device/IP/global limits
  └─ private object storage + job metadata
       ↓ queue / bounded concurrency
[AI Worker：OpenAI key 只在 Secret Manager]
       ↓
[OpenAI image/moderation API]
```

信任原則：**iOS 客戶端傳來的 user id、付費狀態、剩餘點數、檔案型別與工作完成狀態全部都不可信。** Server 每次重新驗證。

### 4.2 STRIDE＋CIA 風險表

| 威脅 | CIA | 風險 | 典型攻擊 | 必要控制 |
|---|---|---:|---|---|
| 假 App／腳本直接打 API（Spoofing） | A/I | High | 從模擬器、改版 IPA 或 curl 大量呼叫 | Auth、App Attest assertion、nonce／challenge、防 replay；App Attest 只做一層，不取代 quota |
| 竄改 premium／點數（Tampering） | I/$ | Critical | 修改 UserDefaults、偽造 client response、同 transaction 重放 | App Store signed transaction 由 server 驗證；server ledger；transaction id 唯一索引；工作 idempotency key |
| 否認曾花點／重複收費（Repudiation） | I | Medium | 使用者與 server 對 job 結果不同步 | append-only transaction/job audit；狀態機；不在 log 放照片／prompt 原文 |
| 把 API Key 寫進 IPA（Disclosure） | C/$ | Critical | 反編譯、runtime hook、proxy 找出 key | App 不含 key；server Secret Manager；dev/prod 分 key；最小權限；用量 alert、hard budget、可立即 revoke/rotate |
| IDOR/BOLA 偷別人的照片（Disclosure） | C | Critical | 把 `/users/A/photo` 改成 `/users/B/photo` | 每一次 object read/write/delete 都由 server 檢查 owner；private-by-default rules；不可列目錄；不可猜 ID；negative authorization tests。[OWASP API1](https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/) |
| 長效 signed URL、log 或 EXIF 洩漏（Disclosure） | C | High | URL 被轉傳／分析平台收集；GPS metadata 留在照片 | 短效 one-time URL 或 auth proxy；URL/token 全部 redact；upload 後 strip EXIF；analytics 不收 raw image/path |
| Cost exhaustion／並發 DoS（Denial of Service） | A/$ | Critical | 免費帳號農場、平行生成、oversized files、重試風暴 | 每人每日／每分鐘、每 device／IP、全域上限；IAP 點數前置；queue；concurrency cap；檔案／像素上限；重試上限；spend kill switch。[OWASP API4](https://owasp.org/API-Security/editions/2023/en/0xa4-unrestricted-resource-consumption/) |
| 圖片 decompression bomb／假 MIME | A | High | 小壓縮檔解開成超大 bitmap，或非圖片偽裝 | 驗 magic bytes；限制 bytes、pixels、dimensions；在隔離環境安全 decode／re-encode；超時即丟棄 |
| 供應商故障／rate limit | A/I | High | OpenAI timeout、429、部分成功 | async queue；指數退避＋jitter；不重複扣點；可取消；狀態頁；local core 降級可用 |
| 惡意／違法內容 | C/法律 | High | 上傳他人、未成年人或 CSAM 影像 | 每張明確 consent；使用條款／年齡門檻；image moderation；人工接觸最小化；incident escalation；v1 不做社交分享 |
| 管理員／客服內鬼 | C/I | High | 後台瀏覽私人照片、改點數 | RBAC、MFA、break-glass、完整 audit、support UI 預設看不到照片、定期 access review |
| CI／依賴供應鏈 | C/I | High | action tag 被換、過寬 GitHub token、build secret 外洩 | action pin 到 commit SHA；build `contents: read`；寫回 job 隔離；environment protection；不讓 PR 取得 prod secret |
| 手機被偷／肩窺通知 | C | Medium | 解鎖裝置或鎖屏通知看到紀錄 | session token 放 Keychain；敏感頁可選 Face ID；通知預設用中性文字；本機 Data Protection |
| 刪除不完整 | C/合規 | High | 原圖已刪但 thumbnail、log、backup 還在 | retention inventory；Storage lifecycle；刪除工作遍歷 derived assets；完成狀態與失敗重試；文件揭露 vendor retention |

Apple 的 App Attest 能讓 server 驗證請求來自正版 App instance，並用 challenge/assertion 降低 replay；但它不是使用者身份、付款驗證或流量限制的替代品。[Apple App Attest](https://developer.apple.com/documentation/devicecheck/validating-apps-that-connect-to-your-server)

---

## 5. 建議的最小安全後端

為了速度，v1.1 可用 Firebase 管理式元件；這不是唯一解，但少掉大量自架維運：

1. **Auth**：只有使用雲端／AI 才建立匿名帳號或 Sign in with Apple；純本機核心不登入。若建立帳號，App 內必須能刪除帳號。[Apple App Review Guidelines §5.1.1](https://developer.apple.com/app-store/review/guidelines/)
2. **App Check + App Attest**：只讓經 attestation 的 App 呼叫 Functions／Storage；正式 enforce 前先觀察合法流量。[Firebase App Check for App Attest](https://firebase.google.com/docs/app-check/ios/app-attest-provider)
3. **Private Cloud Storage**：路徑含 server-derived UID，Rules 驗 `request.auth.uid`，不接受 client 提供 owner。[Firebase Storage Rules](https://firebase.google.com/docs/storage/security/rules-conditions)
4. **Callable Function / API**：驗 Auth、App Check、entitlement、quota、idempotency 與檔案 metadata。
5. **Cloud Tasks**：把 AI 工作排隊，設定 max concurrent dispatches、rate、retry；客戶端輪詢工作狀態或接通知。[Firebase Task Queue Functions](https://firebase.google.com/docs/functions/task-functions)
6. **Secret Manager**：OpenAI key 只 bind 給 worker function，不給其他 function／CI／App。[Firebase secret parameters](https://firebase.google.com/docs/functions/config-env)
7. **OpenAI**：使用 project-specific key、project rate limit／spend limit、影像 moderation；傳 `safety_identifier` 為不可逆雜湊的內部 user id，不傳 email／姓名。[OpenAI Moderation](https://developers.openai.com/api/docs/models/omni-moderation-latest)、[Responses safety_identifier](https://developers.openai.com/api/reference/cli/resources/responses/methods/create)

### 照片資料生命週期

建議明寫在 consent sheet：

```text
使用者選一張照片（系統 PhotosPicker）
→ App 端 crop / resize；server 再驗證並 re-encode、移除 EXIF
→ 原圖進私人暫存區，預設 24 小時自動刪除
→ AI 生成結果只給 owner，看完可立即刪除
→ 若使用者選「存到角色」，只保留必要的生成結果，不保留原始自拍
→ 刪除帳號：原圖、結果、縮圖、job metadata 與衍生物進刪除佇列
```

Apple 建議只需要單張照片時使用 out-of-process picker，不要要求完整相簿權限；向第三方 AI 分享個資前必須明確揭露分享對象並取得明確同意。[App Review Guidelines §5.1.1](https://developer.apple.com/app-store/review/guidelines/)

App Store privacy label 的「collect」有其技術定義，且必須納入第三方 partner；請依真實 retention 與傳輸填寫，不要用「只是即時處理」作模糊話術。[Apple App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)

---

## 6. 會卡住的地方，以及解法

| 瓶頸／挑戰 | 為什麼會卡 | 解法與驗收標準 |
|---|---|---|
| App Store 帳號、合約、銀行／稅務、IAP review | 不是程式寫完就能收錢 | 今天先確認 Paid Apps Agreement、銀行／稅務與商品狀態；v1 只上一個 IAP；review notes 附購買路徑 |
| Mac、Xcode、簽章、實機 | 目前環境是 Windows；iOS archive／upload 和真機互動 QA 仍需要 macOS/Xcode | 今天取得自己的 Mac 或合規 remote Mac；登入 Apple 帳號；真機測通知、icon、dark/light、購買／還原、kill/reopen |
| 審查時間不可控 | 平均 24 小時不等於保證 | 把「明天」定義成送審＋internal TestFlight 可用；不要承諾公開商店營收日期 |
| 目前沒有 StoreKit | 沒有可賣商品，且 premium state 不可只存 UserDefaults | StoreKit 2；商品載入、購買、pending/cancelled、restore、refund/revocation 都要測；entitlement 由 verified transaction 得出 |
| AI 成本與產出不穩 | 重試、尺寸、品質與照片不同會改變成本；失敗圖會傷轉換 | 固定 crop／尺寸／prompt；100 次基準測試；記錄 token/cost/latency/成功率但不記錄照片；失敗退點 |
| OpenAI 初期吞吐 | `gpt-image-2` 初始 tier 的 images/min 限制可能很低 | 所有生成非同步排隊；UI 顯示順位／狀態；global concurrency 對齊實際 tier；絕不讓每台手機直接打 OpenAI。[模型 rate limits](https://developers.openai.com/api/docs/models/gpt-image-2) |
| 隱私信任 | 自拍比洗頭 checkbox 敏感得多 | v1 無照片；v1.1 每張 opt-in、清楚列 OpenAI、保留時間、刪除鍵、無廣告／不賣資料；通知可切私密文案 |
| 刪除與備份 | 「刪資料」常漏掉 thumbnail、log、queue、backup | 建 data inventory；TTL lifecycle；定期做刪除演練；每個衍生物有 owner 與 parent job id |
| 濫用與退款 | 免費額度會被農，網路失敗會造成「扣錢沒圖」 | App Attest＋quota＋點數；idempotency；只有 terminal success 扣點；自動退點；客服查得到 job id |
| 內容審核 | 社交分享讓所有私人生成物變成平台責任 | v1/v1.1 都不做公開 UGC；若未來要做，另開完整 moderation、report/block、客服 SLA 專案 |
| 留存不足 | 洗頭是一個窄、低頻問題 | 把回訪變成「角色狀態／荒謬台詞／收藏」，不要用羞辱或通知轟炸；用 D1/D7 retention 與 reminder opt-out 率決定是否值得訂閱 |

---

## 7. 明天的 3 小時衝刺表

前提：Apple Developer、App Store Connect 的 agreements／banking／tax 已可用，而且今天拿得到 Mac 與一台 iPhone。任何一項不成立，就把目標降成「可測 build＋完整送審資料」。

### 00:00–00:30 — 凍結範圍

- v1.0 明確標記：**不收照片、不接 OpenAI、不建帳號**。
- 只選一個 IAP：「創始人個性包」。
- 寫一句產品承諾：`洗頭紀錄留在你的 iPhone；我們不賣你的資料。`
- 刪掉所有暗示健康診斷或 AI 已可用的 metadata。

**產出：一頁 scope、商品名稱、價格與 6–10 個確定交付的素材。**

### 00:30–01:00 — 合規骨架

- 發佈 Privacy Policy、Terms、Support URL，App 內 Settings 可點。
- Privacy Policy 寫明目前資料只在裝置、本機通知、未來功能不提前宣稱。
- App Store privacy answers 依實際 build 填；不要填未來藍圖。

**產出：三個可公開 URL＋完成的 privacy questionnaire。**

### 01:00–01:30 — 付款最小閉環

- App Store Connect 建一個 non-consumable。
- StoreKit 2 接商品、購買、還原與 verified entitlement。
- 產品未載入時保持 free core 可用，不白屏。

**產出：Sandbox 購買＋restore 的螢幕錄影。**

### 01:30–02:00 — 實機破壞測試

- 新裝、升級、kill/reopen、離線、拒絕通知、時區／跨午夜。
- 購買成功、取消、pending、第二台裝置 restore。
- 通知文案加「隱私模式」，避免鎖屏直接說洗頭。

**產出：逐項 PASS/FAIL；有 crash 或購買錯帳就停止送審。**

### 02:00–02:30 — 商店頁

- 截圖、subtitle、description、關鍵字、review notes、support contact。
- 說清免費與付費內容；不要把 TestFlight 當付費商品。
- review account 不需要，因 v1 不登入。

**產出：App Store Connect 無 missing metadata。**

### 02:30–03:00 — Archive、上傳、送審

- Release archive、validate、upload。
- internal TestFlight smoke test。
- IAP 跟 App version 一起送審，review notes 指出入口。

**產出：Processing 完成的 build＋submission id。**

---

## 8. 上線 Gate：沒過就不要收照片

### v1.0 收費 Gate

- [ ] 實機完成核心流程、kill/reopen、通知與跨日測試
- [ ] StoreKit sandbox：成功／取消／pending／restore／revocation
- [ ] Privacy／Terms／Support URL 皆可公開讀取，App 內也可進入
- [ ] 沒有 API Key、token、certificate 進 source、IPA 或 log
- [ ] GitHub build job 改為 `contents: read`；需要寫回的 automation 分離
- [ ] 使用者名稱不再 hardcode `Hank`
- [ ] Release build crash-free smoke test

### v1.1 照片／AI Gate

- [ ] App 內完全沒有 OpenAI key；直接網路反編譯測試也找不到
- [ ] Auth＋App Attest／App Check 已 enforce，並有合法裝置 fallback 策略
- [ ] BOLA negative tests：A 永遠讀不到／刪不到 B 的 object
- [ ] per-user、device/IP、global quota＋queue＋hard spend limit＋kill switch
- [ ] upload bytes／pixels／dimension／magic-byte／decode timeout 限制
- [ ] server-side StoreKit verification、idempotency 與點數 ledger
- [ ] 原照 TTL、刪除帳號、衍生圖刪除、失敗重試均已演練
- [ ] consent 明列「傳給 OpenAI」、用途、retention、刪除與 vendor limitation
- [ ] log／analytics／crash reporting 不含 raw image、signed URL 或 prompt 內個資
- [ ] 100 次成本／延遲／失敗率 benchmark 通過 20–25% COGS 門檻
- [ ] OpenAI outage、429、timeout、partial success 全部不重複扣點

**最終 Go / No-Go：目前 v0 可以繼續作為本機原型；v1.0 收費尚未過 Gate；照片／AI v1.1 目前是 No-Go。**

---

## 9. 決策清單

今天直接採用：

- [x] 不賣資料、不放廣告。
- [x] v1.0 免費核心＋一次性原創個性包。
- [x] v1.0 不收照片、不碰 OpenAI。
- [x] AI 改成 server-mediated、按次點數、排隊、成功才扣點。
- [x] 本機紀錄不強迫登入；只有使用雲端功能才建立帳號。
- [x] 明天目標是「送審／beta ready」，不虛假保證「公開上架並盈利」。

需要產品負責人之後決定：

- [ ] 創始人包先測 `NT$90` 還是 `NT$120`。
- [ ] AI 原始照片 TTL 採 1 小時還是 24 小時；原則是越短越好，但必須支援可靠重試。
- [ ] v1.1 用 Firebase managed stack，或另選 Cloudflare／AWS；安全要求不因供應商而降低。

