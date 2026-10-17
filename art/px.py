"""A small canvas of letters for pixel art: shapes are filled with a letter
(a colour of the palette), then an outline of black is laid round what is
filled, the way the sprites of a 1980s console were drawn. Shapes take a
transform, so one pose can be turned or leaned without being drawn again."""
import math


class Canvas:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.px = [["." for _ in range(w)] for _ in range(h)]
        # Where shapes land: turned by `turn` degrees round `pivot`, then moved.
        self.turn, self.pivot, self.shift = 0.0, (0.0, 0.0), (0.0, 0.0)

    def where(self, x, y):
        """A point of a shape, through the transform."""
        a = math.radians(self.turn)
        px, py = self.pivot
        dx, dy = x - px, y - py
        return (px + dx * math.cos(a) - dy * math.sin(a) + self.shift[0],
                py + dx * math.sin(a) + dy * math.cos(a) + self.shift[1])

    def back(self, x, y):
        """A pixel of the canvas, back into the shapes' own room."""
        a = math.radians(-self.turn)
        px, py = self.pivot
        x, y = x - self.shift[0] - px, y - self.shift[1] - py
        return (px + x * math.cos(a) - y * math.sin(a), py + x * math.sin(a) + y * math.cos(a))

    def put(self, x, y, c):
        x, y = int(x), int(y)
        if 0 <= x < self.w and 0 <= y < self.h:
            self.px[y][x] = c

    def get(self, x, y):
        if 0 <= x < self.w and 0 <= y < self.h:
            return self.px[y][x]
        return "."

    def fill(self, inside, c, box=None):
        """Every pixel whose centre, taken back into the shape's room, is inside."""
        for y in range(self.h):
            for x in range(self.w):
                sx, sy = self.back(x + 0.5, y + 0.5)
                if inside(sx, sy):
                    self.px[y][x] = c

    def ellipse(self, cx, cy, rx, ry, c, tilt=0.0):
        t = math.radians(tilt)
        def inside(x, y):
            dx, dy = x - cx, y - cy
            u = dx * math.cos(t) + dy * math.sin(t)
            v = -dx * math.sin(t) + dy * math.cos(t)
            return (u / rx) ** 2 + (v / ry) ** 2 <= 1.0
        self.fill(inside, c)

    def rect(self, x0, y0, x1, y1, c):
        self.fill(lambda x, y: x0 <= x < x1 and y0 <= y < y1, c)

    def poly(self, pts, c):
        def inside(x, y):
            n, ok = len(pts), False
            j = n - 1
            for i in range(n):
                xi, yi = pts[i]
                xj, yj = pts[j]
                if (yi > y) != (yj > y) and x < (xj - xi) * (y - yi) / (yj - yi) + xi:
                    ok = not ok
                j = i
            return ok
        self.fill(inside, c)

    def stroke(self, pts, width, c):
        """A thick line through the points, with round ends."""
        r = width / 2
        def inside(x, y):
            for (ax, ay), (bx, by) in zip(pts, pts[1:]):
                vx, vy = bx - ax, by - ay
                l2 = vx * vx + vy * vy or 1e-9
                t = max(0, min(1, ((x - ax) * vx + (y - ay) * vy) / l2))
                if (ax + vx * t - x) ** 2 + (ay + vy * t - y) ** 2 <= r * r:
                    return True
            return False
        self.fill(inside, c)

    def dot(self, x, y, c):
        """One pixel, placed through the transform."""
        X, Y = self.where(x, y)
        self.put(math.floor(X), math.floor(Y), c)

    def outline(self, c="K", diagonal=False):
        """Black round everything filled, where it meets nothing."""
        add = []
        for y in range(self.h):
            for x in range(self.w):
                if self.px[y][x] != ".":
                    continue
                near = [(1, 0), (-1, 0), (0, 1), (0, -1)]
                if diagonal:
                    near += [(1, 1), (1, -1), (-1, 1), (-1, -1)]
                if any(self.get(x + dx, y + dy) not in ".K" or (self.get(x + dx, y + dy) == "K" and False) for dx, dy in near):
                    add.append((x, y))
        for x, y in add:
            self.px[y][x] = c

    def edge(self, a, b, c="K"):
        """A line of `c` where colour `a` meets colour `b`, on the `a` side."""
        add = []
        for y in range(self.h):
            for x in range(self.w):
                if self.px[y][x] == a and any(self.get(x + dx, y + dy) == b for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    add.append((x, y))
        for x, y in add:
            self.px[y][x] = c

    def rows(self):
        return ["".join(r) for r in self.px]

    def reset(self):
        self.turn, self.pivot, self.shift = 0.0, (0.0, 0.0), (0.0, 0.0)


def mirror(rows):
    return [r[::-1] for r in rows]


def from_text(text, w, h):
    """Rows typed by hand, padded to the cell."""
    rows = [r for r in text.strip("\n").split("\n")]
    rows = [r.rstrip() for r in rows]
    out = [r.ljust(w, ".")[:w] for r in rows]
    while len(out) < h:
        out.append("." * w)
    return out[:h]


def half(text, w, h):
    """The left half typed by hand, the right half its mirror."""
    rows = from_text(text, w // 2, h)
    return [r + r[::-1] for r in rows]
