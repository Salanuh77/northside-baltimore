"""Prepare licensed source vehicles for the Roblox model importer. See vehicle-credits.md."""
from pathlib import Path
from urllib.request import urlopen
from collections import defaultdict
import tempfile, json, struct
import numpy as np
from scipy.spatial.transform import Rotation
base=Path(__file__).parent
catalog=[
 ('GT','PatapscoCarConcept.glb','https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models/CarConcept/glTF-Binary/CarConcept.glb',17.8),
 ('Sedan','sedan-car-42109739.glb','https://www.innerscene.com/api/library/sedan-car-42109739/download',17.5),
 ('SUV','suv-dc972cab.glb','https://www.innerscene.com/api/library/suv-dc972cab/download',18.3)]
styles=['Mechanical','Glass','Trim','Fabric','Carpet','Alloy','Leather','Fabric','Trim','Plate','Accent','Paint','Amber','Red','Lamp','Mirror','Brake','Disc','Rubber','Rubber','Rim','Alloy']
colors={'Paint':[144,35,45],'Accent':[62,64,72],'Glass':[83,107,119],'Mechanical':[49,54,57],'Trim':[43,47,50],'Fabric':[53,55,58],'Carpet':[46,47,49],'Alloy':[164,173,177],'Leather':[118,84,73],'Plate':[205,211,206],'Amber':[234,156,54],'Red':[193,39,41],'Lamp':[206,226,235],'Mirror':[153,170,180],'Brake':[174,56,46],'Disc':[114,122,125],'Rubber':[34,36,39],'Rim':[76,82,86]}
blob=bytearray()
out={'asset':{'version':'2.0'},'scene':0,'scenes':[{'nodes':[]}],'nodes':[],'meshes':[],'accessors':[],'bufferViews':[]}
manifest={}
def accessor(a,kind):
 while len(blob)%4:blob.append(0)
 size=len(blob);blob.extend(a.tobytes())
 view=len(out['bufferViews']);out['bufferViews'].append(dict(buffer=0,byteOffset=size,byteLength=a.nbytes))
 idx=len(out['accessors']);x=dict(bufferView=view,componentType=5123 if kind=='SCALAR' else 5126,count=len(a),type=kind)
 if kind=='VEC3':x.update(min=a.min(0).tolist(),max=a.max(0).tolist())
 out['accessors'].append(x);return idx
for label,filename,url,length in catalog:
 path=Path(tempfile.gettempdir())/filename
 if not path.exists():path.write_bytes(urlopen(url).read())
 raw=path.read_bytes();sz=struct.unpack_from('<I',raw,12)[0];g=json.loads(raw[20:20+sz]);data=raw[28+sz:]
 def read(i):
  a=g['accessors'][i];b=g['bufferViews'][a['bufferView']]
  dim={'SCALAR':1,'VEC3':3}[a['type']];dt=np.dtype({5126:'<f4',5123:'<u2',5125:'<u4',5121:'u1'}[a['componentType']])
  return np.ndarray((a['count'],dim),dtype=dt,buffer=data,offset=b.get('byteOffset',0)+a.get('byteOffset',0),strides=(b.get('byteStride',dt.itemsize*dim),dt.itemsize))
 pieces=[];lights=[]
 def visit(i,aff):
  node=g['nodes'][i];name=node.get('name','')
  if 'matrix' in node:tf=np.array(node['matrix']).reshape(4,4).T
  else:
   tf=np.eye(4);tf[:3,3]=node.get('translation',[0]*3);tf[:3,:3]=Rotation.from_quat(node.get('rotation',[0,0,0,1])).as_matrix()@np.diag(node.get('scale',[1]*3))
  aff=aff@tf
  if 'mesh' in node:
   for p in g['meshes'][node['mesh']]['primitives']:
    material=p['material']; key=g['materials'][material].get('name','')
    if label=='GT':finish=styles[material] if material<len(styles) else 'Trim'
    else:finish={'blue':'Paint','green':'Paint','glass':'Glass','chrome':'Alloy','steel':'Disc','rubber':'Rubber','lamp':'Lamp','tail':'Red','black':'Trim','white':'Plate'}[key]
    if 'emblem' in name.lower() or 'logo' in name.lower():continue
    v=read(p['attributes']['POSITION'])@aff[:3,:3].T+aff[:3,3];n=read(p['attributes']['NORMAL'])@np.linalg.inv(aff[:3,:3]);n/=np.maximum(np.linalg.norm(n,axis=1,keepdims=True),1e-7)
    faces=read(p['indices']).reshape(-1,3)
    if np.linalg.det(aff[:3,:3])<0:faces=faces[:,::-1]
    pieces.append((finish,v,n,faces))
    if finish=='Lamp':lights.append(v)
  for sub in node.get('children',[]):visit(sub,aff)
 for i in g['scenes'][0]['nodes']:visit(i,np.eye(4))
 vs=np.concatenate([p[1] for p in pieces]);lo,hi=vs.min(0),vs.max(0);axis=0 if (hi-lo)[0]>(hi-lo)[2] else 2
 yaw=0 if axis==2 else np.pi/2
 turn=Rotation.from_euler('y',yaw).as_matrix()
 if ((np.concatenate(lights).mean(0)-(lo+hi)/2)@turn.T)[2]>0:turn=Rotation.from_euler('y',yaw+np.pi).as_matrix()
 center=(lo+hi)/2;center[1]=lo[1]
 scale=length/(hi-lo)[axis];groups=defaultdict(list)
 for finish,v,n,faces in pieces:
  v=(v-center)@turn.T*scale+[0,.45,0];n=n@turn.T
  groups[finish].append((v,n,faces))
 for finish,parts in groups.items():
  verts=[];norm=[];inds=[];count=0
  for v,n,faces in parts:
   verts.append(v);norm.append(n);inds.append(faces+count);count+=len(v)
  v=np.concatenate(verts);n=np.concatenate(norm);idx=np.concatenate(inds)
  for k in range(0,len(idx),7000):
   unique,indices=np.unique(idx[k:k+7000].flatten(),return_inverse=True)
   pts=v[unique].astype('<f4');normal=n[unique].astype('<f4')
   ni=len(out['nodes']);tag=label+'_'+finish+'_'+str(k//7000)
   prm={'attributes':{'POSITION':accessor(pts,'VEC3'),'NORMAL':accessor(normal,'VEC3')},'indices':accessor(indices.astype('<u2'),'SCALAR')}
   out['nodes'].append({'name':tag,'mesh':ni});out['scenes'][0]['nodes'].append(ni);out['meshes'].append({'name':tag,'primitives':[prm]})
   manifest[tag]={'car':label,'finish':finish,'color':colors[finish],'center':((pts.max(0)+pts.min(0))/2).tolist()}
 print(label,'size',np.round((hi-lo)*scale,2),'triangles',sum(len(p[3]) for p in pieces))
out['buffers']=[{'byteLength':len(blob)}];doc=json.dumps(out,separators=(',',':')).encode();doc+=b' '*(-len(doc)%4);blob.extend(b'\0'*(-len(blob)%4))
(base/'patapsco-road-cars.glb').write_bytes(struct.pack('<4sII',b'glTF',2,28+len(doc)+len(blob))+struct.pack('<I4s',len(doc),b'JSON')+doc+struct.pack('<I4s',len(blob),b'BIN\0')+blob)
(base/'road-cars.json').write_text(json.dumps(manifest))
