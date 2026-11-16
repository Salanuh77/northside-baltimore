local handling=require('../src/VehicleHandling')
for _,hz in {30,60,120} do
 local function drive(seconds,speed,wheel,yaw,gas,steer,brake,fuel)
  for _=1,math.floor(seconds*hz) do speed,wheel,yaw=handling.step(speed,wheel,yaw,gas,steer,brake,fuel,1/hz) end
  return speed,wheel,yaw
 end
 local speed,wheel,yaw=drive(1,0,0,0,1,1,false,100)
 assert(speed>=30 and wheel==1 and yaw<-.5,'Cannot negotiate a corner')
 local stopped=drive(.7,50,0,0,1,0,true,100)
 assert(stopped==0,'Brake must stop forward propulsion with throttle held')
 assert(drive(.5,-17,0,0,-1,0,true,100)==0,'Reverse braking')
 local backwards,_,reverseYaw=drive(2,10,0,0,-1,1,false,100)
 assert(backwards<0 and reverseYaw>0,'Brake before reversing and steer backwards')
 assert(drive(1,0,0,0,1,0,false,0)==0,'Empty tank')
 assert(select(3,drive(1,0,0,0,0,1,false,100))==0,'Parked steering must not pivot the vehicle')
end
print('HANDLING_PASS', '30, 60, 120 Hz')
