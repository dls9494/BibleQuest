#!/usr/bin/env python3
"""
Generate elegant Bible app icon for all Android mipmap densities.
Uses PIL/Pillow to draw an open book with a subtle cross, warm gold & dark brown palette.
"""
import os
import math

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    import subprocess
    subprocess.run(["pip3", "install", "Pillow"], check=True)
    from PIL import Image, ImageDraw, ImageFont

# Size map: density → pixel size
SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

BASE_PATH = "android/app/src/main/res"


def draw_icon(size: int) -> Image.Image:
    """Draw the icon at the given pixel size."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    s = size
    cx = s // 2
    cy = s // 2

    # ─── Background circle with warm dark gradient ───────────────────────────
    # Simulate a radial gradient with concentric circles
    for r in range(cx, 0, -1):
        t = r / cx  # 1 at edge, 0 at center
        # Deep brown to warm dark brown
        red   = int(40  + t * 20)
        green = int(20  + t * 10)
        blue  = int(8   + t * 4)
        draw.ellipse(
            [cx - r, cy - r, cx + r, cy + r],
            fill=(red, green, blue, 255),
        )

    # ─── Outer glow ring ────────────────────────────────────────────────────
    ring_r = int(s * 0.46)
    ring_w = max(2, s // 36)
    draw.ellipse(
        [cx - ring_r, cy - ring_r, cx + ring_r, cy + ring_r],
        outline=(212, 160, 60, 200),
        width=ring_w,
    )

    # ─── Open book ──────────────────────────────────────────────────────────
    bk_w  = int(s * 0.72)
    bk_h  = int(s * 0.52)
    bk_l  = cx - bk_w // 2
    bk_r  = cx + bk_w // 2
    bk_t  = cy - bk_h // 2
    bk_b  = cy + bk_h // 2

    page_color       = (245, 230, 195, 255)   # warm cream
    page_shadow      = (200, 175, 130, 255)   # warm shadow
    spine_color      = (80, 50, 20, 255)      # dark spine
    gold             = (212, 160, 60, 255)
    gold_light       = (255, 210, 100, 255)

    # Book shadow
    shadow_offset = max(1, s // 40)
    draw.rounded_rectangle(
        [bk_l + shadow_offset, bk_t + shadow_offset, bk_r + shadow_offset, bk_b + shadow_offset],
        radius=max(3, s // 24),
        fill=(0, 0, 0, 100),
    )

    # Left page (slightly angled — we'll just do rect for simplicity)
    left_page = [bk_l, bk_t, cx - 2, bk_b]
    draw.rounded_rectangle(left_page, radius=max(2, s // 32), fill=page_shadow)
    draw.rounded_rectangle(
        [bk_l + 2, bk_t + 2, cx - 4, bk_b - 2],
        radius=max(2, s // 32),
        fill=page_color,
    )

    # Right page
    right_page = [cx + 2, bk_t, bk_r, bk_b]
    draw.rounded_rectangle(right_page, radius=max(2, s // 32), fill=page_shadow)
    draw.rounded_rectangle(
        [cx + 4, bk_t + 2, bk_r - 2, bk_b - 2],
        radius=max(2, s // 32),
        fill=page_color,
    )

    # Spine (center strip)
    spine_w = max(4, s // 20)
    draw.rounded_rectangle(
        [cx - spine_w // 2, bk_t - 2, cx + spine_w // 2, bk_b + 2],
        radius=max(2, s // 32),
        fill=spine_color,
    )
    # Spine highlight
    draw.rounded_rectangle(
        [cx - spine_w // 2 + 1, bk_t - 1, cx - spine_w // 4, bk_b + 1],
        radius=1,
        fill=(120, 80, 40, 180),
    )

    # ─── Page lines (left page) ──────────────────────────────────────────────
    line_col = (180, 155, 110, 160)
    num_lines = max(3, s // 22)
    line_spacing = (bk_h - 10) // (num_lines + 1)
    line_pad_l = bk_l + max(4, s // 18)
    line_pad_r = cx - max(6, s // 14)
    for i in range(1, num_lines + 1):
        y = bk_t + 4 + i * line_spacing
        draw.line([(line_pad_l, y), (line_pad_r, y)], fill=line_col, width=max(1, s // 72))

    # ─── Page lines (right page) ─────────────────────────────────────────────
    line_pad_l2 = cx + max(6, s // 14)
    line_pad_r2 = bk_r - max(4, s // 18)
    for i in range(1, num_lines + 1):
        y = bk_t + 4 + i * line_spacing
        draw.line([(line_pad_l2, y), (line_pad_r2, y)], fill=line_col, width=max(1, s // 72))

    # ─── Cross on the right page ─────────────────────────────────────────────
    cross_cx = cx + bk_w // 5
    cross_cy = cy
    cross_h  = int(bk_h * 0.45)
    cross_w  = int(cross_h * 0.55)
    cross_bar_y = cross_cy - cross_h // 5
    cross_thick = max(2, s // 38)

    # Cross shadow
    draw.line(
        [(cross_cx + 1, cross_cy - cross_h // 2 + 1), (cross_cx + 1, cross_cy + cross_h // 2 + 1)],
        fill=(150, 110, 50, 100), width=cross_thick + 1,
    )
    draw.line(
        [(cross_cx - cross_w // 2 + 1, cross_bar_y + 1), (cross_cx + cross_w // 2 + 1, cross_bar_y + 1)],
        fill=(150, 110, 50, 100), width=cross_thick + 1,
    )

    # Cross (gold)
    draw.line(
        [(cross_cx, cross_cy - cross_h // 2), (cross_cx, cross_cy + cross_h // 2)],
        fill=gold, width=cross_thick,
    )
    draw.line(
        [(cross_cx - cross_w // 2, cross_bar_y), (cross_cx + cross_w // 2, cross_bar_y)],
        fill=gold, width=cross_thick,
    )

    # ─── Gold decorative dots on spine ──────────────────────────────────────
    dot_r = max(2, s // 40)
    for y_frac in [0.3, 0.7]:
        dy = int(bk_t + bk_h * y_frac)
        draw.ellipse(
            [cx - dot_r, dy - dot_r, cx + dot_r, dy + dot_r],
            fill=gold_light,
        )

    # ─── Top page curl (right page) ─────────────────────────────────────────
    curl_size = max(4, s // 18)
    draw.polygon(
        [
            (bk_r - curl_size, bk_t),
            (bk_r, bk_t),
            (bk_r, bk_t + curl_size),
        ],
        fill=page_shadow,
    )
    draw.polygon(
        [
            (bk_r - curl_size, bk_t),
            (bk_r, bk_t + curl_size),
            (bk_r - curl_size + 1, bk_t + curl_size - 1),
        ],
        fill=(230, 210, 170, 255),
    )

    # ─── Bottom glow / reflection arc ───────────────────────────────────────
    arc_r = int(s * 0.42)
    arc_w = max(1, s // 64)
    draw.arc(
        [cx - arc_r, cy - arc_r, cx + arc_r, cy + arc_r],
        start=200, end=340,
        fill=(212, 160, 60, 80),
        width=arc_w,
    )

    return img


def main():
    for density, size in SIZES.items():
        out_dir = os.path.join(BASE_PATH, density)
        os.makedirs(out_dir, exist_ok=True)
        icon = draw_icon(size)
        out_path = os.path.join(out_dir, "ic_launcher.png")
        icon.save(out_path, "PNG")
        print(f"✓ Saved {size}×{size} → {out_path}")

    print("\nIcon generation complete!")


if __name__ == "__main__":
    main()
