"""Paint the three free crew outfits on Roblox classic shirt UV islands."""
from pathlib import Path
from random import Random
from PIL import Image, ImageDraw
from resident_layers import jacket

ROOT = Path(__file__).parent
SETS = [
    ("ash-pullover", (74,72,70), (53,50,51), (77,71,69), (115,54,53)),
    ("dock-denim", (66,85,94), (53,62,67), (84,91,86), (84,106,129)),
    ("field-liner", (94,93,70), (64,65,54), (90,87,68), (177,151,102)),
]

def garment(key, base, rib, sleeve, accent):
    jacket(key, base, rib, sleeve)
    path = ROOT/(key+".png")
    image = Image.open(path).convert("RGBA")
    pen = ImageDraw.Draw(image)
    light = tuple(min(255,c+25) for c in base)
    dark = tuple(max(0,c-14) for c in base)
    rng = Random(key)
    for x,w in [(165,64),(231,128),(361,64),(427,128)]:
        for _ in range(w):
            px,py=x+rng.randrange(w-5),rng.randrange(80,187)
            pen.line((px,py,px+rng.randint(1,4),py),fill=light if rng.random()<.46 else dark)
    if key=="ash-pullover":
        # Hand-me-down hoodie, cord ends, sagging pouch and a maroon sleeve tie.
        pen.polygon([(261,74),(279,79),(295,95),(311,79),(328,74),(322,88),(295,103),(266,89)],fill=rib)
        pen.line((283,91,281,115),fill=(173,162,137),width=2)
        pen.line((308,91,312,111),fill=(173,162,137),width=2)
        pen.polygon([(267,155),(319,155),(331,179),(259,180)],fill=dark)
        pen.line((266,159,257,174),fill=light,width=2)
        pen.line((321,159,328,174),fill=light,width=2)
        for j in range(4):
            x=19+j*66
            pen.polygon([(x,424),(x+63,423),(x+63,433),(x,435)],fill=accent)
    elif key=="dock-denim":
        # Faded denim shell and a hand-sewn indigo chest patch.
        for x in [242,309]:
            pen.rectangle((x,112,x+29,136),fill=dark)
            pen.line((x,114,x+14,120,x+29,114),fill=light,width=2)
        pen.rectangle((317,148,342,166),fill=accent)
        for x in range(318,342,4):
            pen.line((x,148,x+1,151),fill=(173,163,136))
        for y in range(108,190,15): pen.ellipse((293,y,296,y+3),fill=(155,137,102))
    else:
        # Surplus field liner with quilting, a mismatched elbow and a knotted pocket rag.
        for x,w in [(231,128),(427,128)]:
            for y in range(105,189,14):
                pen.line((x,y,x+w//2,y+8,x+w-1,y),fill=dark)
        pen.polygon([(308,152),(334,151),(330,175),(321,168),(317,181)],fill=accent)
        pen.line((306,151,339,150),fill=rib,width=3)
        pen.rounded_rectangle((387,399,416,435),radius=7,fill=(83,77,63),outline=light)
    # Wear follows cuffs and hems, leaving bounded skin openings and clear seams.
    for start in (19,308):
        for j in range(4):
            x=start+66*j
            for _ in range(10):
                px=x+rng.randrange(60)
                pen.line((px,465,px+2,463),fill=light)
    image.save(path)

if __name__=="__main__":
    for spec in SETS:
        garment(*spec)
