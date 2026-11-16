"""Draw 32 original product rows for in-world shelf fronts. Cells are 256 x 128."""
from pathlib import Path
import json
import random
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).parent
FONT = Path("C:/Windows/Fonts")
BOLD = ImageFont.truetype(str(FONT / "arialbd.ttf"), 18)
SMALL = ImageFont.truetype(str(FONT / "arialbd.ttf"), 8)
SERIF = ImageFont.truetype(str(FONT / "georgiab.ttf"), 16)
# Each shelf has one merchandise family and several related pack colors.
LINES = [
 ("chips","RIPTIDE","BAY CHIPS","bag","D14C37 F0AB39 138782"),
 ("sweets","LOOP","FRUIT CHEWS","bag","862C63 E05D70 2E9291"),
 ("soda","FIZZ","SODA POP","can","CC4836 378A99 D9962F"),
 ("oil","MILE 40","MOTOR OIL","jug","536C72 884738 A38F54"),
 ("deli","STACK","DELI FRESH","wrap","B47F4D DFBE84 95734C"),
 ("coffee","NIGHT OWL","ROAST No. 4","bag","745242 B88750 527A70"),
 ("tea","LEAF","STEEP SLOW","box","728958 B86E66 D19B58"),
 ("pastry","CRUMB","BAKED TODAY","bread","CE955A E4BA76 B3744D"),
 ("fruit","ORCHARD","FRUIT CRATE","fruit","B84732 B68335 799444"),
 ("pantry","TIN WORKS","PANTRY","can","BD583E 829453 D5AB5E"),
 ("spice","PINCH","BAY SPICE","jar","B75335 C29142 838453"),
 ("books","LOW TIDE","EDITION","book","356270 A8593F B29A6A"),
 ("magazines","CURB","CITY PRESS","book","C04F53 C8A44B 578D92"),
 ("vinyl","B SIDE","33 RPM","record","546E8B A45458 D0A04E"),
 ("camera","FRAME","FILM 400","box","D4983F B45649 2E787A"),
 ("print","INK LAB","COLOR SET","box","6C5C86 4F9990 BF6269"),
 ("cosmetics","CURL CO.","DAILY CARE","bottle","A97E67 668981 987189"),
 ("laundry","SUDSY","FRESH WASH","jug","598F9A E39A47 985986"),
 ("meds","BAYWELL","CARE","box","4F897D A5695B 6798A5"),
 ("sneakers","LATE RUN","COURT LOW","shoe","D2C7AD 727D91 9F644E"),
 ("denim","SELVEDGE","DENIM","fold","54718C 384B5D 868B94"),
 ("hoodies","NORTH CUT","FLEECE","fold","9B5354 A99070 627675"),
 ("sports","REC DEPT","LEAGUE","ball","A55D39 CB9B53 718DA2"),
 ("camp","RIDGE","FIELD KIT","bag","758065 B0885F 81737A"),
 ("tools","BOLT","WORKSHOP","box","C8973B C15F40 557C78"),
 ("art","EDITION","PRINT No.","poster","CB7B5F 829785 BCA276"),
 ("ticket","ADMIT","MATINEE","book","BE7357 AA9370 54878B"),
 ("electronics","BIT BOX","ARCADE","box","527786 A45670 D1A042"),
 ("paper","FOLIO","STATIONERY","book","89845B B27457 658E8C"),
 ("beverages","LIMELINE","SPARKLING","bottle","80A45D B4904F 559596"),
 ("care","TIDELINE","HAND CARE","bottle","7E9C8A B78983 8EA5AE"),
 ("sauces","RED DOCK","HOT SAUCE","bottle","C16242 AD8449 847B48"),
]
ink="#252926"
cream="#F6EACC"

def shade(hexcode,factor):
    return tuple(min(255, round(int(hexcode[i:i+2],16)*factor)) for i in (0,2,4))

def print_fit(d,text,x,y,w,h,font,color):
    stamp=Image.new("RGBA",(220,36))
    painter=ImageDraw.Draw(stamp)
    box=painter.textbbox((0,0),text,font=font)
    painter.text((-box[0]+1,-box[1]+1),text,font=font,fill=color)
    glyph=stamp.crop((0,0,box[2]-box[0]+2,box[3]-box[1]+2))
    glyph.thumbnail((max(1,w),max(1,h)),Image.Resampling.LANCZOS)
    d._image.paste(glyph,(int(x+(w-glyph.width)/2),int(y)),glyph)

def row(index,spec):
    _,name,sub,kind,colors=spec
    palette=colors.split()
    out=Image.new("RGBA",(256,128))
    d=ImageDraw.Draw(out)
    rng=random.Random(index*301+11)
    count=4 if kind in ("shoe","ball","record","poster","fold","bread","fruit") else 5
    slot=244/count
    for i in range(count):
        x=int(6+i*slot+rng.uniform(-1,1)); w=int(slot)-3
        bottom=119
        h=rng.randrange(76,93) if kind not in ("wrap","bread","fold","shoe","ball","fruit") else rng.randrange(46,68)
        y=bottom-h
        c=palette[(i//2+index)%3]; face="#"+c; shade1=shade(c,.67)
        if kind in ("fruit","ball"):
            if kind=="fruit":
                for n in range(6):
                    a=x+(n%3)*15+2; b=bottom-17-(n//3)*17
                    d.ellipse((a,b-13,a+19,b+9),fill=face,outline=shade1,width=2)
                    d.line((a+9,b-12,a+12,b-17),fill=ink,width=2)
                d.rectangle((x,bottom-14,x+w,bottom),fill="#A97D50",outline=ink)
            else:
                d.ellipse((x+1,bottom-w,x+w,bottom),fill=face,outline=ink,width=2)
                d.arc((x+w//4,bottom-w,x+w*3//4,bottom),75,290,fill=ink,width=2)
                d.line((x+4,bottom-w//2,x+w-4,bottom-w//2),fill=ink,width=2)
            continue
        if kind in ("fold","shoe","bread"):
            for k in range(3 if kind=="fold" else 1):
                top=bottom-(k+1)*12 if kind=="fold" else y+9
                if kind=="shoe":
                    d.polygon([(x,bottom-21),(x+w//4,top),(x+w//2,top+1),(x+w*3//5,bottom-26),(x+w-2,bottom-16),(x+w,bottom-5),(x,bottom-4)],fill=face,outline=ink)
                    d.line((x,bottom-6,x+w,bottom-6),fill=cream,width=6)
                    for j in range(3): d.line((x+17+j*4,top+12+j*2,x+22+j*4,top+11+j*2),fill=cream,width=2)
                else:
                    low=bottom-k*12; d.rounded_rectangle((x,top,x+w,low),radius=6,fill=shade(c,1-k*.07),outline=shade1,width=2)
                    if kind=="bread":
                        for j in range(3): d.line((x+10+j*12,top+4,x+4+j*12,top+12),fill=cream,width=2)
                    else: d.line((x+5,low-4,x+w-8,low-4),fill=shade1)
            continue
        if kind in ("bottle","jug","jar"):
            neck=x+w//2; yy=y+20 if kind!="jar" else y+9
            d.rounded_rectangle((x+3,yy,x+w-2,bottom),radius=8,fill=face,outline=shade1,width=2)
            d.polygon([(x+6,yy+3),(neck-7,y+9),(neck+7,y+9),(x+w-5,yy+3)],fill=face)
            d.rectangle((neck-8,y+3,neck+8,y+11),fill=cream,outline=ink)
            if kind=="jug": d.rounded_rectangle((x+w-13,yy+3,x+w-6,yy+18),radius=3,fill=ink)
        elif kind=="bag":
            d.polygon([(x+2,y+3),(x+w-3,y),(x+w-6,y+10),(x+w-1,bottom-6),(x+w-5,bottom),(x+2,bottom-2),(x+5,y+14)],fill=face,outline=shade1)
            for top in (y+5,bottom-5): d.line((x+4,top,x+w-5,top),fill=shade1,width=2)
        else:
            d.rounded_rectangle((x,y,x+w,bottom),radius=5 if kind in ("can","wrap") else 1,fill=face,outline=shade1,width=2)
            d.rectangle((x+w-4,y+3,x+w-1,bottom-2),fill=shade1)
            if kind=="can":
                for top in (y+1,bottom-2): d.line((x+2,top,x+w-2,top),fill="#CFC9B7",width=3)
        mid=int(y+h*.52)
        if kind=="record":
            d.ellipse((x+5,y+8,x+w-5,y+w-2),fill=ink);d.ellipse((x+w//2-5,y+w//2,x+w//2+5,y+w//2+10),fill=cream)
        elif kind=="poster":
            d.ellipse((x+6,y+7,x+w-9,mid+12),fill=cream);d.polygon([(x+4,bottom-13),(x+w-10,mid),(x+w-4,bottom-13)],fill=shade1)
        elif kind in ("book","box"):
            d.polygon([(x+3,y+8),(x+w-5,y+4),(x+w-5,y+15),(x+3,y+22)],fill=shade1)
        else:
            d.ellipse((x+w//2-8,mid-15,x+w//2+9,mid+2),fill=cream)
            d.polygon([(x+w//2-7,mid-2),(x+w//2,mid-11),(x+w//2+7,mid-2)],fill=shade1)
        d.rectangle((x+3,mid+6,x+w-4,mid+23),fill=cream)
        print_fit(d,name,x+3,mid+8,w-7,11,SERIF if index%3==0 else BOLD,ink)
        print_fit(d,sub,x+3,bottom-12,w-7,8,SMALL,cream)
    return out

def main():
    atlas=Image.new("RGBA",(1024,1024))
    for index,spec in enumerate(LINES):
        atlas.paste(row(index,spec),((index%4)*256,(index//4)*128))
    atlas.save(ROOT/"retail-aisles.png",optimize=True)
    packages = [{"shape": kind, "colors": palette.split()} for _, _, _, kind, palette in LINES]
    (ROOT / "retail-packages.json").write_text(json.dumps(packages, indent=2) + "\n", encoding="utf-8")

if __name__=="__main__":
    main()
