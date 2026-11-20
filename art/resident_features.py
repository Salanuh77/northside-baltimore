"""Conforming eye/lip overlays: the artwork follows the head instead of floating on flat cards."""
import numpy as np
from scipy.interpolate import PchipInterpolator
from resident_profiles import ROOT,PROFILES,Y,export
import json,math

def surface(shape,kind,variant=None):
    chin,jaw,cheek,temple,crown=PROFILES[shape]
    width=PchipInterpolator(Y,[.05,chin,jaw,cheek,temple,temple*.91,crown,.07])
    depth=PchipInterpolator(Y,[.09,.30,.41,.46,.46,.45,.33,.09])
    w,h,cy=({'Close':.72,'Balanced':.79,'Wide':.85}[variant or 'Balanced'],.255,.106) if kind=='Eyes' else (.405,{'Thin':.105,'Medium':.133,'Full':.160}[variant or 'Medium'],-.218)
    vertices=[];uv=[];faces=[]
    for j in range(13):
        v=j/12;y=cy+(v-.5)*h
        for i in range(33):
            u=i/32;x=(u-.5)*w
            z=-float(depth(y))*math.sqrt(max(0,1-(abs(x)/float(width(y)))**3.4))
            z-=.050*math.exp(-(x/.068)**2-((y-.028)/.185)**2)
            z-=.117*math.exp(-(x/.098)**2-((y+.083)/.072)**2)
            z-=.020*math.exp(-((abs(x)-.21)/.12)**2-((y-.145)/.053)**2)
            z-=.027*math.exp(-(x/.17)**2-((y+.32)/.074)**2)
            vertices.append([x,y,z-.012]);uv.append([u,1-v])
    for j in range(12):
        for i in range(32):
            a=j*33+i
            faces.extend([(a,a+33,a+1),(a+1,a+33,a+34)])
    return np.array(vertices,dtype='<f4'),np.array(faces,dtype='<u2'),np.array(uv,dtype='<f4')

if __name__=='__main__':
    meshes=[(shape+' '+kind+' '+variant,surface(shape,kind,variant)) for shape in PROFILES for kind,variants in {'Eyes':['Close','Balanced','Wide'],'Mouth':['Thin','Medium','Full']}.items() for variant in variants]
    export(ROOT/'resident-features.glb',meshes,ROOT/'portrait-calm.png')
    bounds={}
    for name,(v,_,_) in meshes:
        lo,hi=v.min(axis=0),v.max(axis=0)
        bounds[name]={'center':((lo+hi)/2).tolist(),'size':(hi-lo).tolist()}
    (ROOT/'feature-bounds.json').write_text(json.dumps(bounds,indent=2)+'\n',encoding='utf-8')
