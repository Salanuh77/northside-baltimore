"""Generate the original vehicle body panels in local Roblox studs, nose toward -Z."""
import json, math, struct
from pathlib import Path
import numpy as np

out = Path(__file__).parent
blob = bytearray()
g = dict(asset={'version':'2.0'}, scene=0, scenes=[{'nodes':[]}], nodes=[], meshes=[], accessors=[], bufferViews=[])
bounds = {}
def accessor(array, kind, component):
    while len(blob)%4: blob.append(0)
    start=len(blob); blob.extend(array.tobytes())
    view=len(g['bufferViews']); g['bufferViews'].append(dict(buffer=0,byteOffset=start,byteLength=array.nbytes))
    acc=dict(bufferView=view,componentType=component,count=len(array),type=kind)
    if kind=='VEC3':
        acc.update(min=array.min(axis=0).tolist(),max=array.max(axis=0).tolist())
    g['accessors'].append(acc);return len(g['accessors'])-1

def export(name, patches):
    vertices=[]; normals=[]; triangles=[]
    for grid in patches:
        a=np.asarray(grid,dtype=float); h,w=a.shape[:2]
        norm=np.zeros_like(a)
        start=len(vertices)
        for i in range(h-1):
            for j in range(w-1):
                idx=[(i,j),(i,j+1),(i+1,j+1),(i+1,j)]
                for ids in ((0,1,2),(0,2,3)):
                    corners=[idx[k] for k in ids]; v=[a[x] for x in corners]
                    n=np.cross(v[1]-v[0],v[2]-v[0])
                    if np.linalg.norm(n)<1e-7: continue
                    triangles.extend(start+x*w+y for x,y in corners)
                    for x in corners: norm[x]+=n
        norm/=np.maximum(np.linalg.norm(norm,axis=2,keepdims=True),1e-8)
        vertices.extend(a.reshape(-1,3));normals.extend(norm.reshape(-1,3))
    v=np.array(vertices,'<f4')
    attributes=dict(POSITION=accessor(v,'VEC3',5126),NORMAL=accessor(np.array(normals,'<f4'),'VEC3',5126))
    prim=dict(attributes=attributes,indices=accessor(np.asarray(triangles,'<u2'),'SCALAR',5123))
    ix=len(g['meshes']);g['meshes'].append(dict(name=name,primitives=[prim]))
    g['nodes'].append(dict(name=name,mesh=ix,translation=[(ix//3)*26,0,0]));g['scenes'][0]['nodes'].append(ix)
    bounds[name]={'center':((v.max(0)+v.min(0))/2).tolist(),'size':np.maximum(v.max(0)-v.min(0),.06).tolist()}

# front bumper, hood, windshield base, roof front, roof rear, rear glass base, tail, roof height, belt height, half width
styles={
 'Sport':(-8.1,-6.3,-4.0,-.9,1.12,5.55,7.85,6.17,3.35,3.91),
 'Saloon':(-7.9,-6.55,-3.95,-1.53,2.0,4.96,7.7,6.65,3.65,3.76),
 'Estate':(-7.85,-6.35,-3.8,-1.56,4.0,6.34,7.49,6.96,3.8,3.80),
 'Utility':(-8.0,-6.85,-3.62,-1.78,4.47,6.51,7.65,7.65,4.12,3.91),
 'Muscle':(-8.4,-6.83,-3.18,-.95,1.67,4.72,7.78,6.37,3.62,3.86),
 'Van':(-7.95,-7.1,-5.78,-3.73,5.49,6.85,7.69,8.05,4.0,3.85)}
for name,(nose,hood,cowl,rf,rr,deck,tail,roof,belt,width) in styles.items():
    paint=[];glass=[]; trim=[]
    isvan=name=='Van'
    def value(z,keys): return float(np.interp(z,[k[0] for k in keys],[k[1] for k in keys]))
    widthkeys=[(nose,width*.82),(nose+.36,width*.93),(hood,width*.99),(cowl,width),(deck,width*.98),(tail-.42,width*.95),(tail,width*.84)]
    def wide(z): return value(z,widthkeys)
    def crown(z):return value(z,[(nose,belt-.67),(nose+.5,belt-.5),(hood,belt-.23),(cowl,belt+.06),(deck,belt-.03),(tail,belt-.32)])
    def opening(z):
        dz=min(abs(z+4.67),abs(z-4.67))
        return max(1.55,1.92+math.sqrt(max(0,1.57**2-dz**2))) if dz<=1.57 else 1.55
    zs=sorted(set([nose,hood,cowl,rf,rr,deck,tail]+list(np.linspace(nose,tail,85))+[ax+1.57*math.cos(t) for ax in [-4.67,4.67] for t in np.linspace(0,math.pi,19)]))
    for side in (-1,1):
        rows=[]
        for z in zs:
            w=wide(z); top=max(crown(z),opening(z)+.13);bot=opening(z)
            rows.append([[side*(w-off),bot+(top-bot)*t,z] for t,off in [(0,.26),(.18,.12),(.59,0),(.82,.018),(1,.16)]])
        paint.append(rows if side==1 else rows[::-1])
    # Curved hood and deck surfaces with chamfered shoulder and two pressed creases.
    for a,b in [(nose,cowl),(deck,tail)]:
        rows=[]
        for z in np.linspace(a,b,19):
            w=wide(z)-.16; y=max(crown(z),opening(z)+.13)
            rows.append([[w*t,y+.24*(1-t*t)+.085*math.exp(-((abs(t)-.66)/.075)**2),z] for t in np.linspace(-1,1,27)])
        paint.append(rows[::-1])
    for z,front in [(nose,True),(tail,False)]:
        w=wide(z);y=crown(z)
        rows=[[[t*(w-.16),1.6+(y-1.6)*v+(v*.24)*(1-t*t),z] for t in np.linspace(-1,1,19)] for v in [0,.21,.67,1]]
        paint.append(rows[::-1] if front else rows)
    # One four-sided cabin shell, including a bowed roof, curved windshield and side glass.
    def canopy(z):
        t=value(z,[(cowl,0),(rf-.31,.93),(rf,1),(rr,1),(rr+.33,.91),(deck,0)])
        y=crown(z)+.17+(roof-crown(z)-.17)*t
        return wide(z)-.23-(.60 if isvan else .85)*t,y,t
    for a,b,region in [(cowl,rf,'glass'),(rf,rr,'paint'),(rr,deck,'glass')]:
        rows=[]
        for z in np.linspace(a,b,18):
            w,y,t=canopy(z)
            rows.append([[u*w,y+.19*(1-u*u),z+(1-u*u)*.16*(1-t)*(1 if a==rr else -1)] for u in np.linspace(-1,1,23)])
        (paint if region=='paint' else glass).append(rows[::-1])
    for side in [-1,1]:
        rows=[]
        for z in np.linspace(cowl,deck,52):
            w,y,t=canopy(z); wb=wide(z)-.16;yb=crown(z)+.12
            rows.append([[side*(wb+(w-wb)*v+.045*math.sin(v*math.pi)),yb+(y-yb)*v,z] for v in [0,.15,.4,.7,1]])
        glass.append(rows if side==1 else rows[::-1])
        for center,half in [(cowl+.52,.5),(rf-.07,.12),(.62,.15),(rr+.12,.17),(deck-.48,.47)]:
            pr=[]
            for z in np.linspace(max(cowl,center-half),min(deck,center+half),8):
                w,y,t=canopy(z); wb=wide(z)-.16;yb=crown(z)+.1
                pr.append([[side*(wb+(w-wb)*v+.06),yb+(y-yb)*v,z] for v in [0,.5,1]])
            trim.append(pr if side==1 else pr[::-1])
    for key,patches in [('Paint',paint),('Glass',glass),('Pillars',trim)]: export(name+'_'+key,patches)
g['buffers']=[{'byteLength':len(blob)}]; doc=json.dumps(g,separators=(',',':')).encode()
doc+=b' '*(-len(doc)%4);blob.extend(b'\0'*(-len(blob)%4))
glb=struct.pack('<4sII',b'glTF',2,28+len(doc)+len(blob))+struct.pack('<I4s',len(doc),b'JSON')+doc+struct.pack('<I4s',len(blob),b'BIN\0')+blob
(out/'northside-motorworks.glb').write_bytes(glb)
(out/'fleet-bounds.json').write_text(json.dumps(bounds))
