"""Source-mesh silhouette review, not a Roblox screenshot."""
from pathlib import Path
import os
import numpy as np
import trimesh
from PIL import Image, ImageDraw

root=Path(__file__).parent
canvas=Image.new('RGB',(1100,960),(222,226,229))
draw=ImageDraw.Draw(canvas)
for row,key in enumerate(['sidearm','smg','shotgun','carbine']):
    scene=trimesh.load(root/f'weapon-{key}.glb',force='scene')
    mesh=scene.to_mesh()
    vertices=np.asarray(mesh.vertices)
    lo,hi=vertices.min(0),vertices.max(0)
    vertices=(vertices-(lo+hi)/2)/(hi[0]-lo[0])
    tri=vertices[mesh.faces]
    for face in np.argsort(tri[:,:,2].mean(1)):
        points=tri[face]
        normal=np.cross(points[1]-points[0],points[2]-points[0])
        normal/=max(np.linalg.norm(normal),1e-8)
        shade=int(80+60*max(0,np.dot(normal,np.array([-.3,.5,.8]))))
        coords=[(550+x*560,120+row*240-y*235) for x,y,z in points]
        draw.polygon(coords,fill=(shade,shade+3,shade+5))
    draw.text((20,row*240+15),key,fill=(20,24,28))
    draw.text((20,row*240+32),'source X: left negative / right positive',fill=(20,24,28))
    # Normalized source-space grid helps choose a grip from actual geometry.
    for x in [-.4,-.2,0,.2,.4]:
        draw.line((550+x*560,row*240+20,550+x*560,row*240+220),fill=(150,162,170))
        draw.text((550+x*560,row*240+222),str(x),fill=(20,24,28))
out=Path(os.environ['TEMP'])/'baltimore-weapon-silhouettes.png'
canvas.save(out)
print(out)
