# 洗頭了沒 — One-Day iOS Demo Build Brief

你現在要幫我做一個 **一天內必須完成、可以真的在 iPhone / Simulator 上玩的 iOS Demo**。

不要把它當正式 production app。

不要過度架構。

不要為未來預留一堆系統。

不要主動增加功能。

今天唯一的目標是：

> **把核心體驗做出來，讓我可以拿給我媽媽實際玩。**

---

# 0. Product Idea

這是一個幫人記住：

**「我到底有沒有洗頭？」**

的 App。

它不是健康追蹤器。

它不鼓勵使用者洗頭。

它不批判使用者沒洗頭。

它不做 streak。

它不給健康建議。

產品人格是：

> **我要不要洗頭關你屁事，你只要幫我記得。**

---

# 1. Demo Success Criteria

一天結束以前，我必須可以在 iPhone / Simulator 上：

1. 打開 App
2. 看到一顆佔畫面約 80% 的巨大 2D 角色頭
3. 回答今天要不要洗頭
4. 選「要」之後進入一個簡單的澆水／洗頭互動
5. 用手指拖曳蓮蓬頭或澆水器，把角色頭髮淋濕
6. 完成後確認「你真的洗完了嗎？」
7. 選「不要」之後，角色會開心地講一句耍廢的話
8. 每次確認不洗，頭髮會變得更大、更澎
9. 洗頭之後，頭髮恢復正常
10. 關閉 App 再重新打開，狀態仍然存在

只要這些成立，Demo 就成功。

---

# 2. Absolute Priority

請依照以下順序開發：

## P0 — 必須完成

- App 可以跑
- 主畫面巨大角色頭
- 「要洗 / 不洗」選擇
- 不洗 → 頭髮膨脹
- 洗 → 澆水互動
- 洗完確認
- 本地持久化

## P1 — P0 全部完成後才碰

- 「不要再提醒我，我很誠實」
- 簡單角色切換
- 問號狀態
- 小動畫
- 少量 polish

## P2 — 有大量剩餘時間才碰

- Local Notification
- notification actions
- 簡單歷史資料 debug view

P2 不能影響 P0。

---

# 3. Technology

請使用：

- Swift
- SwiftUI
- iOS native
- `@AppStorage` / `UserDefaults` 優先

不要建立 backend。

不要建立帳號系統。

不要 Firebase。

不要 CloudKit。

不要 networking。

不要 external database。

如果沒有必要，不要加入第三方 dependency。

---

# 4. Very Important: Keep Architecture Small

這是一天 Demo。

請優先：

- 少量 Swift files
- 清楚但簡單的 state
- 能跑
- 能改
- 能 debug

不要：

- Clean Architecture
- Repository Pattern
- Dependency Injection framework
- Coordinator framework
- Protocol abstraction everywhere
- 巨大的 ViewModel hierarchy
- 為未來功能建立空殼
- Backend API abstraction
- production-grade analytics architecture

如果某件事可以用 20 行 SwiftUI 解決，就不要做成 7 個 types。

---

# 5. Main Screen

主畫面必須非常極簡。

## Layout

大約：

**80% 螢幕 = 一顆超大的角色頭**

其他 UI 退到次要位置。

不要 dashboard。

不要 cards everywhere。

不要 progress charts。

不要健康資訊。

畫面主要應該讓人第一眼覺得：

> 「幹，怎麼有一顆這麼大的頭。」

---

# 6. Character

Demo 是 **2D**。

不要 3D。

不要 SceneKit。

不要 RealityKit。

不要 Unity。

不要 Blender pipeline。

角色可以使用 layered images，或者如果更快：

**直接使用不同狀態的完整角色圖片。**

Demo 不需要漂亮 architecture。

---

# 7. Character Assets / Fallback

如果目前 repo 沒有正式美術素材：

請不要卡住。

可以先使用：

- SwiftUI Shapes
- SF Symbols
- 簡單 placeholder 角色
- 圓形臉
- 簡單眼睛
- 簡單嘴巴
- 程式畫出的頭髮形狀

最重要的是互動可以測試。

程式結構要讓我之後容易把 placeholder 換成 PNG / SVG。

不要因為沒有美術而停止開發。

---

# 8. Hair States

不要模擬油脂。

不要模擬真實頭髮。

只需要用「頭髮體積」表示連續沒洗。

請至少有：

```text
clean
puffy1
puffy2
puffy3
wet
unknown
```

## clean

正常頭髮。

## puffy1

一次沒洗。

頭髮比正常稍微大。

## puffy2

更大、更澎。

## puffy3

爆炸澎。

可以非常誇張。

最終甚至可以：

- 快佔滿螢幕
- 遮住部分臉
- 只露出眼睛

重點是好笑。

不要做噁心的：

- 油滴
- 蒼蠅
- 綠色臭氣
- 衛生警告

---

# 9. Main Question

主畫面角色問：

> **「欸 Hank，我們今天有要洗頭嗎？」**

Demo 可以先把 `Hank` hardcode。

之後再改成使用者名字。

按鈕：

**要啊**

**今天不要**

文字可以微調，但人格必須自然、不像健康 App。

---

# 10. Flow — User Chooses Not To Wash

使用者按：

**今天不要**

立即：

1. 今日狀態 = `notWashed`
2. `messinessLevel += 1`
3. 最大值 clamp 到最高級
4. 儲存資料
5. 頭髮切換到下一個更澎狀態
6. 顯示角色台詞

第一版台詞：

> **「噢耶，賺到一點時間，我可以躺床上看平板。」**

不要出現：

- 可惜
- 失敗
- 明天要記得
- 已經 X 天沒洗
- 健康提醒

不洗頭也必須是一個有趣、完整的結果。

---

# 11. Flow — User Chooses To Wash

使用者按：

**要啊**

不要立刻紀錄成 washed。

進入：

# Wash Interaction Screen

畫面：

- 巨大角色頭
- 可拖曳的蓮蓬頭／澆水器
- 水流簡單 visual effect

使用者用手指拖曳蓮蓬頭。

---

# 12. Watering Interaction

不要做真正 fluid physics。

不要做 particle simulation 到影響進度。

實作越簡單越好。

例如：

當拖曳中的 shower position 進入 hair hit area 時：

```text
wetProgress += ...
```

或依拖曳停留時間增加。

進度達到門檻後：

```text
wetProgress >= 1.0
```

顯示洗完確認。

UI 不一定要顯示百分比。

最好讓使用者只感覺：

「我把頭淋濕了。」

而不是：

「我完成了 73% progress bar。」

---

# 13. Wet Visual

最簡單即可。

例如：

- wetProgress 增加時，頭髮逐漸縮小
- 頭髮變貼
- 顯示透明水滴
- 或 clean/wet image crossfade

不要做真實 wet shader。

---

# 14. Confirmation After Washing Game

完成澆水互動後：

Modal / Sheet / Alert：

> **「你真的洗完了嗎？」**

選項：

### 洗完了！

結果：

```text
lastStatus = washed
messinessLevel = 0
```

儲存。

角色頭髮變 wet / clean。

---

### 其實還沒

不要記錄 washed。

回到主畫面。

原本 messiness level 保留。

---

# 15. Trust User Option

確認視窗中加入：

> ☐ **不要再提醒我，我很誠實**

如果使用者勾選：

```text
trustUser = true
```

保存。

之後每次完成澆水互動：

直接：

```text
lastStatus = washed
messinessLevel = 0
```

不用再顯示確認。

第一次開啟這個選項後，可以讓角色說：

> **「行，我信你。」**

如果 checkbox 在 SwiftUI Alert 裡不好做，不要浪費時間硬塞 Alert。

可以使用自製 modal / sheet。

P0 已完成前，這個功能是 P1。

---

# 16. Persistence

最低需要保存：

```swift
messinessLevel
lastStatus
lastStatusDate
trustUser
```

如果角色有 preset：

```swift
characterPreset
```

可以使用：

```swift
@AppStorage
```

或 UserDefaults。

關掉 App、kill App、重新打開：

頭髮狀態必須還在。

---

# 17. Date Logic

Demo 不需要完整 scheduling engine。

重要規則：

**跨日不會自動把頭髮恢復 clean。**

如果昨天沒洗：

今天打開仍然是澎頭。

如果昨天洗了：

今天打開仍然是 clean。

「今天還沒有回答」不等於 unknown。

---

# 18. Unknown State

這是 P1。

正式產品邏輯：

使用者平常睡覺時間前 10 分鐘，如果今天仍完全沒有紀錄：

→ `unknown`

→ 顯示問號頭。

但 Demo 不需要真的等待時間。

可以加一個只供 Debug / Demo 的：

**「模擬睡前 10 分鐘」**

按下後：

如果今天沒有回答：

切到 unknown。

這比現在建立完整 scheduler 更重要。

---

# 19. Notification

這是 P2。

不要一開始做。

如果 P0 完成而且 App 穩定，再做一個 local notification：

> **「欸 Hank，我們今天有要洗頭嗎？」**

理想 action：

- 要啊
- 今天不要

但如果 notification actions 會吃掉太多時間：

只做：

tap notification → open app

就好。

Notification 不可以成為 Demo blocker。

---

# 20. Character Creator

今天不要做完整捏臉。

正式版本未來會有：

- 臉型
- 眼睛
- 眉毛
- 鼻子
- 嘴巴
- 頭髮
- 顏色
- 部分五官 X/Y/size 調整

**但這些今天全部不是核心。**

Demo：

如果非常快，可以做 2–3 個 preset 頭。

例如：

```text
Character A
Character B
Character C
```

讓使用者點一個。

如果需要超過很短時間：

直接只用一顆預設頭。

不要因此拖延核心玩法。

---

# 21. History

今天不做正式歷史 UI。

不做：

- Calendar
- Charts
- Streak
- Statistics

如果 debugging 需要，可以保存少量資料或顯示 debug text。

正式產品之後才做。

---

# 22. App Icon

正式產品最終希望：

**App icon 就是使用者自己的角色頭，而且會依頭髮狀態改變。**

但今天：

**不要實作 dynamic app icon system。**

Demo 使用固定角色頭 icon 即可。

這是未來功能。

---

# 23. Ads

今天完全不要加入廣告。

不要加入任何 ad SDK。

商業模式之後再討論。

---

# 24. Things You Are Explicitly Forbidden To Build Today

不要碰：

- 3D
- SceneKit
- RealityKit
- Unity
- Blender
- Metal
- 真實水 physics
- 真實 hair physics
- shader-heavy system
- 完整 avatar editor
- 完整 calendar
- streak
- achievements
- social
- friends
- leaderboard
- health data
- HealthKit
- AI
- chatbot
- backend
- Firebase
- CloudKit
- account system
- authentication
- Sign in with Apple
- ads
- analytics SDK
- subscriptions
- complex notification scheduler
- architecture for hypothetical future Android app

如果你準備開始做其中任何一項：

**STOP。**

回去完成 P0。

---

# 25. UX Personality

整個 App 不准像健康工具。

不要：

> 今日洗頭任務

不要：

> 你已連續三天沒有完成洗頭目標

不要：

> 維持良好衛生習慣！

要像一個跟使用者一起耍廢的角色。

例如：

> 「欸 Hank，我們今天有要洗頭嗎？」

> 「噢耶，賺到一點時間。」

> 「行，我信你。」

> 「蛤，我不知道我們到底有沒有洗。」

語氣要：

- 很 casual
- 有點白痴
- 可愛
- 不 judgmental
- 不過度話多

---

# 26. Visual Direction

非常極簡。

優先級：

1. 巨大的頭
2. 頭髮變化很明顯
3. 按鈕很好按
4. 澆水互動立即看得懂

不要花時間：

- 裝飾背景
- fancy navigation
- glassmorphism
- dashboard
- card system
- gradients everywhere

如果不知道怎麼設計：

**白／單色背景 + 超大頭 + 兩顆按鈕。**

---

# 27. Suggested Basic State Model

可以保持非常小，例如：

```swift
enum WashStatus: String {
    case none
    case washed
    case notWashed
    case unknown
}
```

以及：

```swift
messinessLevel: Int // 0...3
trustUser: Bool
lastStatusDate: Date?
```

不要因為這個 spec 建立一個複雜 domain layer。

---

# 28. Suggested Screen Structure

保持少量 screens：

```text
ContentView
    ↓
MainHeadView

WashInteractionView

WashConfirmationSheet
```

如果需要：

```text
SimpleCharacterPickerView
```

即可。

檔案怎麼拆可以自行判斷，但不要過度拆分。

---

# 29. Development Strategy

請先查看現有 repo。

理解目前：

- project structure
- deployment target
- 是否已有 SwiftUI App
- 是否已有 assets
- 是否已有可利用的 code

然後：

**在現有基礎上直接實作。**

不要因為你想要更漂亮的架構就重建整個專案。

如果現有程式能用，就沿用。

---

# 30. Build Continuously

每完成一個主要功能，就確認 App 還能 build。

不要一次改一大堆最後才 compile。

優先順序：

### Step 1

讓 App 顯示巨大頭。

### Step 2

加入「要啊 / 今天不要」。

### Step 3

完成不洗 → 頭髮膨脹 → persistence。

### Step 4

完成 wash interaction。

### Step 5

完成洗完確認。

### Step 6

確認重開 App 狀態存在。

到這裡：

**Demo 已經成功。**

再處理 P1。

---

# 31. Definition of Done

只有以下流程全部可以實際操作，才算 Done：

## Test A — Don't Wash

Fresh install / reset state

→ 看到 clean head

→ 按「今天不要」

→ 角色講：

「噢耶，賺到一點時間，我可以躺床上看平板。」

→ 頭髮變大

→ 再次不洗

→ 頭更大

→ 再次不洗

→ 頭髮爆炸澎

→ kill app

→ reopen

→ 還是爆炸澎

PASS

---

## Test B — Wash

從爆炸澎開始

→ 按「要啊」

→ 進入洗頭畫面

→ 拖曳蓮蓬頭

→ 頭髮逐漸濕

→ 完成

→ 問：

「你真的洗完了嗎？」

→ 選「洗完了！」

→ 頭髮 reset

→ kill app

→ reopen

→ 仍然是 clean

PASS

---

## Test C — Fake Wash

→ 按「要啊」

→ 玩完澆水

→ 選「其實還沒」

→ 不可以把狀態改成 washed

PASS

---

# 32. Final Rule

每當你想加一個 spec 沒要求的功能，先問自己：

> **「沒有它，我今天還能不能讓媽媽玩這個 Demo？」**

如果答案是：

**可以。**

那就不要做。

今天不是在蓋產品。

今天是在驗證：

> **「一顆會因為你洗不洗頭而變化的巨大頭，到底好不好玩？」**

Build that first.
