"""Sculpt rigid, dyeable grooms in the same coordinate frame as the resident's head."""
from math import sin, cos, pi, sqrt
from random import Random
import json
import numpy as np
from resident_profiles import ROOT, export

class Groom:
    def __init__(self, seed):
        self.vertices=[]
        self.faces=[]
        self.random=Random(seed)

    def surface(self,rows):
        start=len(self.vertices)
        count=len(rows[0])
        for row in rows: self.vertices.extend(row)
        for r in range(len(rows)-1):
            for i in range(count):
                a=start+r*count+i
                b=start+r*count+(i+1)%count
                self.faces.extend([(a,a+count,b),(b,a+count,b+count)])

    def scalp(self, tight=.0):
        rows=[]
        for j in range(11):
            t=j/10
            row=[]
            for i in range(48):
                a=i*2*pi/48
                edge=.08+.15*cos(a)+.035*cos(2*a)
                phi=(1-t)*(.5*pi-edge)+.025*t
                radius=(.50+tight+.008*cos(13*a+2*t))*sin(phi)
                row.append((radius*sin(a),edge+(.53-edge)*(cos(phi)-sin(edge))/(1-sin(edge)),-radius*cos(a)))
            rows.append(row)
        self.surface(rows)

    def puff(self,center,scale):
        # Uneven edge lobes on a dense base keep the puff fluffy in silhouette.
        def fleece(c,s,seed,loops,segments):
            rings=[]
            for j in range(loops+1):
                lat=-pi/2+.014+(pi-.028)*j/loops
                row=[]
                for i in range(segments):
                    a=2*pi*i/segments
                    grain=1+.065*cos(9*a+seed+2*lat)*cos(lat)**2+.05*sin(7*lat+3*cos(a))
                    row.append((c[0]+s[0]*grain*cos(lat)*sin(a),c[1]+s[1]*grain*sin(lat),c[2]-s[2]*grain*cos(lat)*cos(a)))
                rings.append(row)
            self.surface(rings)
        fleece(center,scale,.5,14,36)
        for i in range(36):
            y=(i+.5)/18-1
            a=i*2.399963
            radial=sqrt(1-y*y)
            c=[center[0]+scale[0]*.91*radial*sin(a),center[1]+scale[1]*.91*y,center[2]+scale[2]*.91*radial*cos(a)]
            fleece(c,[v*.22 for v in scale],i,5,10)

    def tube(self,path,radii):
        rows=[]
        for i,c in enumerate(path):
            tangent=path[min(i+1,len(path)-1)]-path[max(0,i-1)]
            tangent/=max(1e-9,np.linalg.norm(tangent))
            axis=np.array([1.,0.,0.]) if abs(tangent[0])<.85 else np.array([0.,0.,1.])
            side=np.cross(tangent,axis);side/=np.linalg.norm(side)
            other=np.cross(side,tangent)
            rows.append([c+radii[i]*(cos(a)*side+sin(a)*other) for a in np.arange(6)*pi/3])
        self.surface(rows)

    def rope(self,path,radius,turns,double=True):
        path=np.asarray(path,dtype=float)
        n=len(path)
        for offset in ([0,pi] if double else [0]):
            centers=[];widths=[]
            for i,c in enumerate(path):
                t=i/(n-1)
                tangent=path[min(i+1,n-1)]-path[max(i-1,0)]
                tangent/=max(1e-9,np.linalg.norm(tangent))
                axis=np.array([1.,0.,0.]) if abs(tangent[0])<.85 else np.array([0.,0.,1.])
                side=np.cross(tangent,axis);side/=np.linalg.norm(side)
                other=np.cross(side,tangent)
                a=turns*2*pi*t+offset
                taper=min(1,.15+9*(1-t))
                shift=(.49*radius*taper if double else 0)*(cos(a)*side+sin(a)*other)
                centers.append(c+shift);widths.append(radius*taper*(.61 if double else .82+.10*sin(a)))
            self.tube(centers,widths)

    def twists(self,loose=False,locs=False):
        # Stagger the parts in three rows; front strands stop above the eyes.
        for row,count in enumerate([14,10,5]):
            for k in range(count):
                a=(k+.46*row+self.random.uniform(-.12,.12))*2*pi/count
                phi=[1.04,.69,.28][row]
                length=.14+self.random.uniform(.03,.16)+(1-cos(a))*.12
                radius=[.050,.056,.055][row]*(1.2 if locs else 1)
                path=[]
                for t in np.linspace(0,1,27):
                    bend=phi+t*(.34 if loose else .48)
                    roll=a+.11*t*sin(a*3)
                    r=.49*sin(bend)+(.12 if loose else .055)*sin(t*pi*.8)
                    path.append([r*sin(roll),.03+.52*cos(bend)-length*t*t,-r*cos(roll)])
                self.rope(path,radius,3.5 if loose else 4.5,not locs)

    def rows(self,thick=False):
        for i,x in enumerate(np.linspace(-.39,.39,5 if thick else 9)):
            h=sqrt(1-(x/.53)**2)
            path=[]
            for t in np.linspace(0,1,65):
                a=-1.08+3.0*t
                path.append([x+.022*sin(a*2),.065+.51*h*cos(a),.49*h*sin(a)])
            self.rope(path,.068 if thick else .033,9 if thick else 12)

    def knots(self):
        for a,p in [(i*2*pi/7,1.02) for i in range(7)]+[(i*2*pi/3+.3,.43) for i in range(3)]:
            origin=np.array([.49*sin(p)*sin(a),.54*cos(p),-.49*sin(p)*cos(a)])
            normal=np.array([sin(p)*sin(a),cos(p),-sin(p)*cos(a)])
            side=np.array([cos(a),0,sin(a)]);along=np.cross(normal,side)
            path=[]
            for t in np.linspace(0,1,40):
                radius=.09*(1-.6*t);spin=t*3*2*pi
                path.append(origin+.155*t*normal+radius*(cos(spin)*side+sin(spin)*along))
            self.rope(path,.043,4,False)

def make(style):
    g=Groom(style);g.scalp(-.021 if style in ("Cornrows","Barrel twists") else -.008)
    if style=="High puff": g.puff((0,.63,.11),(.43,.32,.40))
    elif style=="Low puff": g.puff((0,.23,.45),(.35,.28,.32))
    elif style=="Twin buns":
        for side in [-1,1]: g.puff((side*.30,.53,.17),(.23,.21,.22))
    elif style in ("Twists","Twist out","Short locs"): g.twists(style=="Twist out",style=="Short locs")
    elif style in ("Cornrows","Barrel twists"): g.rows(style=="Barrel twists")
    elif style=="Bantu knots": g.knots()
    return np.array(g.vertices,dtype="<f4"),np.array(g.faces,dtype="<u2")

if __name__=="__main__":
    styles=["High puff","Twists","Twin buns","Cornrows","Short locs","Low puff","Twist out","Barrel twists","Bantu knots"]
    meshes=[(style,make(style)) for style in styles]
    export(ROOT/"resident-grooms.glb",meshes)
    bounds={}
    for name,(verts,_) in meshes:
        lo,hi=verts.min(axis=0),verts.max(axis=0)
        bounds[name]={"center":((lo+hi)/2).round(5).tolist(),"size":(hi-lo).round(5).tolist()}
    (ROOT/"groom-bounds.json").write_text(json.dumps(bounds,indent=2)+"\n")
