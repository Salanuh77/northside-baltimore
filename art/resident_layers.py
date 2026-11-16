"""Draw the Northside creator's independent decal layers and classic clothing UV maps."""
from pathlib import Path
from math import cos, pi
from random import Random
from PIL import Image, ImageDraw

ROOT = Path(__file__).parent


def face(key, shape):
    image = Image.new("RGBA", (512, 512))
    pen = ImageDraw.Draw(image)
    ink = (47, 35, 31, 255)
    if key.startswith("resident"):
        for x, direction in [(171, 1), (341, -1)]:
            def points(coords):
                return [(x + dx * direction, y) for dx, y in coords]
            lid = {"calm": 208, "focused": 216, "smile": 203}[shape]
            pen.polygon(points([(-34, lid+9),(-22,lid),(4,lid-2),(31,lid+4),(20,lid+14),(-6,lid+18)]), fill=(215,199,177,255))
            pen.ellipse((x-8,lid-1,x+10,lid+15), fill=(75,59,46,255))
            pen.ellipse((x-4,lid+2,x+4,lid+12), fill=ink)
            pen.line(points([(-34,lid+8),(-20,lid),(2,lid-2),(30,lid+4)]), fill=ink, width=5)
            slope = 12 if shape=="focused" else 3
            pen.polygon(points([(-36,lid-18),(-23,lid-27),(1,lid-29),(30,lid-24+slope),(27,lid-19+slope),(-5,lid-22)]), fill=ink)
    else:
        corner = {"level": 307, "smile": 299, "set": 312}[shape]
        pen.line([(216,corner),(237,308),(251,307),(260,308),(272,307),(295,corner-1)],fill=(74,47,41,235),width=5)
        pen.line([(241,318),(257,320),(273,316)], fill=(117,74,61,130),width=3)
    image.save(ROOT / (key+".png"))


def fabric(pen, box, base, seed):
    x,y,w,h=box
    rng=Random(seed)
    for row in range(h):
        for col in range(w):
            value=round(3*cos(2*pi*col/w)+rng.uniform(-3,3))
            pen.point((x+col,y+row),fill=tuple(max(0,min(255,c+value)) for c in base))


def jacket(key, color, cuff, sleeves):
    image=Image.new("RGBA",(585,559))
    pen=ImageDraw.Draw(image)
    for i,(x,w) in enumerate([(165,64),(231,128),(361,64),(427,128)]):
        fabric(pen,(x,74,w,128),color,i)
        pen.rectangle((x,190,x+w-1,201),fill=cuff)
        pen.line((x,193,x+w-1,193), fill=(139,138,126),width=1)
    for x,w,y,h in [(231,128,8,64),(231,128,204,64),(217,64,289,64),(308,64,289,64)]:
        fabric(pen,(x,y,w,h),color,x)
    for start in [19,308]:
        for j in range(4):
            x=start+66*j
            fabric(pen,(x,355,64,112),sleeves,j)
            pen.rectangle((x,454,x+63,468),fill=cuff)
            pen.line((x,457,x+63,457),fill=(138,137,123))
    pen.polygon([(268,74),(320,74),(295,99)],fill=(202,201,185))
    pen.polygon([(261,74),(271,74),(295,96),(287,104)],fill=cuff)
    pen.polygon([(327,74),(317,74),(295,96),(303,104)],fill=cuff)
    pen.line((295,97,295,198),fill=(130,132,123),width=2)
    for x0,x1 in [(239,258),(350,331)]:
        pen.line((x0,180,x1,160),fill=cuff,width=4)
    image.save(ROOT/(key+".png"))


def trousers(key, color, shoe):
    image=Image.new("RGBA",(585,559))
    pen=ImageDraw.Draw(image)
    thread=tuple(min(255,c+27) for c in color)
    for x,w in [(165,64),(231,128),(361,64),(427,128)]:
        fabric(pen,(x,183,w,19),color,x)
        pen.line((x,190,x+w-1,190),fill=thread)
    for start in [19,308]:
        for j in range(4):
            x=start+66*j
            fabric(pen,(x,355,64,108),color,j)
            pen.line((x+3,360,x+4,458),fill=thread)
            pen.line((x+9,355,x+7,367,x+2,373),fill=thread,width=2)
            pen.line((x+15,422,x+44,424,x+54,422),fill=thread)
            pen.rectangle((x,459,x+63,482),fill=shoe)
            for y in [465,469,473]:
                pen.line((x+21,y,x+43,y+1),fill=(140,143,142),width=2)
            pen.rectangle((x,479,x+63,484),fill=(172,169,152))
        for x in ([217] if start==19 else [308]):
            pen.rectangle((x,487,x+63,550),fill=(89,88,80))
    image.save(ROOT/(key+".png"))


if __name__ == "__main__":
    for shape in ["calm","smile","focused"]:
        face("resident-"+shape,shape)
    for shape in ["level","smile","set"]:
        face("mouth-"+shape,shape)
    jacket("harbor-warmup",(45,64,74),(26,37,44),(45,64,74))
    jacket("pier-varsity",(100,52,61),(59,35,43),(193,183,159))
    for key,color in [("street-denim",(38,46,57)),("washed-denim",(86,102,118)),("canvas-trousers",(125,111,86))]:
        trousers(key,color,(202,201,186))
        trousers(key+"-black",color,(46,47,47))
