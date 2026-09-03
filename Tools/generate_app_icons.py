from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "WashHead" / "Assets.xcassets"


def font(size: int):
    candidates = [
        Path("C:/Windows/Fonts/arialbd.ttf"),
        Path("/System/Library/Fonts/Supplemental/Arial Bold.ttf"),
    ]
    for candidate in candidates:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size=size)
    return ImageFont.load_default()


def draw_icon(folder: str, hair_scale: float, unknown: bool = False):
    target = CATALOG / f"{folder}.appiconset" / "icon-1024.png"
    target.parent.mkdir(parents=True, exist_ok=True)

    image = Image.new("RGB", (1024, 1024), (242, 232, 209))
    draw = ImageDraw.Draw(image)
    outline = (20, 18, 17)
    skin = (249, 186, 128)
    hair = (42, 24, 20)

    draw.ellipse((170, 394, 854, 1010), fill=skin, outline=outline, width=30)
    draw.ellipse((105, 575, 260, 745), fill=skin)
    draw.ellipse((764, 575, 919, 745), fill=skin)

    center_x, center_y = 512, 340
    cloud_width = int(730 * hair_scale)
    cloud_height = int(440 * hair_scale)
    left = center_x - cloud_width // 2
    top = center_y - cloud_height // 2
    draw.ellipse((left, top, left + cloud_width, top + cloud_height), fill=hair, outline=outline, width=28)
    for dx, dy, radius in [
        (-260, 30, 150), (-155, -90, 175), (0, -130, 195),
        (165, -80, 170), (270, 35, 145),
    ]:
        radius = int(radius * hair_scale)
        x = center_x + int(dx * hair_scale)
        y = center_y + int(dy * hair_scale)
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=hair)

    if hair_scale < 1.52:
        for eye_x in (395, 629):
            draw.ellipse((eye_x - 55, 585, eye_x + 55, 665), fill="white", outline=outline, width=18)
            draw.ellipse((eye_x - 15, 610, eye_x + 15, 640), fill=outline)
        draw.rounded_rectangle((430, 795, 594, 830), radius=18, fill=outline)

    if unknown:
        text = "?"
        question_font = font(370)
        box = draw.textbbox((0, 0), text, font=question_font)
        width = box[2] - box[0]
        draw.text(((1024 - width) / 2, 310), text, font=question_font, fill="white", stroke_width=14, stroke_fill=outline)

    image.save(target, format="PNG", optimize=True)


draw_icon("AppIcon", 1.00)
draw_icon("AppIconPuffy", 1.20)
draw_icon("AppIconMax", 1.62)
draw_icon("AppIconUnknown", 1.20, unknown=True)
