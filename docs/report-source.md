# Research source ledger — 2026-09-04

本檔是 `LAUNCH_MONETIZATION_SECURITY_REPORT.md` 的研究工作底稿。範圍：台灣優先的 iOS 消費型 App 商業化、App Store 規則、照片／生成式 AI 資料流、CIA／STRIDE／OWASP threat model。價格與排名是商店頁在研究日顯示的快照，會隨地區與時間改變；法律段落為工程風險整理，不替代台灣律師意見。

## Source hierarchy

1. 規則／技術／法規：Apple、OpenAI、NIST、OWASP、Firebase、台灣國發會法規頁等 primary sources。
2. 競品：Apple App Store listing 與產品官方 help。
3. 使用者反應：App Store reviews；只作質性訊號，不當因果證明。

## Claim ledger

| 主題 | 關鍵主張 | 來源 | 信心／限制 |
|---|---|---|---|
| Apple IAP | App 內解鎖數位功能／點數須用 IAP；訂閱要有持續價值；不可販售通知／相機等系統能力 | https://developer.apple.com/app-store/review/guidelines/ | 高；官方現行規則 |
| TestFlight | beta 不可用任何形式收費；external testing 可能需 beta review | https://developer.apple.com/app-store/review/guidelines/ ; https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview ; https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers | 高 |
| Review timing | Apple 稱 90% submissions 平均少於 24h；非 SLA，批准後商店傳播可再花時間 | https://developer.apple.com/app-store/review/ | 高；不可解讀為保證 |
| Privacy | policy metadata 與 App 內皆要有；第三方 AI 分享須揭露與明確同意；能用 picker 就不要完整 Photos access；有 account creation 就要 in-app deletion | https://developer.apple.com/app-store/review/guidelines/ | 高 |
| App privacy label | 第三方 partner 也要申報；collect 有 off-device＋retention 定義 | https://developer.apple.com/app-store/app-privacy-details/ | 高；標籤不等於完整資料流保證 |
| Apple commission | 合資格 Small Business Program commission 15% | https://developer.apple.com/app-store/small-business-program/ | 高；需申請與確認資格 |
| PicPet | 免費社交養寵物；訂閱＋coins＋道具；台灣價格和 feature gates | https://apps.apple.com/tw/app/picpet/id6742077014 ; https://apps.apple.com/us/app/picpet/id6742077014 | 高於商店資訊；評論僅質性 |
| Freshily | hair wash tracker；Premium annual/lifetime；無帳號／廣告，local／optional iCloud | https://apps.apple.com/us/app/freshily-smart-hair-wash-day/id6755645431 | 高於商店 self-report |
| iPoop | 免費＋廣告，annual／lifetime IAP | https://apps.apple.com/us/app/poop-tracker-calendar-ipoop/id1671100769 | 高於商店頁；價格可能變動 |
| Happy Poop | 核心免費、廣告、一次性移除廣告、donation；PIN/biometric/disguised icon | https://apps.apple.com/us/app/happy-poop-toilet-journal-log/id1586000388 ; https://casadozeps.com/help/settings-customization.html | 高；官方產品資料 |
| KB Poop AI | local base、AI premium、每張 opt-in；weekly/annual/lifetime prices | https://apps.apple.com/us/app/kb-poop-tracker-ai-stool-scan/id6784489026 | 高於 listing；「Data Not Collected」須依 Apple 定義理解 |
| GutLog | offline/no account base；analytics/PDF/pattern premium；多週期 IAP | https://apps.apple.com/us/app/ibs-poop-tracker-gutlog/id6749550927 | 高於 listing |
| Poop Map | social/location virality，免費＋IAP | https://apps.apple.com/us/app/poop-map-pin-and-track/id1303269455 | 高於 listing；不推論其實際收入 |
| CIA | confidentiality / integrity / availability 定義 | https://www.nccoe.nist.gov/publication/1800-26/VolA/index.html | 高；NIST |
| Mobile hardcoded secret | IPA／client hardcoded key 可被 recover | https://mas.owasp.org/MASWE/MASVS-STORAGE/MASWE-0004/ ; https://mas.owasp.org/MASWE/MASVS-STORAGE/MASWE-0003/ | 高；OWASP |
| BOLA | 任意 object id 缺少逐物件授權可造成 disclosure/modification | https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/ | 高 |
| Resource exhaustion | unrestricted resource use 造成 DoS 與成本放大，需 limits | https://owasp.org/API-Security/editions/2023/en/0xa4-unrestricted-resource-consumption/ | 高 |
| App Attest | server 可驗證正版 App instance，以 challenge/assertion 抗 replay | https://developer.apple.com/documentation/devicecheck/validating-apps-that-connect-to-your-server ; https://developer.apple.com/documentation/DeviceCheck/establishing-your-app-s-integrity | 高；只是一層控制 |
| Firebase App Check | iOS App Attest provider、enforcement、TTL | https://firebase.google.com/docs/app-check/ios/app-attest-provider | 高 |
| Storage authorization | Storage Rules 可驗 auth uid／resource conditions | https://firebase.google.com/docs/storage/security/rules-conditions | 高；具體 rules 仍需測試 |
| Server secrets | Cloud Functions secret parameters／Secret Manager，secret 只 bind needed functions | https://firebase.google.com/docs/functions/config-env | 高 |
| Async queue | task queue 可控 rate／retry | https://firebase.google.com/docs/functions/task-functions | 高 |
| OpenAI retention/training | API data 預設不訓練；abuse logs 通常最多 30 天；image/file CSAM scanning；approved ZDR/MAM 例外 | https://developers.openai.com/api/docs/guides/your-data | 高；依 endpoint 與合約而異 |
| OpenAI pricing | `gpt-image-2` 依 tokens/quality/size；需 empirical benchmark | https://developers.openai.com/api/docs/pricing ; https://developers.openai.com/api/docs/models/gpt-image-2 | 高；價格會變動 |
| Moderation | omni-moderation supports image/text and is free | https://developers.openai.com/api/docs/models/omni-moderation-latest | 高 |
| Safety identifier | 可傳穩定、去識別 user identifier；不傳 PII | https://developers.openai.com/api/reference/cli/resources/responses/methods/create | 高 |
| OpenAI project limits | project key/rate/spend controls exist | https://developers.openai.com/api/reference/resources/admin/subresources/organization/subresources/projects/subresources/api_keys ; https://developers.openai.com/api/reference/python/resources/admin/subresources/organization/subresources/projects/subresources/rate_limits/methods/update_rate_limit | 高；實際可用項目依帳號／API |
| Taiwan PDPA | purpose/minimization, lawful basis, data subject rights, security obligations | https://theme.ndc.gov.tw/lawout/EngLawContent.aspx?id=89 ; https://theme.ndc.gov.tw/lawout/EngLawContent.aspx?id=66&lan=E ; https://theme.ndc.gov.tw/lawout/EngLawContent.aspx?id=67&lan=E | 高於法條摘要；非法律意見 |

## Repository evidence

- `WashHead/ContentView.swift:8–23`: AppStorage persistence.
- `WashHead/ContentView.swift:89,375`: hardcoded `Hank`.
- `WashHead/SystemFeatures.swift:111–113`: visible notification body.
- `.github/workflows/ios-build.yml:8,19`: broad `contents: write`, checkout by tag.
- `WashHead.xcodeproj/project.pbxproj:289–327`: automatic signing, bundle identifier, iOS 17 target; no stored development team observed.
- Tracked-file scan found no `URLSession`, `StoreKit`, `PhotosPicker`, OpenAI SDK/API key, Firebase/CloudKit/backend, privacy/terms screen, auth, or test target.
- Git history pattern scan found no `OPENAI_API_KEY`, common `apiKey`, or `sk-...` match. This is bounded evidence, not proof about CI secrets, developer machines, remote caches, or deleted unreachable objects.

## Gap matrix

| 問題 | 證據是否足夠 | 尚缺什麼 |
|---|---|---|
| 明天能否保證公開營收 | 足夠判定「不能保證」 | Apple account/agreements/banking/tax status、Mac/signing、review outcome |
| 哪個模式最適合 | 足夠提出 first test | 真實 conversion、retention、WTP，需上線實驗 |
| 每次 AI 毛利 | 尚不足以定價 | 100-run benchmark、實際 image settings、retry rate、storage/function/support/refund |
| 現在是否洩漏 OpenAI key | 工作樹／可達歷史未發現 | CI/hosting secret inventory、developer machine、GitHub secret scanning |
| 照片／AI 是否安全 | 足夠判定目前尚未實作，直接 client key 不安全 | 實作後架構、rules、penetration/negative tests、retention audit |
| 法規完全合規 | 不足以做法律保證 | 實際 privacy policy、資料處理者契約、跨境資料流、台灣律師 review |

