"""The marsh (tree, bush, tall grass and the dirt under it, the sky left
empty), the clay range, and the small pieces: the board's icons, the clays and
the sight. Drawn here with a fixed seed: the same every time."""
import math
import random
from PIL import Image
from px import from_text

SCREEN = (256, 240)
GRASS_TOP = 148   # where the tall grass begins (its blades reach higher)
DIRT_TOP = 183    # where the dirt begins, and the board on it


def rgba(h):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255)


class Pic:
    def __init__(self, w, h):
        self.im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        self.w, self.h = w, h

    def put(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.im.putpixel((int(x), int(y)), rgba(c))

    def get(self, x, y):
        if 0 <= x < self.w and 0 <= y < self.h:
            return self.im.getpixel((int(x), int(y)))
        return (0, 0, 0, 0)

    def rect(self, x0, y0, x1, y1, c):
        for y in range(int(y0), int(y1)):
            for x in range(int(x0), int(x1)):
                self.put(x, y, c)


def clump(p, cx, cy, r, fill, rim, seed, specks=None):
    """A rounded mass of leaves: a scalloped edge in `rim`, `fill` inside."""
    rnd = random.Random(seed)
    phase, lobes = rnd.random() * 6.28, rnd.choice([6, 7, 8])
    inside = set()
    for y in range(int(cy - r - 3), int(cy + r + 4)):
        for x in range(int(cx - r - 3), int(cx + r + 4)):
            a = math.atan2(y - cy, x - cx)
            edge = r + 1.6 * abs(math.sin(a * lobes / 2 + phase))
            if math.hypot(x + 0.5 - cx, y + 0.5 - cy) <= edge:
                inside.add((x, y))
    for (x, y) in inside:
        boundary = any((x + dx, y + dy) not in inside for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
        p.put(x, y, rim if boundary else fill)
    if specks:
        for (x, y) in inside:
            # Leaves inside: short curves of the dark colour, in rows.
            if (x * 7 + y * 13 + seed) % 23 == 0 and (x + 1, y) in inside and (x - 1, y) in inside:
                p.put(x, y, specks)
                p.put(x + 1, y + 1, specks)
                p.put(x - 1, y + 1, specks)


def line(p, x0, y0, x1, y1, width, c):
    n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
    for i in range(n + 1):
        t = i / n
        x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
        r = width / 2
        for yy in range(int(y - r), int(y + r) + 1):
            for xx in range(int(x - r), int(x + r) + 1):
                if (xx + 0.5 - x) ** 2 + (yy + 0.5 - y) ** 2 <= r * r:
                    p.put(xx, yy, c)


def grass(p, nes, top, bottom, seed=7):
    """Tall grass: blades of light green with dark strokes and white tips."""
    rnd = random.Random(seed)
    light, dark, white = nes["grass"], nes["leaf"], nes["white"]
    p.rect(0, top, p.w, bottom, light)
    # The ragged top: blades of different heights.
    x = 0
    while x < p.w:
        h = rnd.choice([2, 3, 4, 5, 6, 7, 8, 4, 3])
        w = rnd.choice([1, 2, 2, 3])
        for k in range(w):
            for y in range(top - h + (k if w > 1 and k == w - 1 else 0), top):
                p.put(x + k, y, light)
        x += w + rnd.choice([0, 1, 1, 2])
    # Dark strokes, longer and more of them towards the bottom.
    for _ in range(int(p.w * 2.2)):
        x = rnd.randrange(p.w)
        y = rnd.randrange(top - 2, bottom - 3)
        n = rnd.randrange(3, 9)
        lean = rnd.choice([-1, 0, 0, 1])
        for k in range(n):
            if top - 4 <= y + k < bottom:
                p.put(x + (lean if k > n // 2 else 0), y + k, dark)
    # White blades near the top, like light catching them.
    for _ in range(int(p.w * 0.55)):
        x = rnd.randrange(p.w)
        y = rnd.randrange(top - 6, top + 14)
        n = rnd.randrange(2, 6)
        lean = rnd.choice([-1, 1])
        for k in range(n):
            px_ = x + (lean if k < n // 2 else 0)
            if p.get(px_, y + k)[3]:
                p.put(px_, y + k, white)


def dirt(p, nes, top, seed=11):
    rnd = random.Random(seed)
    p.rect(0, top, p.w, p.h, nes["dirt"])
    p.rect(0, top, p.w, top + 1, nes["bark"])
    for x in range(0, p.w, 2):
        if rnd.random() < 0.5:
            p.put(x, top + 1, nes["bark"])
    for _ in range(int(p.w * 0.9)):
        x, y = rnd.randrange(p.w), rnd.randrange(top + 3, p.h)
        p.put(x, y, nes["bark"])
        if rnd.random() < 0.6:
            p.put(x + 1, y, nes["bark"])


def marsh(nes):
    """Games A and B: the tree on the left, the bush on the right, the grass
    and the dirt. The sky is left empty: the scene paints it, blue or pink."""
    p = Pic(*SCREEN)
    trunk, bark, black = nes["trunk"], nes["bark"], nes["black"]
    light, dark = nes["grass"], nes["leaf"]
    # The branches out to the leaves, then the trunk over their roots, wider at the foot.
    for (x0, y0, x1, y1, w) in ((35, 80, 12, 58, 3), (36, 68, 60, 50, 3), (36, 100, 66, 84, 3), (35, 52, 22, 30, 2.5),
                                (37, 44, 52, 20, 2.5), (34, 118, 14, 98, 2.5), (38, 110, 52, 104, 2)):
        line(p, x0, y0, x1, y1, w + 2, black)
        line(p, x0, y0, x1, y1, w, trunk)
    for y in range(26, GRASS_TOP + 4):
        t = (y - 26) / (GRASS_TOP - 26)
        half = 4 + 3 * t
        cx = 36 - 2 * t
        for x in range(int(cx - half), int(cx + half) + 1):
            p.put(x, y, trunk)
        p.put(int(cx - half) - 1, y, black)
        p.put(int(cx + half) + 1, y, black)
        if y % 9 in (2, 3, 4):
            p.put(int(cx - 1), y, bark)
        if y % 13 in (6, 7):
            p.put(int(cx + 2), y, bark)
    for i, (cx, cy, r) in enumerate(((18, 22, 12), (46, 14, 12), (62, 40, 11), (14, 54, 11), (64, 78, 10),
                                     (34, 34, 9), (16, 94, 9), (50, 60, 7), (8, 76, 7))):
        clump(p, cx, cy, r, light, dark, seed=100 + i, specks=dark)
    # The bush on the right, darker, standing in the grass.
    for i, (cx, cy, r) in enumerate(((206, 138, 13), (222, 126, 11), (232, 146, 10), (196, 152, 9), (214, 112, 8))):
        clump(p, cx, cy, r, dark, nes["deep"], seed=200 + i, specks=light)
    grass(p, nes, GRASS_TOP, DIRT_TOP)
    dirt(p, nes, DIRT_TOP)
    return p.im


def range_(nes):
    """Game C: a mown field going away to a far line of trees."""
    p = Pic(*SCREEN)
    horizon = 132
    for i in range(40):
        cx = i * 7 + (i % 3)
        clump(p, cx, horizon - 2 - (i * 5 % 7), 6 + (i * 3 % 4), nes["leaf"], nes["deep"], seed=300 + i)
    p.rect(0, horizon, 256, DIRT_TOP, nes["grass"])
    # Rows of the mown grass, closer together as they go away.
    y, gap = float(horizon + 2), 2.0
    k = 0
    while y < DIRT_TOP:
        if k % 2 == 0:
            p.rect(0, int(y), 256, int(y + gap * 0.5), nes["leaf"])
        y += gap
        gap *= 1.35
        k += 1
    # The trap house the clays come from, low in the middle.
    p.rect(108, 166, 148, 182, nes["bark"])
    p.rect(110, 168, 146, 176, nes["olive"])
    p.rect(108, 164, 148, 166, nes["black"])
    p.rect(112, 170, 144, 172, nes["black"])
    dirt(p, nes, DIRT_TOP, seed=12)
    return p.im


HUD = [
    """
.....WW.
....WWWW
....WWO.
W..WWWW.
WWWWWWW.
.WWWWWW.
..WWWW..
""",
    """
.....RR.
....RRRR
....RRO.
R..RRRR.
RRRRRRR.
.RRRRRR.
..RRRR..
""",
    """
........
..WWWW..
.WWWWWW.
WWWWWWWW
.WWWWWW.
........
""",
    """
........
..RRRR..
.RRRRRR.
RRRRRRRR
.RRRRRR.
........
""",
    """
...WW...
..WWWW..
..WWWW..
..WWWW..
..WWWW..
..OOOO..
..OOOO..
..KKKK..
""",
]

SIGHT = """
.......K.......
......KWK......
......KWK......
......KWK......
......KWK......
.......K.......
.KKKK.....KKKK.
KWWWW..W..WWWWK
.KKKK.....KKKK.
.......K.......
......KWK......
......KWK......
......KWK......
......KWK......
.......K.......
"""


def clays():
    """A clay, from close to far, and broken."""
    frames = []
    for r in (8, 7, 6, 5, 4, 3, 2, 1.4):
        rows = [["."] * 16 for _ in range(10)]
        for y in range(10):
            for x in range(16):
                dx, dy = (x + 0.5 - 8) / r, (y + 0.5 - 5) / (r * 0.55)
                d = dx * dx + dy * dy
                if d <= 1.0:
                    rows[y][x] = "O" if dy > -0.2 else "W"
                    if d > 0.55 and r >= 3:
                        rows[y][x] = "K" if d > 0.8 else rows[y][x]
        frames.append(["".join(r) for r in rows])
    frames.append(from_text("""
..KK.......K....
.KOOK.....KOK...
..KOOK...KOOK...
...KK.....KK....
.......KK.......
......KOOK......
.KK....KK....KK.
KOOK........KOOK
.KK..........KK.
""", 16, 10))
    frames.append(from_text("""
K..............K
.K....K...K...K.
......K....K....
................
..K..........K..
.......KK.......
K..............K
................
....K......K....
""", 16, 10))
    return frames


def sheets(nes):
    nes.setdefault("deep", "#005800")
    hud = {"W": nes["white"], "R": nes["red"], "O": nes["orange"], "K": nes["black"]}
    clay = {"O": "#e45c10", "W": nes["cream"], "K": nes["black"]}
    sight = {"K": nes["black"], "W": nes["white"]}
    return {
        "hud": ([from_text(t, 8, 8) for t in HUD], 8, 8, hud, len(HUD)),
        "clay": (clays(), 16, 10, clay, 10),
        "sight": ([from_text(SIGHT, 15, 15)], 15, 15, sight, 1),
    }


def pictures(nes):
    nes.setdefault("deep", "#005800")
    return {"marsh": marsh(nes), "range": range_(nes)}
