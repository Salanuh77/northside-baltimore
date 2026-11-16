-- Blend the light falling on players with the geometric sun set by the city clock.
local frames={
 -- hour, brightness, exposure, outdoor sky, indoor fill, grade tint, saturation, haze
 {0,1.65,.03,{88,99,125},{72,72,90},{213,225,250},-.14,1.05},
 {5,1.65,.03,{88,99,125},{72,72,90},{213,225,250},-.14,1.05},
 {7,2.3,.04,{132,130,140},{98,85,85},{255,229,208},-.03,.87},
 {12,2.65,-.08,{148,152,157},{98,100,108},{251,249,244},-.08,.6},
 {16,2.55,-.03,{153,147,142},{104,94,92},{255,241,222},-.055,.67},
 {18,2.3,.05,{141,125,138},{99,83,92},{255,223,201},.025,.9},
 {20,1.8,.04,{101,108,139},{79,78,95},{222,222,249},-.08,1.12},
 {24,1.65,.03,{88,99,125},{72,72,90},{213,225,250},-.14,1.05},
}
return function(lighting,hour)
 local grade=lighting:FindFirstChildOfClass('ColorCorrectionEffect')
 local air=lighting:FindFirstChildOfClass('Atmosphere')
 local minute=hour%24
 for i=2,#frames do
  local first,last=frames[i-1],frames[i]
  if minute<=last[1] then
   local t=math.clamp((minute-first[1])/(last[1]-first[1]),0,1)
   local function number(k) return first[k]+(last[k]-first[k])*t end
   local function color(k)
    return Color3.fromRGB(table.unpack(first[k])):Lerp(Color3.fromRGB(table.unpack(last[k])),t)
   end
   lighting.Brightness=number(2);lighting.ExposureCompensation=number(3)
   lighting.OutdoorAmbient=color(4);lighting.Ambient=color(5)
   if grade then grade.TintColor=color(6);grade.Saturation=number(7) end
   if air then air.Haze=number(8) end
   return
  end
 end
end
