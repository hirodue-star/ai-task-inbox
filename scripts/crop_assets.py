#!/usr/bin/env python3
"""MA-LOGIC 本番アセット切り出しスクリプト
Sheet 1 (aqsrnk): 上段シート - ガオミ級、親子の絆、背景、グリッドアイコン等
Sheet 2 (f8odwd): 下段シート - ひよこ級、ペンギン級、ライオン級メイン素材
"""

from PIL import Image
import os

BASE = os.path.expanduser("~/ai-task-inbox/assets/images")
SHEET1 = os.path.expanduser("~/Downloads/Gemini_Generated_Image_aqsrnkaqsrnkaqsr.png")
SHEET2 = os.path.expanduser("~/Downloads/Gemini_Generated_Image_f8odwdf8odwdf8od.png")

def crop_save(img, box, folder, filename, resize=None):
    """Crop region and save as transparent PNG."""
    path = os.path.join(BASE, folder, filename)
    cropped = img.crop(box)
    if resize:
        cropped = cropped.resize(resize, Image.LANCZOS)
    cropped.save(path, "PNG")
    print(f"  ✅ {folder}/{filename} ({cropped.size[0]}x{cropped.size[1]})")

def process_sheet1(img):
    """Sheet 1: ガオミ級、背景、親子の絆、グリッドアイコン、メダル、Wipes"""
    w, h = img.size
    print(f"\n📋 Sheet 1 ({w}x{h})")

    # === ひよこ級 背景 (左上) ===
    print("\n🐣 ひよこ級 背景:")
    crop_save(img, (15, 55, 200, 210), "hiyoko", "bg_bubble.png", (512, 512))
    crop_save(img, (15, 215, 200, 375), "hiyoko", "bg_main.png", (1080, 1920))

    # === ペンギン級 背景 (中央上) ===
    print("\n🐧 ペンギン級 背景:")
    crop_save(img, (200, 55, 375, 210), "penguin", "bg_ice.png", (512, 512))

    # === ライオン級 背景 (右上) ===
    print("\n🦁 ライオン級 背景:")
    crop_save(img, (375, 55, 500, 210), "lion", "bg_gold.png", (512, 512))

    # === ガオミ級 ひよこ表情 (中央) ===
    print("\n😊 ガオミ級 ひよこ表情:")
    gaomi_y = 30
    gaomi_names = ["hiyoko_normal", "hiyoko_happy", "hiyoko_thinking", "hiyoko_sleepy", "hiyoko_excited"]
    for i, name in enumerate(gaomi_names):
        x = 500 + i * 82
        crop_save(img, (x, gaomi_y, x + 78, gaomi_y + 85), "gaomi", f"{name}.png", (256, 256))

    # === ガオミ級 ペンギン表情 ===
    print("\n😊 ガオミ級 ペンギン表情:")
    peng_y = 140
    peng_names = ["penguin_focus", "penguin_clean", "penguin_craft", "penguin_success"]
    for i, name in enumerate(peng_names):
        x = 530 + i * 90
        crop_save(img, (x, peng_y, x + 85, peng_y + 95), "gaomi", f"{name}.png", (256, 256))

    # === ガオミ級 ライオン表情 ===
    print("\n😊 ガオミ級 ライオン表情:")
    lion_y = 260
    lion_names = ["lion_proud", "lion_analyze", "lion_create", "lion_master"]
    for i, name in enumerate(lion_names):
        x = 530 + i * 90
        crop_save(img, (x, lion_y, x + 85, lion_y + 100), "gaomi", f"{name}.png", (256, 256))

    # === ガオミ級 ヒヨココ ===
    print("\n😊 ガオミ級 ヒヨココ:")
    crop_save(img, (570, 380, 680, 480), "gaomi", "hiyoko_split.png", (256, 256))
    crop_save(img, (680, 380, 810, 480), "gaomi", "hiyoko_share.png", (256, 256))

    # === 親子の絆エフェクト フレーム (右上) ===
    print("\n🖼️ 親子の絆エフェクト:")
    frame_x = 960
    frame_names = ["frame_gold_square", "frame_gold_ornate", "frame_simple", "frame_cloud"]
    for i, name in enumerate(frame_names):
        col = i % 2
        row = i // 2
        x = frame_x + col * 110
        y = 25 + row * 105
        crop_save(img, (x, y, x + 105, y + 100), "bond_effect", f"{name}.png", (256, 256))

    # === 親子の絆 - ひょっこり現れる、承認系 ===
    print("\n🖼️ 親子の絆 追加:")
    crop_save(img, (1185, 25, 1400, 260), "bond_effect", "hyokkori.png", (400, 512))
    crop_save(img, (960, 260, 1080, 370), "bond_effect", "frame_gold_large.png", (256, 256))
    crop_save(img, (1080, 260, 1200, 370), "bond_effect", "mama_papa_approve.png", (256, 256))
    crop_save(img, (1200, 260, 1300, 370), "bond_effect", "thumbs_up.png", (128, 128))
    crop_save(img, (1300, 260, 1400, 370), "bond_effect", "gift_thanks.png", (128, 128))

    # === 智慧な知恵 グリッドアイコン ===
    print("\n💡 グリッドアイコン:")
    grid_y = 400
    grid_names = ["thinking", "idea", "knowledge", "discovery", "direction", "expression"]
    for i, name in enumerate(grid_names):
        x = 25 + i * 80
        crop_save(img, (x, grid_y, x + 75, grid_y + 85), "grid_icons", f"icon_{name}.png", (128, 128))

    # === ヘルプメダル ===
    print("\n🏅 メダル:")
    crop_save(img, (20, 530, 130, 680), "medals", "medal_help_bronze.png", (256, 256))
    crop_save(img, (130, 530, 240, 680), "medals", "medal_help_gold.png", (256, 256))

    # === レジェンドリー ===
    print("\n🦁 レジェンドリー:")
    crop_save(img, (270, 530, 430, 700), "lion", "legendary_lion.png", (256, 256))

    # === 親子の絆エフェクト (中央下) ===
    print("\n💕 親子の絆エフェクト:")
    crop_save(img, (530, 520, 720, 700), "bond_effect", "bond_frame_gold.png", (256, 256))

    # === レベルエクショットWipes ===
    print("\n🎬 Wipes:")
    wipe_y = 530
    crop_save(img, (960, wipe_y, 1100, wipe_y + 170), "wipes", "wipe_hiyoko_hatch.png", (400, 300))
    crop_save(img, (1100, wipe_y, 1240, wipe_y + 170), "wipes", "wipe_ice_melt.png", (400, 300))
    crop_save(img, (1240, wipe_y, 1400, wipe_y + 170), "wipes", "wipe_gold_curtain.png", (400, 300))


def process_sheet2(img):
    """Sheet 2: ひよこ級、ペンギン級、ライオン級メイン素材"""
    w, h = img.size
    print(f"\n📋 Sheet 2 ({w}x{h})")

    # === ひよこ級 ぷにぷにボタン ===
    print("\n🐣 ひよこ級 ぷにぷにボタン:")
    btn_colors = ["pink", "blue", "green", "yellow"]
    btn_labels = ["iro", "katachi", "otetsudai", "bouken"]
    for i, (color, label) in enumerate(zip(btn_colors, btn_labels)):
        x = 30 + i * 115
        crop_save(img, (x, 40, x + 110, 140), "hiyoko", f"button_{label}.png", (256, 256))

    # === ひよこ級 ガオガオ表情 ===
    print("\n🐣 ひよこ級 ガオガオ:")
    gaogao_names = ["gaogao_happy", "gaogao_shy", "gaogao_sleepy"]
    for i, name in enumerate(gaogao_names):
        x = 30 + i * 155
        crop_save(img, (x, 175, x + 150, 370), "hiyoko", f"{name}.png", (256, 256))

    # === ひよこ級 おすこの図鑑 ===
    print("\n🐣 ひよこ級 図鑑・風景:")
    crop_save(img, (20, 400, 240, 580), "hiyoko", "otsuko_zukan.png", (512, 512))
    crop_save(img, (240, 400, 460, 580), "hiyoko", "bg_landscape.png", (512, 512))

    # === ペンギン級 氷の結晶フロー ===
    print("\n🐧 ペンギン級:")
    crop_save(img, (480, 20, 920, 170), "penguin", "ice_crystal_flow.png", (800, 256))

    # === ペンギン級 ガオガオレジ ===
    crop_save(img, (490, 190, 660, 390), "penguin", "gaogao_penguin.png", (256, 256))

    # === ペンギン級 プロフィール写図（氷フレーム） ===
    crop_save(img, (660, 190, 870, 390), "penguin", "ice_frame_profile.png", (256, 256))

    # === ペンギン級 お手伝いメダル ===
    print("\n🐧 ペンギン級 メダル・素材:")
    crop_save(img, (490, 420, 660, 580), "penguin", "help_medal_ice.png", (256, 256))

    # === ペンギン級 ツアス素種 ===
    crop_save(img, (660, 420, 920, 580), "penguin", "bg_tour_ice.png", (512, 512))

    # === ライオン級 マンダラグリッド ===
    print("\n🦁 ライオン級:")
    crop_save(img, (945, 20, 1180, 210), "lion", "mandala_grid.png", (512, 512))

    # === ライオン級 びっくらポン（ガチャ） ===
    crop_save(img, (945, 220, 1100, 400), "lion", "bikkurapon_lion.png", (256, 256))
    crop_save(img, (1100, 220, 1250, 340), "lion", "gacha_capsule_gold.png", (256, 256))

    # === ライオン級 パークティクスアイコン ===
    print("\n🦁 ライオン級 パークティクス:")
    particle_names = ["icon_compass", "icon_magnifier", "icon_rocket", "icon_telescope"]
    for i, name in enumerate(particle_names):
        col = i % 2
        row = i // 2
        x = 945 + col * 110
        y = 410 + row * 100
        crop_save(img, (x, y, x + 105, y + 95), "lion", f"{name}.png", (128, 128))

    # === ライオン級 ゴルド素種（宇宙背景） ===
    crop_save(img, (1200, 400, 1400, 600), "lion", "bg_universe.png", (1080, 1920))


if __name__ == "__main__":
    print("🎨 MA-LOGIC 本番アセット切り出し開始...")

    img1 = Image.open(SHEET1).convert("RGBA")
    img2 = Image.open(SHEET2).convert("RGBA")

    process_sheet1(img1)
    process_sheet2(img2)

    # Count total
    total = 0
    for root, dirs, files in os.walk(BASE):
        total += len([f for f in files if f.endswith(".png") and f != ".gitkeep"])
    print(f"\n🏁 切り出し完了: 合計 {total} 素材")
