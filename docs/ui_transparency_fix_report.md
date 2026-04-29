# UI 资源透明度修复报告

## 修复结果

| 文件 | 存在 | 尺寸 | 修复前 Alpha | 修复后 Alpha | 边缘背景占比 | 背景占比 | 疑似伪透明 | 已修复 | 备注 |
|---|---:|---|---|---|---:|---:|---:|---:|---|
| `assets/icons/status/status_hunger.png` | True | (1254, 1254) | (255, 255) | (0, 255) | 1.000 | 0.624 | True | True | fixed, backup=status_hunger.png.bak.png, candidates=[(240, 240, 240), (245, 245, 245), (254, 253, 254)] |
| `assets/icons/status/status_mood.png` | True | (1254, 1254) | (255, 255) | (0, 255) | 1.000 | 0.528 | True | True | fixed, backup=status_mood.png.bak.png, candidates=[(246, 245, 245), (250, 250, 250), (255, 254, 254)] |
| `assets/icons/status/status_energy.png` | True | (1254, 1254) | (255, 255) | (0, 255) | 1.000 | 0.676 | True | True | fixed, backup=status_energy.png.bak.png, candidates=[(243, 243, 242), (254, 253, 253), (248, 248, 248)] |
| `assets/icons/status/status_clean.png` | True | (1254, 1254) | (255, 255) | (0, 255) | 1.000 | 0.654 | True | True | fixed, backup=status_clean.png.bak.png, candidates=[(242, 242, 241), (253, 253, 253), (248, 247, 247)] |
| `assets/icons/actions/action_feed.png` | True | (1254, 1254) | (255, 255) | (0, 255) | 1.000 | 0.517 | True | True | fixed, backup=action_feed.png.bak.png, candidates=[(241, 240, 240), (252, 252, 252), (247, 246, 246)] |
| `assets/icons/actions/action_play.png` | True | (1254, 1254) | (255, 255) | (0, 255) | 1.000 | 0.754 | True | True | fixed, backup=action_play.png.bak.png, candidates=[(240, 240, 240), (253, 253, 252), (247, 246, 246)] |
| `assets/icons/actions/action_pet.png` | True | (1254, 1254) | (255, 255) | (0, 255) | 1.000 | 0.603 | True | True | fixed, backup=action_pet.png.bak.png, candidates=[(240, 240, 240), (252, 252, 252), (247, 246, 246)] |
| `assets/icons/actions/action_bath.png` | True | (1254, 1254) | (255, 255) | (0, 255) | 1.000 | 0.642 | True | True | fixed, backup=action_bath.png.bak.png, candidates=[(243, 243, 243), (253, 253, 253), (248, 248, 248)] |
| `assets/icons/actions/action_sleep.png` | True | (1254, 1254) | (255, 255) | (0, 255) | 1.000 | 0.750 | True | True | fixed, backup=action_sleep.png.bak.png, candidates=[(245, 245, 244), (253, 253, 253)] |
| `assets/ui/status/status_card_hunger_bg.png` | True | (2172, 724) | (255, 255) | (0, 255) | 1.000 | 0.263 | True | True | fixed, backup=status_card_hunger_bg.png.bak.png, candidates=[(242, 242, 242), (253, 253, 253), (248, 248, 248)] |
| `assets/ui/status/status_card_mood_bg.png` | True | (2172, 724) | (255, 255) | (0, 255) | 1.000 | 0.325 | True | True | fixed, backup=status_card_mood_bg.png.bak.png, candidates=[(243, 243, 242), (250, 250, 250), (255, 255, 255)] |
| `assets/ui/status/status_card_energy_bg.png` | True | (2172, 724) | (255, 255) | (0, 255) | 1.000 | 0.275 | True | True | fixed, backup=status_card_energy_bg.png.bak.png, candidates=[(245, 245, 245), (254, 254, 254)] |
| `assets/ui/status/status_card_clean_bg.png` | True | (2172, 724) | (255, 255) | (0, 255) | 1.000 | 0.287 | True | True | fixed, backup=status_card_clean_bg.png.bak.png, candidates=[(245, 244, 244), (251, 251, 251)] |
| `assets/ui/actions/action_button_feed_bg.png` | True | (1157, 1359) | (255, 255) | (0, 255) | 1.000 | 0.272 | True | True | fixed, backup=action_button_feed_bg.png.bak.png, candidates=[(241, 241, 241), (249, 249, 249), (254, 254, 254)] |
| `assets/ui/actions/action_button_play_bg.png` | True | (1157, 1359) | (255, 255) | (0, 255) | 1.000 | 0.394 | True | True | fixed, backup=action_button_play_bg.png.bak.png, candidates=[(235, 235, 235), (245, 245, 245), (254, 254, 254)] |
| `assets/ui/actions/action_button_pet_bg.png` | True | (1157, 1359) | (255, 255) | (0, 255) | 1.000 | 0.253 | True | True | fixed, backup=action_button_pet_bg.png.bak.png, candidates=[(238, 238, 238), (246, 246, 246), (254, 254, 254)] |
| `assets/ui/actions/action_button_bath_bg.png` | True | (1157, 1359) | (255, 255) | (0, 255) | 1.000 | 0.288 | True | True | fixed, backup=action_button_bath_bg.png.bak.png, candidates=[(239, 239, 238), (247, 247, 247), (254, 254, 254)] |
| `assets/ui/actions/action_button_sleep_bg.png` | True | (1157, 1359) | (255, 255) | (0, 255) | 1.000 | 0.396 | True | True | fixed, backup=action_button_sleep_bg.png.bak.png, candidates=[(243, 243, 242), (251, 251, 251)] |
| `assets/icons/common/sparkle_gold.png` | True | (1254, 1254) | (255, 255) | (0, 255) | 1.000 | 0.845 | True | True | fixed, backup=sparkle_gold.png.bak.png, candidates=[(242, 241, 241), (248, 248, 248), (254, 254, 254)] |
| `assets/icons/common/sparkle_pink.png` | True | (1254, 1254) | (255, 255) | (0, 255) | 1.000 | 0.917 | True | True | fixed, backup=sparkle_pink.png.bak.png, candidates=[(244, 244, 244), (249, 249, 249), (254, 254, 254)] |
| `assets/icons/common/sparkle_blue.png` | True | (1254, 1254) | (255, 255) | (0, 255) | 1.000 | 0.855 | True | True | fixed, backup=sparkle_blue.png.bak.png, candidates=[(244, 244, 244), (253, 253, 253), (249, 248, 248)] |
| `assets/icons/common/sparkle_green.png` | True | (1254, 1254) | (255, 255) | (0, 255) | 1.000 | 0.880 | True | True | fixed, backup=sparkle_green.png.bak.png, candidates=[(245, 245, 244), (251, 251, 251)] |
| `assets/icons/common/sparkle_purple.png` | True | (1254, 1254) | (255, 255) | (0, 255) | 1.000 | 0.873 | True | True | fixed, backup=sparkle_purple.png.bak.png, candidates=[(244, 244, 244), (254, 254, 254), (249, 249, 249)] |
