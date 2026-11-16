"""Draw front-facing eye and lip plates at their actual in-game aspect ratios."""
from pathlib import Path
from PIL import Image, ImageDraw
ROOT = Path(__file__).parent

def eyes(style):
    art=Image.new("RGBA",(768,192))
    p=ImageDraw.Draw(art)
    tilt={"calm":0,"smile":-9,"focused":10}[style]
    for mirror in (False,True):
        def pts(path):
            return [(767-x if mirror else x,y) for x,y in path]
        p.polygon(pts([(31,58),(71,30),(119,23),(174,28),(221,45+tilt),
                       (230,59+tilt),(183,49),(120,44),(75,47)]),fill=(48,35,30,240))
        p.polygon(pts([(38,125),(73,103),(119,92+tilt),(173,98+tilt),
                       (218,119),(187,135),(146,143),(100,146),(62,139)]),fill=(222,205,186,255))
        cx=767-129 if mirror else 129
        p.ellipse((cx-21,96+tilt,cx+21,139),fill=(112,86,62,255))
        p.ellipse((cx-10,102+tilt,cx+10,135),fill=(40,31,29,255))
        p.ellipse((cx-9,103+tilt,cx-4,109+tilt),fill=(242,229,203,235))
        p.line(pts([(38,125),(73,103),(119,92+tilt),(173,98+tilt),(218,119)]),fill=(53,37,30,255),width=8)
        p.line(pts([(68,139),(110,148),(145,147)]),fill=(120,79,63,150),width=3)
    art.save(ROOT/("portrait-"+style+".png"))

def lips(style):
    art=Image.new("RGBA",(384,128))
    p=ImageDraw.Draw(art)
    corner={"level":66,"smile":43,"set":72}[style]
    p.polygon([(18,corner),(86,55),(149,41),(183,48),(204,43),(246,46),(362,corner),
               (258,77),(194,84),(113,78)],fill=(134,77,66,175))
    p.polygon([(18,corner),(122,66),(193,71),(273,65),(362,corner),
               (293,87),(228,99),(170,100),(102,90)],fill=(171,105,93,160))
    p.line([(18,corner),(98,65),(151,64),(194,70),(240,64),(284,63),(362,corner)],fill=(74,46,39,230),width=5)
    art.save(ROOT/("lips-"+style+".png"))

if __name__=="__main__":
    for value in ["calm","smile","focused"]: eyes(value)
    for value in ["level","smile","set"]: lips(value)
