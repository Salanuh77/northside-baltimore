"""Build six original head silhouettes in resident coordinates, looking down -Z."""
from pathlib import Path
import json
import math
import struct
import numpy as np

ROOT = Path(__file__).parent
# Half-widths at chin, jaw, cheeks, temple and crown. Each is a distinct profile.
PROFILES = {
    "Oval": (.17, .34, .48, .48, .32),
    "Square": (.25, .46, .48, .47, .31),
    "Round": (.18, .38, .51, .49, .33),
    "Heart": (.12, .28, .49, .51, .34),
    "Oblong": (.20, .36, .41, .42, .29),
    "Diamond": (.13, .32, .52, .43, .29),
}
Y = [-.50, -.44, -.27, -.07, .18, .35, .46, .50]

def rings(profile):
    chin, jaw, cheek, temple, crown = profile
    widths = [.05, chin, jaw, cheek, temple, temple*.91, crown, .07]
    depths = [.09, .30, .41, .46, .46, .45, .33, .09]
    vertices = []
    samples = 64
    for y in np.linspace(-.50, .50, 49):
        w, depth = np.interp(y, Y, widths), np.interp(y, Y, depths)
        for i in range(samples):
            angle = 2*math.pi*i/samples
            x = w*math.sin(angle)
            front = math.cos(angle)
            z = -depth*front
            if front > 0:
                # A broad face with brows, a continuous bridge, nose tip and chin.
                z = -depth*(1-(abs(x)/w)**3.4)**.5
                z -= .050*math.exp(-(x/.068)**2-((y-.028)/.185)**2)
                z -= .117*math.exp(-(x/.098)**2-((y+.083)/.072)**2)
                z -= .020*math.exp(-((abs(x)-.21)/.12)**2-((y-.145)/.053)**2)
                z -= .027*math.exp(-(x/.17)**2-((y+.32)/.074)**2)
            vertices.append([x,y,z])
    faces = []
    for row in range(48):
        for i in range(samples):
            a = row*samples+i
            b = row*samples+(i+1)%samples
            faces.extend([(a,a+samples,b),(b,a+samples,b+samples)])
    for i in range(1,samples-1):
        faces.extend([(0,i,i+1),(48*samples,48*samples+i+1,48*samples+i)])
    return np.array(vertices, dtype="<f4"), np.array(faces, dtype="<u2")

def export(path, models):
    blob = bytearray()
    doc = dict(asset={"version":"2.0"},scene=0,scenes=[{"nodes":[]}],nodes=[],meshes=[],accessors=[],bufferViews=[])
    def accessor(data, kind, component):
        blob.extend(b"\0"*((-len(blob))%4))
        view = len(doc["bufferViews"])
        doc["bufferViews"].append(dict(buffer=0,byteOffset=len(blob),byteLength=data.nbytes))
        blob.extend(data.tobytes())
        item = dict(bufferView=view,componentType=component,count=len(data),type=kind)
        if kind=="VEC3":
            item.update(min=data.min(axis=0).tolist(),max=data.max(axis=0).tolist())
        doc["accessors"].append(item)
        return len(doc["accessors"])-1
    for index,(name,(vertices,faces)) in enumerate(models):
        normals = np.zeros_like(vertices)
        triangles = vertices[faces]
        area = np.cross(triangles[:,1]-triangles[:,0], triangles[:,2]-triangles[:,0])
        for column in faces.T:
            np.add.at(normals,column,area)
        normals /= np.maximum(np.linalg.norm(normals,axis=1)[:,None],1e-8)
        prim = dict(attributes=dict(POSITION=accessor(vertices,"VEC3",5126), NORMAL=accessor(normals,"VEC3",5126)),
                    indices=accessor(faces.reshape(-1),"SCALAR",5123))
        doc["meshes"].append(dict(name=name,primitives=[prim]))
        doc["nodes"].append(dict(name=name,mesh=index,translation=[index*2,0,0]))
        doc["scenes"][0]["nodes"].append(index)
    blob.extend(b"\0"*((-len(blob))%4))
    doc["buffers"]=[dict(byteLength=len(blob))]
    meta=json.dumps(doc,separators=(",",":")).encode()
    meta+=b" "*((-len(meta))%4)
    chunks=struct.pack("<I4s",len(meta),b"JSON")+meta+struct.pack("<I4s",len(blob),b"BIN\0")+blob
    path.write_bytes(struct.pack("<4sII",b"glTF",2,len(chunks)+12)+chunks)

if __name__ == "__main__":
    export(ROOT/"resident-profiles.glb", ((name,rings(p)) for name,p in PROFILES.items()))
