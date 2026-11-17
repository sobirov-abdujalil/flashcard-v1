"""Creates Play-Store-ready screenshot frames from real device captures.

Run from the project root:
    python tool/make_store_screenshots.py

Google Play requires phone screenshots with an aspect ratio between 16:9 and
9:16. The test phone captures are 720x1640 (taller than 9:16), so each capture
is placed on a 1080x1920 brand canvas without changing the app UI itself.
"""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
SCREENSHOTS = ROOT / "screenshots"
OUT = ROOT / "store_assets" / "screenshots"

CANVAS = (1080, 1920)
NAVY = (9, 14, 29)
NAVY_LIGHT = (17, 26, 45)
LAVENDER = (146, 124, 255)
CYAN = (101, 200, 245)


def _glow(size: int, color, alpha: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    steps = 36
    for i in range(steps, 0, -1):
        t = i / steps
        r = int(size * 0.5 * t)
        a = int(alpha * (1 - t) ** 2)
        draw.ellipse(
            (size // 2 - r, size // 2 - r, size // 2 + r, size // 2 + r),
            fill=(color[0], color[1], color[2], a),
        )
    return img.filter(ImageFilter.GaussianBlur(size * 0.06))


def background() -> Image.Image:
    w, h = CANVAS
    img = Image.new("RGBA", CANVAS, (*NAVY, 255))
    # Vertical gradient.
    gradient = Image.new("RGBA", (1, h))
    gdraw = ImageDraw.Draw(gradient)
    for y in range(h):
        t = y / (h - 1)
        r = int(NAVY_LIGHT[0] + (NAVY[0] - NAVY_LIGHT[0]) * t)
        g = int(NAVY_LIGHT[1] + (NAVY[1] - NAVY_LIGHT[1]) * t)
        b = int(NAVY_LIGHT[2] + (NAVY[2] - NAVY_LIGHT[2]) * t)
        gdraw.line((0, y, 1, y), fill=(r, g, b, 255))
    img.alpha_composite(gradient.resize(CANVAS))

    for pos, color, size, alpha in (
        ((0.15, 0.08), LAVENDER, 900, 90),
        ((0.9, 0.9), CYAN, 900, 70),
    ):
        glow = _glow(size, color, alpha)
        img.alpha_composite(
            glow,
            (int(w * pos[0] - glow.width / 2), int(h * pos[1] - glow.height / 2)),
        )
    return img


def frame(source: Path, destination: Path) -> None:
    shot = Image.open(source).convert("RGBA")
    # Phone captures include the system status bar and gesture bar; crop them
    # for a cleaner store screenshot. (Emulator captures at 1080 wide are left
    # as-is.)
    if shot.width < 900 and shot.height > 1200:
        shot = shot.crop((0, 46, shot.width, shot.height - 26))
    canvas = background()
    w, h = CANVAS
    margin = 64
    target_h = h - margin * 2
    scale = target_h / shot.height
    target_w = int(shot.width * scale)
    if target_w > w - margin * 2:
        target_w = w - margin * 2
        target_h = int(shot.height * (target_w / shot.width))
        scale = target_h / shot.height
    resized = shot.resize((target_w, target_h), Image.LANCZOS)

    radius = 32
    mask = Image.new("L", resized.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, resized.width - 1, resized.height - 1), radius=radius, fill=255
    )

    x = (w - target_w) // 2
    y = (h - target_h) // 2

    # Soft shadow behind the framed screenshot.
    shadow = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    sdraw.rounded_rectangle(
        (x - 12, y - 12, x + target_w + 12, y + target_h + 12),
        radius=radius + 12,
        fill=(0, 0, 0, 190),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(36))
    canvas.alpha_composite(shadow)

    # Thin gradient-ish border.
    border = ImageDraw.Draw(canvas)
    border.rounded_rectangle(
        (x - 3, y - 3, x + target_w + 3, y + target_h + 3),
        radius=radius + 3,
        outline=(255, 255, 255, 46),
        width=2,
    )

    canvas.paste(resized, (x, y), mask)
    canvas.convert("RGB").save(destination, quality=95)
    print(f"{destination.name}: {CANVAS[0]}x{CANVAS[1]}")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    mapping = {
        "store_assets/screenshots/01_home_light.png": "01_home_light.png",
        "store_assets/screenshots/02_learn_light.png": "02_learn_light.png",
        "store_assets/screenshots/03_recall_light.png": "03_recall_light_teacher.png",
    }
    for folder_name, source_name in mapping.items():
        source = SCREENSHOTS / source_name
        if not source.exists():
            print(f"missing: {source}")
            continue
        frame(source, ROOT / folder_name)


if __name__ == "__main__":
    main()
