"""Exchange Streetwear's three original parody labels on the resident shirt UV layout."""
from pathlib import Path
from PIL import Image, ImageDraw
from resident_layers import jacket

ROOT = Path(__file__).parent
STYLES = [
    ("haste-markdown", (121, 39, 46), (50, 28, 33), (117, 38, 45)),
    ("forever-tuesday", (44, 61, 80), (26, 37, 49), (210, 195, 163)),
    ("last-season", (137, 133, 105), (56, 61, 53), (115, 116, 92)),
]

def render(key, base, rib, sleeve):
    jacket(key, base, rib, sleeve)
    path = ROOT / (key + ".png")
    shirt = Image.open(path).convert("RGBA")
    pen = ImageDraw.Draw(shirt)
    ivory = (228, 217, 189)
    if key == "haste-markdown":
        # Clearance racing shell, chevrons across the front, back and both cuffs.
        for x in (231,427):
            pen.polygon([(x,106),(x+64,133),(x+127,106),(x+127,114),(x+64,144),(x,114)],fill=ivory)
            pen.line([(x,118),(x+64,148),(x+127,118)],fill=rib,width=2)
        pen.text((302,151),"H / M'DN",fill=ivory)
        for start in (19,308):
            for i in range(4):
                x = start + i*66
                pen.rectangle((x,427,x+63,434),fill=ivory)
    elif key == "forever-tuesday":
        # Two-color chain-stitched varsity numeral; counterbalance with back lettering.
        pen.rounded_rectangle((306,110,338,146),3,fill=rib,outline=ivory,width=3)
        pen.text((312,115),"TU",fill=ivory)
        pen.text((314,130),"02",fill=ivory)
        pen.text((451,105),"FOREVER TUESDAY",fill=ivory)
        for y in (135,141):
            pen.line((442,y,539,y),fill=ivory,width=2)
    else:
        # Soft olive chore jacket with an offset plaid repeat and flap pockets.
        for x,w in [(165,64),(231,128),(361,64),(427,128)]:
            for u in range(x+5,x+w-1,19):
                pen.line((u,98,u,188),fill=(91,97,78),width=2)
            for y in range(106,185,17):
                pen.line((x,y,x+w-1,y),fill=(159,146,109),width=2)
        for x in (241,309):
            pen.rectangle((x,123,x+35,153),fill=rib)
            pen.polygon([(x-1,123),(x+36,123),(x+32,132),(x+4,132)],fill=sleeve)
        pen.text((304,103),"L / S",fill=rib)
    shirt.save(path)

if __name__ == "__main__":
    for item in STYLES:
        render(*item)
