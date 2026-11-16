local Handling={}
local function approach(value,target,step)
 return value+math.clamp(target-value,-step,step)
end
function Handling.step(speed,wheel,yaw,gas,steer,brake,fuel,dt)
 dt=math.min(dt,.1)
 local opposing=gas*speed<0
 local target=(brake or fuel<=0) and 0 or gas*(gas>=0 and 50 or 17)
 local rate=(brake or opposing) and 86 or (gas==0 or fuel<=0) and 15 or 31
 speed=approach(speed,opposing and 0 or target,rate*dt)
 wheel=approach(wheel,steer,(steer==0 and 6 or 4.6)*dt)
 local bend=math.rad(39-16*math.clamp(math.abs(speed)/50,0,1))
 local yawRate=math.clamp(speed*math.tan(wheel*bend)/8,-2.05,2.05)
 return speed,wheel,yaw-yawRate*dt
end
return Handling
