local rb,fs=require('@lune/roblox'),require('@lune/fs')
local motion=require('../art/combat-motion');local Rules=require('../src/StreetCombatRules')
local state=Rules.new(0);local now=0
for _,name in {'Jab','Cross','Hook'} do
 local attack=assert(Rules.attack(state,now));local spec=motion[name]
 assert(spec.contact==attack.windup,'Animation contact must align with server damage timing')
 assert(spec.frames[#spec.frames][1]==attack.duration,'No animation ends before recovery')
 assert(#spec.frames>=6,'Strikes need anticipation, contact, follow-through and recovery')
 local sequence=rb.deserializeModel(fs.readFile('art/combat-'..name..'.rbxm'))[1]
 local marker=false
 for _,child in sequence:GetDescendants() do if child:IsA('KeyframeMarker') and child.Name=='Contact' then marker=true end end
 assert(marker,'Published clip retains contact marker')
 assert(not sequence.Loop,'Punches must not loop')
 now+=attack.duration+.02;Rules.update(state,now)
end
for _,name in {'Ready','Guard','Flinch','GuardHit','Surrender'} do assert(motion[name] and fs.isFile('art/combat-'..name..'.rbxm')) end
print('PASS eight authored clips, strike contact/recovery alignment and markers')
