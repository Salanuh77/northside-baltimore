local rb=require('@lune/roblox')
return function(part,group,label,action,city)
 local m=group('Patapsco Detention Center',city)
 local brick=rb.Color3.fromRGB(143,86,69)
 local cream=rb.Color3.fromRGB(204,195,173)
 local blue=rb.Color3.fromRGB(56,91,100)
 local function p(name,w,h,d,x,y,z,c,mat)
  return part(name,{w,h,d},{-120+x,y,1126+z},c,mat or 'Concrete',m)
 end
 p('Campus grounds',184,5,150,0,-2.6,20,'green','Grass')
 p('Visitor walk',19,.65,68,0,.4,-56,cream)
 p('Entry court',87,.65,18,0,.5,-38,cream)
 p('Visiting lobby floor',80,.85,22,0,.71,-22,cream,'Marble')
 p('Detention floor',80,.85,54,0,.71,15,cream)
 p('North wall',80,18,1,0,10,-12,brick,'Brick')
 p('South wall',80,18,1,0,10,42,brick,'Brick')
 for _,s in {-1,1} do
  p('End wall',1,18,75,s*40,10,4.5,brick,'Brick')
  p('Visitor glazing',33,12,.65,s*23.5,7.3,-33,blue,'Glass').Transparency=.35
  p('Visitor transom',80,5,1,0,16.3,-33,brick,'Brick')
  for j=1,3 do
   local x=s*(6+j*9)
   p('Window pier',.8,14,1,x,8.2,-33,cream)
  end
 end
 p('Institutional roof',82,1,77,0,19.3,4.5,'dark','Slate')
 p('Carved entrance stone',50,3,1,0,15.5,-33.6,cream,'Limestone')
 label(m['Carved entrance stone'],'PATAPSCO DETENTION CENTER',blue)
 for k=-2,2 do
  local x=k*15
  p('Cell partition',.85,10,13,x-7.2,6,35,brick,'Brick')
  p('Bunk',5.4,.9,9,x-3,3,35,'dark','Metal'); p('Mattress',5.2,.6,8.8,x-3,3.7,35,blue,'Fabric')
  for bar=-2,2 do p('Cell bar',.24,10,.25,x+bar*1.35-3,6,28,'dark','Metal') end
  p('Cell lintel',14,1,.65,x,11,28,'dark','Metal')
 end
 for _,x in {-19,19} do p('Dayroom table',9,.55,5,x,4,11,cream); p('Table leg',2,3,2,x,2.5,11,'dark','Metal') end
 local function panel(name,kind,caption,x,z,back)
  p('Terminal plinth',4.1,3.3,2.8,x,2.6,z,blue,'Metal')
  local screen=p(name,4.3,2.4,.4,x,5,z+(back and 1.5 or -1.5),blue,'Metal')
  if back then screen.CFrame*=rb.CFrame.Angles(0,math.pi,0) end
  label(screen,caption,cream); action(screen,kind,caption)
 end
 panel('Visitor bail window','BailDesk','BAIL',-13,-17,false)
 panel('Resident bail terminal','BailDesk','BAIL',-20,-8,true)
 panel('Recreation game terminal','EscapeGame','LIGHT RUN',20,-8,true)
 local function marker(name,x,z)
  local mark=p(name,2,.1,2,x,1.3,z,cream); mark.Transparency=1; mark.CanCollide=false; mark.CanQuery=false
 end
 marker('Intake',0,16); marker('Release',0,-41); marker('Escape landing',55,13)
end
