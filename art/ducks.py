"""The ducks, drawn letter by letter, facing right; those facing left are
their mirror. H head, D body, L wing, C breast, O beak, F feet, E eye's white,
K black. Three kinds, the same drawing in three palettes."""
from px import from_text, half, mirror

W, H = 32, 32

UP = """
...........KK
..........KLLK
.........KLLLK
........KLLLLK
.......KLLLLK.........KKKK
......KLLLLLK........KHHHHK
......KLLLLK........KHHHHHHK
.....KLLLLLK........KHHEEEHK
.....KLLLLK.........KHHEKKHKOO
....KLLLLLK.........KHHEKKHKOOO
....KLLLLK...........KHHHHHKOOOO
...KLLLLLK..........KHHHHKKOOOK
...KLLLLK...........KHHHKK.KKK
..KKKLLLKKKKKKKKKKKKEEEEK
.KDDDKKKDDDDDDDDDDDDDDDK
KDDDDDDDDDDDDDDDDDDDDDCK
KDDDDDDDDDDDDDDDDDDDDCCK
.KDDDDDDDDDDDDDDDDDDCCCK
..KDDDDDDDDDDDDDDDDCCCCK
...KCCDDDDDDDDDDDCCCCCK
....KKCCCCCCCCCCCCCCKK
......KKKKKKKKKKKKKK
..........KFFK.KFFK
...........KK...KK
"""

MID = """
....
....
....
....
......................KKKK
.....................KHHHHK
....................KHHHHHHK
....................KHHEEEHK
....................KHHEKKHKOO
....................KHHEKKHKOOO
.....................KHHHHHKOOOO
......KKKKKKK.......KHHHHKKOOOK
....KKLLLLLLLKK.....KHHHKK.KKK
..KKLLLLLLLLLLLKKKKKEEEEK
.KDDKKKLLLLLLLLLLKDDDDDK
KDDDDDDKKKKLLLLLLKDDDDCK
KDDDDDDDDDDKKKKKKDDDDCCK
.KDDDDDDDDDDDDDDDDDDCCCK
..KDDDDDDDDDDDDDDDDCCCCK
...KCCDDDDDDDDDDDCCCCCK
....KKCCCCCCCCCCCCCCKK
......KKKKKKKKKKKKKK
..........KFFK.KFFK
...........KK...KK
"""

DOWN = """
....
....
....
....
......................KKKK
.....................KHHHHK
....................KHHHHHHK
....................KHHEEEHK
....................KHHEKKHKOO
....................KHHEKKHKOOO
.....................KHHHHHKOOOO
....................KHHHHKKOOOK
....................KHHHKK.KKK
......KKKKKKKKKKKKKKEEEEK
...KKKDDDDDDDDDDDDDDDDDK
.KKDDDDDDDDDDDDDDDDDDDCK
KDDDDDDKKKKKKKKKDDDDDCCK
KDDDDDKLLLLLLLLKDDDDCCCK
.KDDDKLLLLLLLLKDDDDCCCCK
..KKKLLLLLLLLKCCCCCCCCK
....KLLLLLLLKKCCCCCCKK
....KLLLLLLK.KKKKKKK
.....KLLLLK..KFFK.KFFK
.....KLLLK....KK...KK
......KLLK
......KLK
.......K
"""

# Climbing: the body leans up to the right, the head high.
CLIMB_UP = """
.......KK...............KKKK
......KLLK.............KHHHHK
......KLLLK...........KHHEEEHK
.....KLLLLK...........KHHEKKHKOO
.....KLLLK............KHHEKKHKOOO
....KLLLLK............KHHHHHHKOOOK
....KLLLK..............KHHHHKKKKK
...KLLLLK.............KEEEEEK
...KLLLK.............KDDDDDDK
..KLLLLK............KDDDDDCCK
..KLLLK............KDDDDDCCCK
.KLLLLK...........KDDDDDCCCK
.KLLLKKKK........KDDDDDCCCCK
.KKKKDDDDKK.....KDDDDDCCCCK
....KDDDDDDKK..KDDDDDCCCCK
.....KDDDDDDDKKDDDDDCCCCK
......KDDDDDDDDDDDDDCCCK
.......KDDDDDDDDDDDCCCCK
........KDDDDDDDDDCCCK
........KDDDDDDDDCCCK
.......KDDDDDDDDCCKK
......KDDDDKKKKKKFFK
.....KDDDKK....KFFK
....KDDKK.......KK
....KKK
"""

CLIMB_MID = """
........................KKKK
.......................KHHHHK
......................KHHEEEHK
......................KHHEKKHKOO
......................KHHEKKHKOOO
......................KHHHHHHKOOOK
.......................KHHHHKKKKK
......................KEEEEEK
.....................KDDDDDDK
....................KDDDDDCCK
...................KDDDDDCCCK
..........KKKKKK..KDDDDDCCCK
........KKLLLLLLKKDDDDDCCCCK
......KKLLLLLLLLLKDDDDCCCCK
....KKLLLLLLLLLLKDDDDCCCCK
...KLLLLLLLLLLLKDDDDCCCCK
...KKKKKKKKLLLKDDDDDCCCK
.......KDDDKKKDDDDDDCCCK
........KDDDDDDDDDDCCCK
........KDDDDDDDDDCCCK
.......KDDDDDDDDCCKK
......KDDDDKKKKKKFFK
.....KDDDKK....KFFK
....KDDKK.......KK
....KKK
"""

CLIMB_DOWN = """
........................KKKK
.......................KHHHHK
......................KHHEEEHK
......................KHHEKKHKOO
......................KHHEKKHKOOO
......................KHHHHHHKOOOK
.......................KHHHHKKKKK
......................KEEEEEK
.....................KDDDDDDK
....................KDDDDDCCK
...................KDDDDDCCCK
..................KDDDDDCCCK
.................KDDDDDCCCCK
................KDDDDDCCCCK
...............KDDDDDCCCCK
.....KKKKK....KDDDDDCCCCK
....KDDDDDKKKKDDDDDDCCCK
.....KDDDDDDKLLLKDDCCCK
......KDDDDKLLLLLKDCCK
.......KDDKLLLLLLKKCK
.......KKKLLLLLLLKFFK
.........KLLLLLLKKFK
.........KLLLLLK..K
..........KLLLK
..........KLLK
...........KK
"""

# Hit: it faces us, wings flung up, eyes wide.
SHOT = """
................
.KK.............
KLLK............
KLLLK...........
.KLLLK.....KKKKK
.KLLLLK...KHHHHH
..KLLLLK.KHHHHHH
..KLLLLLKHHEEEHH
...KLLLLKHEEKEHH
...KLLLLKHEEEEHH
....KLLLKHHHHHOO
....KLLLKKHHHOOO
.....KLLLKKHHKOO
.....KLLLDKKKKKK
......KLDDEEEEEE
......KDDDDDDDDD
......KDDDDDDDDD
......KDDDDDDCCC
......KDDDDDCCCC
.......KDDDCCCCC
.......KDDCCCCCC
........KKCCCCCC
..........KKKKKK
............KFFK
............KFFK
.............KK.
"""

# Falling: head first, wings shut, feet up.
FALL = """
................................
..........KK..KK
..........KFFKKFFK
...........KFFKFFK
..........KKKKKKKKK
.........KCCCCDDDDK
........KCCCCDDDDDDK
........KCCCDDDDDDDK
........KCCCDDDLDDDK
........KCCDDDLLLDDK
........KCCDDDLLLDDK
........KCCDDLLLLDDK
........KCCDDLLLLDDK
.........KCDDLLLDDK
.........KCDDDLDDDK
..........KDDDDDDK
..........KEEEEEEK
..........KHHHHHHK
.........KHHHHHHHHK
.........KHEEEHHHHK
.........KHEKEHHHHK
.........KHHHHHHHHK
..........KHHHHHHK
...........KKOOKK
............KOOK
............KOOK
.............KK
"""


def frames():
    right = [
        from_text(UP, W, H), from_text(MID, W, H), from_text(DOWN, W, H),
        from_text(CLIMB_UP, W, H), from_text(CLIMB_MID, W, H), from_text(CLIMB_DOWN, W, H),
        half(SHOT, W, H), from_text(FALL, W, H),
    ]
    return right + [mirror(f) for f in right]


def palettes(nes):
    common = {"K": nes["black"], "E": nes["white"], "O": nes["orange"], "F": nes["salmon"]}
    black = dict(common, H=nes["leaf"], D="#000000", L=nes["white"], C=nes["red"])
    blue = dict(common, H=nes["magenta"], D=nes["navy"], L=nes["white"], C=nes["salmon"])
    red = dict(common, H=nes["navy"], D=nes["maroon"], L=nes["white"], C=nes["cream"])
    return [black, blue, red]
