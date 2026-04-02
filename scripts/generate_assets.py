#!/usr/bin/env python3
"""MA-LOGIC 全24素材のプレースホルダーPNG生成"""

from PIL import Image, ImageDraw, ImageFont
import os

BASE = os.path.expanduser("~/ai-task-inbox/assets/images")

# カラーパレット
COLORS = {
    "hiyoko": {"bg": (255, 245, 200), "fg": (180, 130, 20), "accent": (255, 200, 50)},
    "lion":   {"bg": (255, 235, 200), "fg": (160, 80, 20),  "accent": (230, 150, 50)},
    "bond":   {"bg": (230, 240, 255), "fg": (60, 80, 140),  "accent": (100, 150, 230)},
}

MEDAL_COLORS = {
    "bronze":   (205, 127, 50),
    "silver":   (192, 192, 192),
    "gold":     (255, 215, 0),
    "platinum": (229, 228, 226),
}

ASSETS = [
    # hiyoko - medals & badges
    ("hiyoko", "medal_bronze.png",    256, 256, "medal",    "ブロンズ\nメダル"),
    ("hiyoko", "medal_silver.png",    256, 256, "medal",    "シルバー\nメダル"),
    ("hiyoko", "medal_gold.png",      256, 256, "medal",    "ゴールド\nメダル"),
    ("hiyoko", "medal_platinum.png",  256, 256, "medal",    "プラチナ\nメダル"),
    ("hiyoko", "badge_streak.png",    128, 128, "badge",    "連続\n達成"),
    # hiyoko - category icons
    ("hiyoko", "icon_cleaning.png",   128, 128, "icon",     "掃除"),
    ("hiyoko", "icon_cooking.png",    128, 128, "icon",     "料理"),
    ("hiyoko", "icon_laundry.png",    128, 128, "icon",     "洗濯"),
    ("hiyoko", "icon_shopping.png",   128, 128, "icon",     "買物"),
    ("hiyoko", "icon_pet_care.png",   128, 128, "icon",     "ペット"),
    ("hiyoko", "icon_sibling_care.png", 128, 128, "icon",   "兄弟"),
    ("hiyoko", "icon_garden.png",     128, 128, "icon",     "庭"),
    ("hiyoko", "icon_other.png",      128, 128, "icon",     "他"),
    # hiyoko - UI
    ("hiyoko", "avatar_default.png",  256, 256, "avatar",   "ひよこ"),
    ("hiyoko", "empty_state.png",     400, 400, "empty",    "まだ\nお手伝いが\nありません"),
    # lion - branding
    ("lion",   "logo.png",           512, 512, "logo",      "MA\nLOGIC"),
    ("lion",   "logo_wide.png",     1024, 512, "logo_wide", "MA-LOGIC"),
    ("lion",   "splash_bg.png",     1080, 1920, "splash",   "MA-LOGIC"),
    ("lion",   "bg_pattern.png",     512, 512, "pattern",   ""),
    # bond - onboarding & sharing
    ("bond",   "onboarding_1.png",   800, 800, "onboard",   "お手伝いで\nメダルを\nゲット!"),
    ("bond",   "onboarding_2.png",   800, 800, "onboard",   "家族の\nきずなが\n深まる"),
    ("bond",   "onboarding_3.png",   800, 800, "onboard",   "ママ友と\nシェア\nしよう"),
    ("bond",   "share_card.png",    1200, 630, "share",     "MA-LOGIC\nお手伝いの記録をシェア"),
    ("bond",   "invite_banner.png",  800, 400, "invite",    "ママ友を招待しよう!"),
]


def get_font(size):
    """Try to load a Japanese-capable font."""
    font_paths = [
        "/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc",
        "/System/Library/Fonts/Hiragino Sans GB.ttc",
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]
    for p in font_paths:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                continue
    return ImageFont.load_default()


def draw_medal(img, draw, w, h, label, medal_type):
    color_key = medal_type.replace("medal_", "").replace(".png", "")
    mc = MEDAL_COLORS.get(color_key, (200, 200, 200))
    cx, cy = w // 2, h // 2
    r = min(w, h) // 2 - 20
    # Ribbon
    draw.polygon([(cx - 30, 10), (cx - 50, cy - r + 10), (cx, cy - r + 40)], fill=(200, 50, 50))
    draw.polygon([(cx + 30, 10), (cx + 50, cy - r + 10), (cx, cy - r + 40)], fill=(200, 50, 50))
    # Medal circle
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=mc, outline=(100, 80, 40), width=4)
    # Inner circle
    ir = r - 15
    draw.ellipse([cx - ir, cy - ir, cx + ir, cy + ir], outline=(100, 80, 40), width=2)
    # Star
    draw_star(draw, cx, cy - 10, ir - 20, mc, (100, 80, 40))
    # Text
    font = get_font(max(16, r // 4))
    draw.multiline_text((cx, cy + r - 30), label, fill=(80, 60, 20), font=font, anchor="mm", align="center")


def draw_star(draw, cx, cy, size, fill, outline):
    import math
    points = []
    for i in range(10):
        angle = math.radians(i * 36 - 90)
        r = size if i % 2 == 0 else size * 0.4
        points.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    darker = tuple(max(0, c - 40) for c in fill)
    draw.polygon(points, fill=darker, outline=outline)


def draw_icon(img, draw, w, h, palette, label):
    cx, cy = w // 2, h // 2
    r = min(w, h) // 2 - 8
    draw.rounded_rectangle([8, 8, w - 8, h - 8], radius=20, fill=palette["accent"], outline=palette["fg"], width=2)
    # Chick body
    cr = r // 3
    draw.ellipse([cx - cr, cy - cr - 10, cx + cr, cy + cr - 10], fill=(255, 230, 100), outline=palette["fg"], width=2)
    # Eyes
    draw.ellipse([cx - 6, cy - 14, cx - 2, cy - 10], fill=(40, 40, 40))
    draw.ellipse([cx + 2, cy - 14, cx + 6, cy - 10], fill=(40, 40, 40))
    # Beak
    draw.polygon([(cx - 3, cy - 6), (cx + 3, cy - 6), (cx, cy)], fill=(255, 150, 50))
    font = get_font(max(14, r // 3))
    draw.text((cx, h - 16), label, fill=palette["fg"], font=font, anchor="mb", align="center")


def draw_badge(img, draw, w, h, palette, label):
    cx, cy = w // 2, h // 2
    r = min(w, h) // 2 - 6
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(255, 100, 100), outline=(180, 50, 50), width=3)
    # Fire / streak symbol
    draw.polygon([(cx, cy - r + 15), (cx + 15, cy + 5), (cx, cy - 5), (cx - 15, cy + 5)], fill=(255, 200, 50))
    font = get_font(max(12, r // 3))
    draw.multiline_text((cx, cy + r - 12), label, fill=(255, 255, 255), font=font, anchor="mm", align="center")


def draw_avatar(img, draw, w, h, palette, label):
    cx, cy = w // 2, h // 2
    r = min(w, h) // 2 - 10
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=palette["bg"], outline=palette["fg"], width=3)
    # Chick body
    br = r * 2 // 3
    draw.ellipse([cx - br, cy - br + 10, cx + br, cy + br + 10], fill=(255, 230, 100), outline=palette["fg"], width=2)
    # Eyes
    draw.ellipse([cx - 18, cy - 8, cx - 8, cy + 2], fill=(40, 40, 40))
    draw.ellipse([cx + 8, cy - 8, cx + 18, cy + 2], fill=(40, 40, 40))
    # Beak
    draw.polygon([(cx - 8, cy + 8), (cx + 8, cy + 8), (cx, cy + 20)], fill=(255, 150, 50))
    # Blush
    draw.ellipse([cx - br + 8, cy + 5, cx - br + 28, cy + 20], fill=(255, 180, 180))
    draw.ellipse([cx + br - 28, cy + 5, cx + br - 8, cy + 20], fill=(255, 180, 180))


def draw_logo(img, draw, w, h, palette, label):
    cx, cy = w // 2, h // 2
    # Background gradient effect
    for i in range(h):
        ratio = i / h
        r = int(palette["bg"][0] * (1 - ratio) + palette["accent"][0] * ratio)
        g = int(palette["bg"][1] * (1 - ratio) + palette["accent"][1] * ratio)
        b = int(palette["bg"][2] * (1 - ratio) + palette["accent"][2] * ratio)
        draw.line([(0, i), (w, i)], fill=(r, g, b))
    # Lion mane circle
    mr = min(w, h) // 3
    for angle in range(0, 360, 15):
        import math
        x = cx + int(mr * 1.2 * math.cos(math.radians(angle)))
        y = cy - 30 + int(mr * 1.2 * math.sin(math.radians(angle)))
        draw.ellipse([x - 20, y - 20, x + 20, y + 20], fill=(200, 120, 30))
    # Face
    draw.ellipse([cx - mr, cy - mr - 30, cx + mr, cy + mr - 30], fill=(240, 180, 80), outline=palette["fg"], width=3)
    # Eyes
    draw.ellipse([cx - 30, cy - 50, cx - 15, cy - 35], fill=(40, 40, 40))
    draw.ellipse([cx + 15, cy - 50, cx + 30, cy - 35], fill=(40, 40, 40))
    # Nose
    draw.ellipse([cx - 12, cy - 25, cx + 12, cy - 10], fill=(180, 100, 40))
    # Mouth
    draw.arc([cx - 20, cy - 20, cx, cy], 0, 180, fill=(120, 60, 20), width=2)
    draw.arc([cx, cy - 20, cx + 20, cy], 0, 180, fill=(120, 60, 20), width=2)
    # Text
    font = get_font(max(36, min(w, h) // 6))
    draw.multiline_text((cx, cy + mr + 20), label, fill=palette["fg"], font=font, anchor="ma", align="center")


def draw_splash(img, draw, w, h, palette, label):
    # Gradient background
    for i in range(h):
        ratio = i / h
        r = int(255 * (1 - ratio) + palette["accent"][0] * ratio)
        g = int(240 * (1 - ratio) + palette["accent"][1] * ratio)
        b = int(220 * (1 - ratio) + palette["accent"][2] * ratio)
        draw.line([(0, i), (w, i)], fill=(r, g, b))
    # Central logo area
    cx, cy = w // 2, h // 3
    r = 150
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(240, 180, 80), outline=palette["fg"], width=4)
    font = get_font(72)
    draw.multiline_text((cx, cy), "MA\nLOGIC", fill=palette["fg"], font=font, anchor="mm", align="center")
    # Tagline
    font2 = get_font(32)
    draw.text((cx, h * 2 // 3), "お手伝いで絆を育む", fill=palette["fg"], font=font2, anchor="mm")


def draw_pattern(img, draw, w, h, palette, label):
    # Tile pattern
    tile = 64
    for y in range(0, h, tile):
        for x in range(0, w, tile):
            c = palette["bg"] if (x // tile + y // tile) % 2 == 0 else palette["accent"]
            draw.rectangle([x, y, x + tile, y + tile], fill=c)
            # Small paw print
            cx, cy = x + tile // 2, y + tile // 2
            draw.ellipse([cx - 6, cy - 2, cx + 6, cy + 8], fill=palette["fg"] + (60,))
            for dx, dy in [(-8, -6), (8, -6), (-12, 2), (12, 2)]:
                draw.ellipse([cx + dx - 3, cy + dy - 3, cx + dx + 3, cy + dy + 3], fill=palette["fg"] + (60,))


def draw_onboard(img, draw, w, h, palette, label):
    cx, cy = w // 2, h // 2
    # Soft background
    draw.rounded_rectangle([20, 20, w - 20, h - 20], radius=40, fill=(245, 248, 255), outline=palette["accent"], width=3)
    # Illustration circle
    r = min(w, h) // 4
    draw.ellipse([cx - r, cy - r - 80, cx + r, cy + r - 80], fill=palette["accent"], outline=palette["fg"], width=2)
    # Heart
    hx, hy = cx, cy - 80
    draw.polygon([(hx, hy + 20), (hx - 30, hy - 10), (hx, hy - 30), (hx + 30, hy - 10)], fill=(255, 120, 120))
    # Text
    font = get_font(40)
    draw.multiline_text((cx, cy + r + 40), label, fill=palette["fg"], font=font, anchor="ma", align="center")


def draw_share(img, draw, w, h, palette, label):
    # Card background
    draw.rounded_rectangle([0, 0, w, h], radius=20, fill=(245, 248, 255), outline=palette["accent"], width=4)
    # Left accent bar
    draw.rectangle([0, 0, 8, h], fill=palette["accent"])
    # Logo area
    draw.ellipse([40, h // 2 - 60, 160, h // 2 + 60], fill=palette["accent"])
    font_s = get_font(28)
    draw.text((100, h // 2), "MA", fill=(255, 255, 255), font=font_s, anchor="mm")
    # Text
    font = get_font(40)
    draw.multiline_text((w // 2 + 80, h // 2), label, fill=palette["fg"], font=font, anchor="mm", align="center")


def draw_invite(img, draw, w, h, palette, label):
    draw.rounded_rectangle([0, 0, w, h], radius=24, fill=palette["accent"], outline=palette["fg"], width=3)
    # Hearts
    for x in [100, 300, 500, 700]:
        draw.polygon([(x, 80), (x - 20, 60), (x, 40), (x + 20, 60)], fill=(255, 150, 150))
    font = get_font(36)
    draw.text((w // 2, h // 2 + 30), label, fill=(255, 255, 255), font=font, anchor="mm")


def draw_empty(img, draw, w, h, palette, label):
    cx, cy = w // 2, h // 2
    # Sad chick
    r = 80
    draw.ellipse([cx - r, cy - r - 20, cx + r, cy + r - 20], fill=(255, 230, 100), outline=palette["fg"], width=2)
    # Eyes (sad)
    draw.arc([cx - 30, cy - 30, cx - 10, cy - 15], 0, 180, fill=(40, 40, 40), width=2)
    draw.arc([cx + 10, cy - 30, cx + 30, cy - 15], 0, 180, fill=(40, 40, 40), width=2)
    # Mouth (sad)
    draw.arc([cx - 15, cy + 10, cx + 15, cy + 30], 180, 360, fill=(40, 40, 40), width=2)
    font = get_font(24)
    draw.multiline_text((cx, cy + r + 30), label, fill=palette["fg"], font=font, anchor="ma", align="center")


DRAW_MAP = {
    "medal": draw_medal,
    "icon": draw_icon,
    "badge": draw_badge,
    "avatar": draw_avatar,
    "logo": draw_logo,
    "logo_wide": draw_logo,
    "splash": draw_splash,
    "pattern": draw_pattern,
    "onboard": draw_onboard,
    "share": draw_share,
    "invite": draw_invite,
    "empty": draw_empty,
}


def generate_asset(folder, filename, w, h, asset_type, label):
    path = os.path.join(BASE, folder, filename)
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    palette = COLORS[folder]

    draw_fn = DRAW_MAP.get(asset_type)
    if draw_fn:
        if asset_type == "medal":
            draw_fn(img, draw, w, h, label, filename)
        else:
            draw_fn(img, draw, w, h, palette, label)
    else:
        draw.rectangle([0, 0, w, h], fill=palette["bg"])
        font = get_font(20)
        draw.text((w // 2, h // 2), label, fill=palette["fg"], font=font, anchor="mm", align="center")

    img.save(path, "PNG")
    print(f"  ✅ {folder}/{filename} ({w}x{h})")


if __name__ == "__main__":
    print("🎨 MA-LOGIC 素材生成開始...\n")
    for folder, filename, w, h, asset_type, label in ASSETS:
        generate_asset(folder, filename, w, h, asset_type, label)
    print(f"\n🏁 完了: {len(ASSETS)}素材を生成しました")
