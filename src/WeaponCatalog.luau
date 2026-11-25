-- Fictional game balance, not real-world firearm specifications.
local Catalog={Order={'Compact','Shotgun','SMG','Carbine'}}
Catalog.Guns={
 Compact={Name='Harbor Compact',Price=250,Damage=24,Interval=.3,Capacity=12,Reload=2,Range=140,Spread=.65,AimSpread=.2,Pellets=1,Automatic=false,Mesh='sidearm',Length=.95,GripY=-.15,GripZ=.28,MuzzleY=.25,Scope=false,Suppressor=true},
 Shotgun={Name='Foundry Pump',Price=650,Damage=9,Interval=.95,Capacity=6,Reload=2.8,Range=70,Spread=6,AimSpread=4,Pellets=6,Automatic=false,Mesh='shotgun',Length=2.35,GripY=-.02,GripZ=.2,MuzzleY=.04,Scope=false,Suppressor=false},
 SMG={Name='Lanvale PDW',Price=750,Damage=11,Interval=.105,Capacity=24,Reload=2.4,Range=110,Spread=2.6,AimSpread=1,Pellets=1,Automatic=true,Mesh='smg',Length=1.65,GripY=-.12,GripZ=.25,MuzzleY=.09,RailY=.18,ScopeZ=-.05,Scope=true,Suppressor=true},
 Carbine={Name='Patapsco Precision',Premium=true,Damage=24,Interval=.35,Capacity=12,Reload=2.4,Range=230,Spread=1.3,AimSpread=.12,Pellets=1,Automatic=false,Mesh='carbine',Length=2.45,GripY=-.058,GripZ=.2,MuzzleY=.06,RailY=.1,ScopeZ=.04,Scope=true,Suppressor=true},
}
Catalog.Attachments={
 Scope={Name='Compact optic',Price=180,Description='Magnified aiming for the PDW or precision carbine.',Mesh='scope'},
 Suppressor={Name='Quiet muzzle',Price=220,Description='Reduced flash and shot range. Nearby players and witnesses can still hear it.',Mesh='suppressor'},
}
function Catalog.get(id) return Catalog.Guns[id] or Catalog.Guns.Compact end
function Catalog.supports(id,attachment) return Catalog.Guns[id] and Catalog.Guns[id][attachment]==true end
function Catalog.hearing(suppressed) return suppressed and 28 or 110 end
return Catalog
