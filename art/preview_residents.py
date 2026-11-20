"""Offscreen mesh review; source-space front and three-quarter views, not a game screenshot."""
from pathlib import Path
import os
import moderngl as gl
import numpy as np
from PIL import Image
from pyrr import Matrix44
from resident_profiles import rings,PROFILES,ROOT
from resident_grooms import make
from resident_features import surface

ctx=gl.create_standalone_context()
fb=ctx.simple_framebuffer((1200,800));fb.use();ctx.enable(gl.DEPTH_TEST|gl.BLEND)
fb.clear(.14,.17,.21,1)
shader=ctx.program(vertex_shader='''#version 330
uniform mat4 mvp;in vec3 pos;in vec3 normal;in vec2 uv;out vec3 n;out vec2 tex;
void main(){gl_Position=mvp*vec4(pos,1);n=normal;tex=uv;}''',fragment_shader='''#version 330
uniform vec3 color;uniform bool textured;uniform sampler2D image;in vec3 n;in vec2 tex;out vec4 pixel;
void main(){float l=.67+.33*max(dot(normalize(n),normalize(vec3(-.7,.8,-1.))),0.);
vec4 c=textured?texture(image,tex):vec4(color,1);if(c.a<.03)discard;pixel=vec4(c.rgb*l,c.a);}''')
def draw(vertices,faces,color,uv=None,texture=None):
    normals=np.zeros_like(vertices)
    tri=vertices[faces];normal=np.cross(tri[:,1]-tri[:,0],tri[:,2]-tri[:,0])
    for col in faces.T:np.add.at(normals,col,normal)
    normals/=np.maximum(np.linalg.norm(normals,axis=1)[:,None],1e-7)
    uv=np.zeros((len(vertices),2)) if uv is None else uv
    data=np.column_stack((vertices,normals,uv))[faces.ravel()].astype('f4')
    shader['color'].value=color;shader['textured'].value=texture is not None
    if texture is not None:
        im=Image.open(texture).convert('RGBA').transpose(Image.Transpose.FLIP_TOP_BOTTOM)
        tx=ctx.texture(im.size,4,im.tobytes());tx.use()
    buf=ctx.buffer(data.tobytes());vao=ctx.vertex_array(shader,[(buf,'3f 3f 2f','pos','normal','uv')]);vao.render();vao.release();buf.release()
    if texture is not None:tx.release()
def plate(x,y,z,w,h,texture,tilt=0):
    v=np.array([[-w/2,-h/2,0],[w/2,-h/2,0],[w/2,h/2,0],[-w/2,h/2,0]])
    angle=np.radians(tilt);r=np.array([[1,0,0],[0,np.cos(angle),-np.sin(angle)],[0,np.sin(angle),np.cos(angle)]])
    draw(v@r.T+[x,y,z],np.array([[0,2,1],[0,3,2]]),(1,1,1),np.array([[0,0],[1,0],[1,1],[0,1]]),texture)
for row,yaw in enumerate([0,35]):
 for col,(hair,shape) in enumerate([('High puff','Oval'),('Twists','Square'),('Low puff','Round')]):
    ctx.viewport=(col*400,(1-row)*400,400,400)
    angle=np.radians(yaw);eye=[3.1*np.sin(angle),.20,-3.1*np.cos(angle)]
    mvp=Matrix44.perspective_projection(36,1,.1,50)*Matrix44.look_at(eye,[0,.23,0],[0,1,0])
    shader['mvp'].write(mvp.astype('f4').tobytes())
    draw(*rings(PROFILES[shape]),(.60,.36,.23))
    v,f,uv=make(hair);draw(v,f,(.075,.060,.047))
    for kind,filename in [('Eyes','portrait-calm.png'),('Mouth','lips-level.png')]:
        v,f,uv=surface(shape,kind);uv[:,1]=1-uv[:,1]
        draw(v,f,(1,1,1),uv,ROOT/filename)
out=Path(os.environ['TEMP'])/'baltimore-resident-art-review.png'
Image.frombytes('RGB',(1200,800),fb.read(components=3)).transpose(Image.Transpose.FLIP_TOP_BOTTOM).save(out)
print(out)
