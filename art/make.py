"""Draws every picture of the game into pieces/: python3 art/make.py
(with `preview` it also writes art/preview-*.png, six times bigger, to look at).

Everything here is drawn by this script, letter by letter or from shapes, in
the colours of the console's palette: nothing is taken from any game."""
import os
import sys
from PIL import Image

sys.path.insert(0, os.path.dirname(__file__))
import px  # noqa: E402
import dog  # noqa: E402
import ducks  # noqa: E402
import field  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "pieces")

# The console's colours the game uses.
NES = {
    "black": "#000000", "white": "#fcfcfc", "sky": "#3cbcfc", "pink": "#fcbcb0",
    "grass": "#80d010", "leaf": "#00a800", "trunk": "#881400", "bark": "#503000",
    "dirt": "#887000", "brown": "#c84c0c", "orange": "#fca044", "salmon": "#fc7460",
    "red": "#d82800", "blue": "#0058f8", "navy": "#0000bc", "magenta": "#d800cc",
    "maroon": "#a81000", "grey": "#bcbcbc", "green": "#00a844", "olive": "#ac7c00",
    "cream": "#fce0a8", "teal": "#008888",
}

DOG = {"K": NES["black"], "W": NES["white"], "B": NES["brown"], "R": NES["red"]}


def rgba(hexs):
    h = hexs.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255)


def sheet(name, frames, w, h, palettes, columns=None):
    """One picture per cell, each with a pixel of nothing round it; a row per palette."""
    columns = columns or len(frames)
    rows_n = ((len(frames) + columns - 1) // columns) * len(palettes)
    cw, ch = w + 2, h + 2
    im = Image.new("RGBA", (cw * columns, ch * rows_n), (0, 0, 0, 0))
    for p, pal in enumerate(palettes):
        for i, rows in enumerate(frames):
            cx = (i % columns) * cw + 1
            cy = ((i // columns) + p * ((len(frames) + columns - 1) // columns)) * ch + 1
            for y, row in enumerate(rows[:h]):
                for x, ch_ in enumerate(row[:w]):
                    if ch_ != "." and ch_ in pal:
                        im.putpixel((cx + x, cy + y), rgba(pal[ch_]))
                    elif ch_ != ".":
                        raise SystemExit(f"{name}: frame {i} has '{ch_}' at {x},{y}, not in its palette")
    im.save(os.path.join(OUT, name + ".png"))
    print(f"{name}.png  {im.size[0]}×{im.size[1]}  cells of {cw}×{ch}, {columns} across")
    return im


def preview(name, im, k=6, sky=NES["sky"]):
    bg = Image.new("RGBA", im.size, rgba(sky))
    bg.alpha_composite(im)
    bg = bg.resize((im.size[0] * k, im.size[1] * k), Image.NEAREST)
    bg.save(os.path.join(HERE, "preview-" + name + ".png"))


def main():
    os.makedirs(OUT, exist_ok=True)
    want = "preview" in sys.argv
    made = {}
    made["dog"] = sheet("dog", dog.frames(), dog.W, dog.H, [DOG])
    duck_frames = ducks.frames()
    made["ducks"] = sheet("ducks", duck_frames, ducks.W, ducks.H, ducks.palettes(NES), columns=len(duck_frames))
    for name, (frames, w, h, pal, cols) in field.sheets(NES).items():
        made[name] = sheet(name, frames, w, h, [pal], columns=cols)
    for name, im in field.pictures(NES).items():
        im.save(os.path.join(OUT, name + ".png"))
        print(f"{name}.png  {im.size[0]}×{im.size[1]}")
        made[name] = im
    if want:
        for name, im in made.items():
            preview(name, im, k=4 if im.size[0] > 300 else 6)


if __name__ == "__main__":
    main()
