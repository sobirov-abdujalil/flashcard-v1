"""Generates the So'z Atlas brand assets.

Run from the project root:
    python tool/generate_brand_assets.py

Outputs:
- Android legacy launcher icons (mipmap-*/ic_launcher.png)
- Android adaptive icon foregrounds (mipmap-*/ic_launcher_foreground.png)
- Android splash logo (drawable/splash_logo.png)
- Google Play store icon (store_assets/icon_512.png)
- Google Play feature graphic (store_assets/feature_graphic_1024x500.png)

The artwork is drawn from scratch (no external images) so the repository stays
self-contained and the icons can be regenerated at any time.
"""

from __future__ import annotations

import math
import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
ANDROID_RES = ROOT / "android" / "app" / "src" / "main" / "res"
STORE_ASSETS = ROOT / "store_assets"
FONT_DIR = ROOT / "assets" / "fonts"

SS = 4  # supersampling factor

NAVY = (9, 14, 29)
NAVY_LIGHT = (17, 26, 45)
LAVENDER = (146, 124, 255)
CYAN = (101, 200, 245)
MINT = (116, 228, 192)
WHITE = (244, 246, 255)


def _lerp(c1, c2, t):
    return tuple(round(a + (b - a) * t) for a, b in zip(c1, c2))


def gradient(size: int, colors, angle: float = 45.0) -> Image.Image:
    """Linear gradient image (RGB)."""
    w = h = size
    img = Image.new("RGB", (size, size))
    pixels = img.load()
    rad = math.radians(angle)
    dx, dy = math.cos(rad), math.sin(rad)
    # projection range
    projections = [0, dx * (w - 1), dy * (h - 1), dx * (w - 1) + dy * (h - 1)]
    lo, hi = min(projections), max(projections)
    span = hi - lo if hi > lo else 1.0
    segments = len(colors) - 1
    for y in range(h):
        for x in range(w):
            t = ((x * dx + y * dy) - lo) / span
            t = min(max(t, 0.0), 1.0)
            pos = t * segments
            idx = min(int(pos), segments - 1)
            local = pos - idx
            pixels[x, y] = _lerp(colors[idx], colors[idx + 1], local)
    return img


def radial_glow(size: int, color, alpha: int = 110) -> Image.Image:
    """Soft radial glow on a transparent canvas."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    steps = 40
    for i in range(steps, 0, -1):
        t = i / steps
        r = int(size * 0.5 * t)
        a = int(alpha * (1 - t) ** 2)
        draw.ellipse(
            (size // 2 - r, size // 2 - r, size // 2 + r, size // 2 + r),
            fill=(color[0], color[1], color[2], a),
        )
    return img.filter(ImageFilter.GaussianBlur(size * 0.05))


def quad_points(p0, ctrl, p1, steps=28):
    points = []
    for i in range(steps + 1):
        t = i / steps
        x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * ctrl[0] + t * t * p1[0]
        y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * ctrl[1] + t * t * p1[1]
        points.append((x, y))
    return points


def book_paths():
    """Returns the two page polygons and the spine in unit coordinates."""
    left = []
    left += quad_points((0.12, 0.58), (0.30, 0.50), (0.475, 0.575))
    left.append((0.475, 0.855))
    left += quad_points((0.475, 0.855), (0.30, 0.785), (0.12, 0.835))[1:]
    right = []
    right += quad_points((0.88, 0.58), (0.70, 0.50), (0.525, 0.575))
    right.append((0.525, 0.855))
    right += quad_points((0.525, 0.855), (0.70, 0.785), (0.88, 0.835))[1:]
    return left, right


def draw_logo(
    canvas: Image.Image,
    box: tuple[int, int, int, int],
    glow: bool = True,
    line_scale: float = 1.0,
    nodes: bool = True,
) -> None:
    """Draws the open-book constellation mark inside `box` on `canvas` (RGBA)."""
    x0, y0, x1, y1 = box
    size = min(x1 - x0, y1 - y0)
    ox = x0 + (x1 - x0 - size) // 2
    oy = y0 + (y1 - y0 - size) // 2

    def pt(ux, uy):
        return (ox + ux * size, oy + uy * size)

    grad = gradient(size, [LAVENDER, CYAN, MINT], angle=45).convert("RGBA")
    grad = grad.resize((size, size))

    # --- Book pages, filled with the brand gradient via a mask.
    mask = Image.new("L", (size, size), 0)
    mdraw = ImageDraw.Draw(mask)
    left, right = book_paths()
    mdraw.polygon([pt(*p) for p in left], fill=255)
    mdraw.polygon([pt(*p) for p in right], fill=255)

    page_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    page_layer.paste(grad, (0, 0), mask)

    if glow:
        glow_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        glow_layer.paste(
            Image.new(
                "RGBA", (size, size), (LAVENDER[0], LAVENDER[1], LAVENDER[2], 110)
            ),
            (0, 0),
            mask,
        )
        glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(size * 0.04))
        canvas.alpha_composite(glow_layer, (ox, oy))
    canvas.alpha_composite(page_layer, (ox, oy))

    draw = ImageDraw.Draw(canvas)

    # Page inner highlight lines make the mark read as an open book.
    # They are clipped to the page mask so nothing spills outside the book.
    highlight_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    hdraw = ImageDraw.Draw(highlight_layer)
    highlight = (255, 255, 255, 70)
    for offset in (0.10, 0.18):
        hdraw.line(
            [pt(0.19, 0.66 + offset), pt(0.43, 0.70 + offset)],
            fill=highlight,
            width=max(1, int(size * 0.011 * line_scale)),
        )
        hdraw.line(
            [pt(0.57, 0.70 + offset), pt(0.81, 0.66 + offset)],
            fill=highlight,
            width=max(1, int(size * 0.011 * line_scale)),
        )
    highlight_layer.putalpha(
        Image.composite(highlight_layer.getchannel("A"), Image.new("L", (size, size), 0), mask)
    )
    canvas.alpha_composite(highlight_layer, (ox, oy))

    # Center gap between the two pages.
    draw.line(
        [pt(0.5, 0.585), pt(0.5, 0.86)],
        fill=(*NAVY, 235),
        width=max(1, int(size * 0.016 * line_scale)),
    )

    # --- Constellation nodes.
    if nodes:
        node_a, node_b, node_c = pt(0.29, 0.27), pt(0.5, 0.15), pt(0.71, 0.27)
        link_width = max(1, int(size * 0.024 * line_scale))
        for a, b in ((node_a, node_b), (node_b, node_c), (node_a, node_c)):
            draw.line([a, b], fill=(CYAN[0], CYAN[1], CYAN[2], 170), width=link_width)
        radius = size * 0.042
        for node in (node_a, node_b, node_c):
            if glow:
                halo = Image.new("RGBA", (size, size), (0, 0, 0, 0))
                hdraw = ImageDraw.Draw(halo)
                hx, hy = node[0] - ox, node[1] - oy
                hr = radius * 2.6
                hdraw.ellipse(
                    (hx - hr, hy - hr, hx + hr, hy + hr),
                    fill=(CYAN[0], CYAN[1], CYAN[2], 80),
                )
                halo = halo.filter(ImageFilter.GaussianBlur(size * 0.03))
                canvas.alpha_composite(halo, (ox, oy))
            draw.ellipse(
                (
                    node[0] - radius,
                    node[1] - radius,
                    node[0] + radius,
                    node[1] + radius,
                ),
                fill=(CYAN[0], CYAN[1], CYAN[2], 255),
            )

        # Four point star accent.
        sx, sy = pt(0.87, 0.14)
        outer, inner = size * 0.045, size * 0.017
        star = []
        for i in range(8):
            r = outer if i % 2 == 0 else inner
            angle = -math.pi / 2 + i * math.pi / 4
            star.append((sx + r * math.cos(angle), sy + r * math.sin(angle)))
        draw.polygon(star, fill=(MINT[0], MINT[1], MINT[2], 255))


def rounded_mask(size: int, radius_ratio: float = 0.22) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    radius = int(size * radius_ratio)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return mask


def make_legacy_icon(px: int) -> Image.Image:
    big = px * SS
    # Background: navy gradient with soft brand glows.
    bg = Image.new("RGBA", (big, big), (*NAVY, 255))
    bg_grad = gradient(big, [NAVY_LIGHT, NAVY, (6, 10, 21)], angle=60).convert("RGBA")
    bg.alpha_composite(bg_grad)
    for pos, color, scale in (
        ((0.78, 0.16), LAVENDER, 0.9),
        ((0.16, 0.86), CYAN, 0.8),
    ):
        glow = radial_glow(int(big * scale), color, 90)
        bg.alpha_composite(
            glow,
            (int(big * pos[0] - glow.width / 2), int(big * pos[1] - glow.height / 2)),
        )
    draw_logo(bg, (int(big * 0.14), int(big * 0.12), int(big * 0.86), int(big * 0.84)))

    # Rounded square mask for the legacy icon.
    bg.putalpha(rounded_mask(big, 0.22))
    return bg.resize((px, px), Image.LANCZOS)


def make_adaptive_foreground(px: int) -> Image.Image:
    big = px * SS
    canvas = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    safe = int(big * 0.56)
    offset = (big - safe) // 2
    draw_logo(canvas, (offset, offset, offset + safe, offset + safe))
    return canvas.resize((px, px), Image.LANCZOS)


def make_splash_logo(px: int = 512) -> Image.Image:
    big = px * SS
    canvas = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    glow = radial_glow(int(big * 0.9), LAVENDER, 60)
    canvas.alpha_composite(glow, ((big - glow.width) // 2, (big - glow.height) // 2))
    draw_logo(canvas, (int(big * 0.10), int(big * 0.10), int(big * 0.90), int(big * 0.90)))
    return canvas.resize((px, px), Image.LANCZOS)


def make_feature_graphic(width: int = 1024, height: int = 500) -> Image.Image:
    scale = 2
    w, h = width * scale, height * scale
    canvas = Image.new("RGBA", (w, h), (*NAVY, 255))

    # Background gradient.
    bg_grad = gradient(max(w, h), [NAVY_LIGHT, NAVY, (6, 9, 19)], angle=20).convert("RGBA")
    bg_grad = bg_grad.resize((w, h))
    canvas.alpha_composite(bg_grad)

    # Brand glows.
    for pos, color, size, alpha in (
        ((0.82, 0.10), LAVENDER, 0.62, 120),
        ((0.20, 0.95), CYAN, 0.55, 90),
        ((0.55, 0.55), MINT, 0.35, 45),
    ):
        glow = radial_glow(int(min(w, h) * size), color, alpha)
        canvas.alpha_composite(
            glow, (int(w * pos[0] - glow.width / 2), int(h * pos[1] - glow.height / 2))
        )

    # Subtle constellation kept to the margins so it never crosses the text.
    draw = ImageDraw.Draw(canvas)
    nodes = [
        (0.72, 0.06), (0.82, 0.14), (0.91, 0.06), (0.975, 0.18),
        (0.62, 0.90), (0.74, 0.84), (0.86, 0.92), (0.96, 0.80),
        (0.55, 0.05), (0.99, 0.40),
    ]
    pts = [(x * w, y * h) for x, y in nodes]
    for a, b in ((0, 1), (1, 2), (2, 3), (5, 6), (6, 3), (4, 5), (0, 8), (7, 6)):
        draw.line([pts[a], pts[b]], fill=(146, 124, 255, 55), width=2 * scale)
    for p in pts:
        draw.ellipse(
            (p[0] - 2 * scale, p[1] - 2 * scale, p[0] + 2 * scale, p[1] + 2 * scale),
            fill=(101, 200, 245, 100),
        )

    # Brand mark.
    logo_size = int(h * 0.5)
    logo_x, logo_y = int(w * 0.035), int((h - logo_size) / 2)
    draw_logo(canvas, (logo_x, logo_y, logo_x + logo_size, logo_y + logo_size))

    # Text.
    font_bold = ImageFont.truetype(
        str(FONT_DIR / "Manrope-ExtraBold.ttf"), int(h * 0.14)
    )
    font_tagline = ImageFont.truetype(
        str(FONT_DIR / "Manrope-SemiBold.ttf"), int(h * 0.058)
    )
    font_small = ImageFont.truetype(
        str(FONT_DIR / "Manrope-Medium.ttf"), int(h * 0.044)
    )
    text_x = int(w * 0.29)
    text_y = int(h * 0.28)
    draw.text((text_x, text_y), "SO‘Z ATLAS", font=font_bold, fill=WHITE)
    draw.text(
        (text_x, text_y + int(h * 0.175)),
        "Ingliz so‘zlarini oson va doimiy yodlang",
        font=font_tagline,
        fill=(163, 174, 204, 255),
    )
    draw.text(
        (text_x, text_y + int(h * 0.265)),
        "100 ta so‘z  ·  A1–A2  ·  To‘liq offline",
        font=font_small,
        fill=(126, 137, 168, 255),
    )

    # Gradient accent bar.
    bar = (
        gradient(int(w * 0.32), [LAVENDER, CYAN, MINT], angle=0)
        .resize((int(w * 0.32), int(h * 0.016)))
        .convert("RGBA")
    )
    canvas.alpha_composite(bar, (text_x, text_y + int(h * 0.40)))
    return canvas.resize((width, height), Image.LANCZOS)


def main() -> None:
    densities = {
        "mdpi": 1.0,
        "hdpi": 1.5,
        "xhdpi": 2.0,
        "xxhdpi": 3.0,
        "xxxhdpi": 4.0,
    }
    for density, factor in densities.items():
        folder = ANDROID_RES / f"mipmap-{density}"
        folder.mkdir(parents=True, exist_ok=True)
        legacy_px = int(round(48 * factor))
        make_legacy_icon(legacy_px).save(folder / "ic_launcher.png")
        foreground_px = int(round(108 * factor))
        make_adaptive_foreground(foreground_px).save(
            folder / "ic_launcher_foreground.png"
        )

    drawable = ANDROID_RES / "drawable"
    drawable.mkdir(parents=True, exist_ok=True)
    make_splash_logo(512).save(drawable / "splash_logo.png")

    mipmap_anydpi = ANDROID_RES / "mipmap-anydpi-v26"
    mipmap_anydpi.mkdir(parents=True, exist_ok=True)

    STORE_ASSETS.mkdir(parents=True, exist_ok=True)
    make_legacy_icon(512).save(STORE_ASSETS / "icon_512.png")
    make_feature_graphic().save(STORE_ASSETS / "feature_graphic_1024x500.png")

    print("Brand assets generated:")
    for density in densities:
        print(f"  mipmap-{density}/ic_launcher.png")
    print("  drawable/splash_logo.png")
    print("  store_assets/icon_512.png")
    print("  store_assets/feature_graphic_1024x500.png")


if __name__ == "__main__":
    main()
