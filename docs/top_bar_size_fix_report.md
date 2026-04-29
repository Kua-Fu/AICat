# TopBar 尺寸优化报告

## 改动摘要

- 调整运行时窗口与拉伸策略，避免桌面默认全屏导致竖屏 UI 被横向放大。
- 将 TopBar 尺寸、间距、图标、字体常量集中管理，去除分散魔法数字。
- 为主页面增加居中与最大内容宽度约束，宽屏下保持 750 设计稿视觉密度。
- 保留 750x1334 设计基准，不修改业务逻辑与存档逻辑。

## 修改文件

- `project.godot`
- `scripts/ui/top_bar.gd`
- `scripts/main_scene.gd`

## 关键实现

1. `project.godot`
- `window/size/mode` 从 `3` 改为 `0`（窗口模式）。
- `window/stretch/aspect` 从 `keep_width` 改为 `keep`。
- 保持 `viewport_width=750` 与 `viewport_height=1334` 不变。

2. `scripts/ui/top_bar.gd`
- 新增并使用统一常量：`BAR_HEIGHT`、`HOME_ICON_SIZE`、`LEVEL_PILL_SIZE`、`COIN_PILL_SIZE`、`TIME_MIN_WIDTH` 等。
- TopBar 高度调整为 `100`，内部 margin 调整为 `8`（上下）与 `18`（左右）。
- `cat_name_label` 启用截断：
  - `clip_text = true`
  - `text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS`
- 保证左侧名称区扩展、时间区收缩居中、右侧资源区收缩靠右，避免猫名挤压等级与金币胶囊。

3. `scripts/main_scene.gd`
- 新增常量：
  - `DESIGN_WIDTH = 750`
  - `PAGE_MARGIN_X = 18`
  - `MAX_PAGE_WIDTH = 714`
- `UI` 内新增 `CenterContainer` 包裹 `Page`。
- `Page` 使用 `SIZE_SHRINK_CENTER`，并在 `NOTIFICATION_RESIZED` 中动态执行 `_update_page_width_limit()`：
  - `page.custom_minimum_size.x = min(MAX_PAGE_WIDTH, available_width)`
  - 小屏允许收缩，避免强制溢出。

## 验证结果

已执行静态检查：

```bash
grep -n 'window/size/mode\|window/stretch/aspect\|viewport_width\|viewport_height' project.godot
grep -n 'BAR_HEIGHT\|custom_minimum_size\|HOME_ICON_SIZE\|LEVEL_PILL_SIZE\|COIN_PILL_SIZE\|CENTER_MIN_WIDTH\|TIME_MIN_WIDTH' scripts/ui/top_bar.gd
```

检查结果符合预期：

- `window/size/mode=0`
- `window/stretch/aspect="keep"`
- `viewport_width=750`
- `viewport_height=1334`
- TopBar 关键尺寸由常量统一管理

已执行运行检查：

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path /Users/yz/godot/ai-cat --check-only --quit
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path /Users/yz/godot/ai-cat --scene res://scenes/MainScene.tscn --quit-after 2
```

两项均通过，未出现脚本错误。
