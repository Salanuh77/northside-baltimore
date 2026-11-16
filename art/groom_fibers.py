"""Original grayscale hair fibers for pulled hair, curled puffs and twisted strands."""
import numpy as np
from PIL import Image,ImageDraw
from pathlib import Path

def fibers():
    rng=np.random.default_rng(81)
    image=Image.new("RGB",(1536,512),(191,191,191))
    for bank in range(3):
        panel=Image.new("L",(512,512),[190,179,187][bank])
        d=ImageDraw.Draw(panel)
        for _ in range([3400,9600,2200][bank]):
            x,y=rng.uniform(-15,525,2)
            t=np.linspace(0,1,18)
            phase=rng.uniform(0,6.28)
            if bank==1:
                radius=rng.uniform(1.5,8)
                xs=x+radius*np.cos(phase+t*5)+t*3
                ys=y+radius*.72*np.sin(phase+t*5)
            else:
                slope=(.26 if bank==0 else .50)
                length=rng.uniform(12,46)
                ys=y+t*length
                xs=x+t*length*slope+np.sin(phase+t*4)*rng.uniform(1,3)
            shade=int(rng.choice([104,130,151,203,225,249]))
            d.line(list(zip(xs,ys)),fill=shade,width=int(rng.choice([1,1,2])))
        channel=np.asarray(panel).astype(float)+rng.normal(0,4,(512,512))
        image.paste(Image.fromarray(np.uint8(channel.clip(0,255))).convert("RGB"),(bank*512,0))
    image.save(Path(__file__).with_name("groom-fibers.png"))

if __name__=="__main__":
    fibers()
