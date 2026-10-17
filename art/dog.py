"""The dog: brown, black ears, a white muzzle and chest. Drawn from shapes so
that a pose is a few numbers, then outlined in black."""
from px import Canvas

W, H = 56, 48


def side(legs=0, head="sniff", nose=0, turn=0.0, tuck=False, mouth=False):
    """In profile, facing right. `legs` 0–3 is the step of the walk."""
    c = Canvas(W, H)
    c.pivot, c.turn = (26, 28), turn
    # The tail, standing up.
    c.stroke([(12, 24), (9, 17), (8, 11), (10, 7)], 3.2, "B")
    # The legs: back pair and front pair, each pair swinging against the other.
    swing = [(-3, 2), (-1, 0), (2, -3), (0, -1)][legs % 4]
    for x, s in ((14, swing[0]), (19, swing[1]), (31, swing[1]), (36, swing[0])):
        if tuck:
            c.stroke([(x, 30), (x + 6, 37)], 4, "B")
        else:
            c.stroke([(x, 30), (x + s * 0.5, 38), (x + s, 43)], 4, "B")
            c.ellipse(x + s + 1, 44, 2.6, 1.6, "B")
    c.ellipse(25, 27, 14, 7.5, "B")
    if head == "sniff":
        c.poly([(32, 21), (39, 21), (47, 32 + nose), (37, 34)], "B")
        c.ellipse(43, 31 + nose, 6.5, 5.5, "B", tilt=30)
        c.ellipse(48, 37 + nose, 4.6, 3.0, "W", tilt=50)
        c.ellipse(50.6, 40.6 + nose, 1.8, 1.5, "K")
        c.poly([(38, 26 + nose), (43, 26 + nose), (42, 37 + nose), (38, 40 + nose), (35.5, 33 + nose)], "K")
        c.rect(44, 28 + nose, 46, 30 + nose, "W")
        c.dot(45, 29 + nose, "K")
        c.ellipse(38, 28, 2.2, 3, "W")
    else:
        c.poly([(31, 22), (37, 15), (43, 15), (38, 28)], "B")
        c.ellipse(42, 13, 6.5, 5.5, "B")
        c.ellipse(48.5, 15, 4.6, 3.0, "W")
        c.ellipse(52.4, 13.6, 1.6, 1.4, "K")
        if mouth:
            c.poly([(45, 17), (52, 17), (50, 20), (46, 20)], "K")
        # The ear: up when it is surprised, hanging otherwise.
        if head == "alert":
            c.poly([(37, 9), (33, 1), (36.5, 0.5), (42, 8)], "K")
        else:
            c.poly([(37, 9), (41, 9), (40, 21), (36, 23), (34.5, 16)], "K")
        c.rect(43, 10, 46, 13, "W")
        c.rect(44, 11, 46, 13, "K")
        c.ellipse(37, 26, 2.2, 3.2, "W")
    c.outline()
    return c.rows()


def front(arms=0, laugh=None, bob=0):
    """Facing us, from the chest up: what is seen of it over the grass.
    `arms`: 0 none raised, 1 the right one, 2 both. `laugh`: 0 or 1, the two
    pictures of its laugh."""
    c = Canvas(W, H)
    y = bob
    # Body and the white of its chest.
    c.ellipse(28, 42 + y, 12, 12, "B")
    c.ellipse(28, 40 + y, 6, 7, "W")
    # Arms held up, each with a paw at the top (where a duck is held).
    if arms >= 1:
        c.stroke([(36, 36 + y), (44, 26 + y), (48, 15 + y)], 4.5, "B")
        c.ellipse(48.5, 13.5 + y, 3, 2.6, "B")
    if arms >= 2:
        c.stroke([(20, 36 + y), (12, 26 + y), (8, 15 + y)], 4.5, "B")
        c.ellipse(7.5, 13.5 + y, 3, 2.6, "B")
    if laugh is not None:
        # Hands on its belly, shaking.
        c.stroke([(19, 38 + y), (24, 44 + y)], 4, "B")
        c.stroke([(37, 38 + y), (32, 44 + y)], 4, "B")
    # The head, its ears flung out, its eyes, muzzle and nose.
    c.ellipse(28, 17 + y, 10.5, 10, "B")
    c.ellipse(16.5, 15 + y, 3.6, 8.5, "K", tilt=20)
    c.ellipse(39.5, 15 + y, 3.6, 8.5, "K", tilt=-20)
    c.ellipse(28, 24 + y, 7.5, 5.5, "W")
    if laugh is None:
        c.ellipse(24.2, 12.5 + y, 3.2, 4.2, "W")
        c.ellipse(31.8, 12.5 + y, 3.2, 4.2, "W")
        c.rect(24, 13 + y, 26, 16 + y, "K")
        c.rect(30, 13 + y, 32, 16 + y, "K")
        # A grin, glad.
        c.poly([(23, 26 + y), (33, 26 + y), (31, 29 + y), (25, 29 + y)], "K")
    else:
        # Eyes shut tight with laughing; a mouth open wide.
        for x in (22, 23, 24, 25, 26):
            c.put(x, 13 + y - (1 if x in (23, 24, 25) else 0), "K")
        for x in (30, 31, 32, 33, 34):
            c.put(x, 13 + y - (1 if x in (31, 32, 33) else 0), "K")
        open_ = 4 if laugh == 0 else 3
        c.poly([(22.5, 25 + y), (33.5, 25 + y), (31, 26 + open_ + y), (25, 26 + open_ + y)], "K")
        c.rect(26, 27 + open_ - 2 + y, 30, 26 + open_ + y, "R")
    c.ellipse(28, 20.5 + y, 3.4, 2.4, "K")
    c.outline()
    return c.rows()


def frames():
    out = []
    for k in range(4):
        out.append(side(legs=k))
    out.append(side(legs=1, nose=0))
    out.append(side(legs=1, nose=-2))
    out.append(side(legs=1, head="alert", mouth=True))
    out.append(side(legs=0, head="up", turn=-32, tuck=True))
    out.append(side(legs=0, head="up", turn=38, tuck=True))
    out.append(front(arms=1))
    out.append(front(arms=2))
    out.append(front(laugh=0))
    out.append(front(laugh=1, bob=1))
    return out
